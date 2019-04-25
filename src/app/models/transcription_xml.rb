class TranscriptionXml < ApplicationRecord
  # Use unique filenames and overwrite on upload
  validates_uniqueness_of :filename
  validates :filename, :xml, presence: true

#-----------------------------------
# Definition of functions
#-----------------------------------

  HISTEI_NS = 'http://www.tei-c.org/ns/1.0'
  # Mount the file uploader
  mount_uploader :xml, XmlUploader

  # Extract the volume, page and paragraph from the Entry ID
  def splitEntryID(id)
    return id.to_s.split(/-|_/).map{|x| x.to_i}.delete_if{|i| i==0}
  end

  # Recursive function to convert the XML format to valid HTML5
  def xml_to_html(tag)
    tag.children().each do |c|
      # Rename the attributes
      c.keys.each do |k|
        c["data-#{k}"] = c.delete(k)
      end
      # Rename the tag and replace lb with br
      c['class'] = "xml-tag #{c.name.gsub(':', '-')}"
      # To avoid invalid void tags: Use "br" if "lb", otherwise "span"
      c.name = c.name == 'lb' ?  "br" : "span"
      # Use recursion
      xml_to_html(c)
    end
  end

#-----------------------------------
# Parsing the paragraphs
#-----------------------------------

  def histei_split_to_paragraphs
    doc = Nokogiri::XML (File.open(xml.current_path))

    # Remove Processing Instructions. Tags of type <? .. ?>
    doc.xpath('//processing-instruction()').remove

    #-----------------------------------
    # Create empty page for each not-problemtatic page break
    #-----------------------------------

    # Get all page break tags which are not inside of div entry
    page_breaks = doc.xpath("//xmlns:pb[@n][not(ancestor::xmlns:div[@xml:id])]", 'xmlns' => HISTEI_NS)
    # Volume = the volume of any div in the document (Assuming it is always the same)
    volume = splitEntryID(doc.xpath('//xmlns:div[@xml:id]/@xml:id', 'xmlns' => HISTEI_NS)[0])[0]

    # search_xml_order = []

    # Fix for empty pages
    page_breaks.each do |pb|
      begin
        # The attribute @n is assumed to be the page number
        page = pb.xpath('@n').to_s.to_i
        # If the page in the DB in not yet created
        if not Search.exists?(page: page, volume: volume, paragraph: 1)
          # Create a page with message "Page is empty."
          pr = TrParagraph.new
          pr.content_xml = "<note xmlns=\"http://www.tei-c.org/ns/1.0\"/>Page is empty.<note>"
          pr.content_html = "Page is empty."
          pr.save
          s = Search.new
          s.volume = volume
          s.page = page
          s.paragraph = 1
          s.tr_paragraph = pr
          s.transcription_xml = self
          s.save
          # search_xml_order << s
        end
      rescue StandardError => e
        logger.error(e)
      end
    end

    #-----------------------------------
    # Insert the content of each paragraph
    #-----------------------------------

    # Extract all "div" tags with atribute "xml:id"
    entries = doc.xpath('//xmlns:div[@xml:id]', 'xmlns' => HISTEI_NS)
    # Parse each entry as follows
    entries.each do |entry|
      date_info = parse_date_from_entry(entry)

      dc = entry.xpath("ancestor::xmlns:div[1]//xmlns:date/@cert", 'xmlns' => HISTEI_NS)
      date_certainty = dc.to_s

      # Convert the 'entry' and 'date' Nokogiri objects to Ruby Hashes
      entry_id = entry.xpath('@xml:id').to_s
      entry_lang = entry.xpath('@xml:lang').to_s
      case entry_lang # Fix language standad
      when 'sc'
        entry_lang = 'sco'
      when 'la'
        entry_lang = 'lat'
      when 'nl'
        entry_lang = 'nld'
      end
      entry_xml = entry.to_xml.gsub('xml:lang="sc"', 'xml:lang="sco"').gsub('xml:lang="la"', 'xml:lang="lat"').gsub('xml:lang="nl"', 'xml:lang="nld"')
      entry_text =(Nokogiri::XML(entry_xml.gsub('<lb break="yes"/>', "\n"))).xpath('normalize-space()')
      xml_to_html(entry)
      entry_html = entry.to_xml

      # Split entryID
      volume, page, paragraph = splitEntryID(entry)
      # Overwrite if exists
      if Search.exists?(entry: entry_id)
        s = Search.find_by(entry: entry_id)
        # Get existing paragraph
        pr = s.tr_paragraph
      else
        # Create new search record
        s = Search.new
        # Create TrParagraph record
        pr = TrParagraph.new
      end

      # Save the new content
      pr.content_xml = entry_xml
      pr.content_html = entry_html
      pr.save

      # Create Search record
      s.entry = entry_id
      s.volume = volume
      s.page = page
      s.paragraph = paragraph
      s.tr_paragraph = pr
      s.transcription_xml = self
      s.lang = entry_lang
      s.date = date_info[:entry_date]
      s.date_not_after = date_info[:entry_date_not_after]
      s.date_incorrect = date_info[:entry_date_incorrect]
      s.date_certainty = date_certainty

      # Replace line-break tag with \n and normalize whitespace
      s.content = entry_text
      s.save
      # search_xml_order << s
    end

    doc = Nokogiri::XML (File.open(xml.current_path))
    doc.xpath('//processing-instruction()').remove
    entries_with_page_break = doc.xpath('//xmlns:div[@xml:id]//xmlns:pb[@n]/ancestor::xmlns:div[@xml:id]', 'xmlns' => HISTEI_NS)

    #-----------------------------------
    # Fix problematic page breaks
    # -> Page breaks inside entries
    #-----------------------------------

    # Get all entries with page break(s) inside
    entries_with_page_break.each do |entry|
      begin
        # Split the string of content by the page break(s)
        xml_content_parts = parse_entry_with_page_breaks(entry.to_s)

        xml_content_first_part = xml_content_parts.shift.gsub('xml:lang="sc"', 'xml:lang="sco"').gsub('xml:lang="la"', 'xml:lang="lat"').gsub('xml:lang="nl"', 'xml:lang="nld"')
        entry_obj = Nokogiri::XML(xml_content_first_part)
        xml_to_html(entry_obj)
        html_content_first_part = entry_obj.to_xml

        # Get the problematic entry
        old_entry_id = entry.xpath('@xml:id').to_s
        volume, page, paragraph = splitEntryID(old_entry_id)
        old_search = Search.find_by(entry: old_entry_id, page: page)

        pr = old_search.tr_paragraph
        # Store the updated content for the paragraph record
        pr.content_xml = xml_content_first_part
        pr.content_html = html_content_first_part
        pr.save

        # Now iterate the other entries, creating records for them:
        current_page = page

        xml_content_parts.each do |part|
          # if part is a page number, set the current page number
          if part =~ /<pb[^>]*\/>/
            current_page = number_from_page_element(part)
            next
          end

          # if part is a block, create a Search object for that block using
          # the existing ID but the new page number.
          xml_part = part.gsub('xml:lang="sc"', 'xml:lang="sco"').gsub('xml:lang="la"', 'xml:lang="lat"').gsub('xml:lang="nl"', 'xml:lang="nld"')
          entry_obj = Nokogiri::XML('<div>' + xml_part)
          xml_to_html(entry_obj)
          html_part = entry_obj.to_xml
          pr = TrParagraph.create(content_xml: xml_part, content_html: html_part)
          s = Search.create(
            tr_paragraph: pr,
            entry: old_entry_id,
            volume: volume,
            page: current_page,
            paragraph: 1,
            transcription_xml: old_search.transcription_xml,
            lang: old_search.lang,
            date: old_search.date,
            date_incorrect: old_search.date_incorrect,
            date_certainty: old_search.date_certainty,
            date_not_after: old_search.date_not_after,
            content: Nokogiri::XML("<p>#{part.gsub('<lb break="yes"/>', "\n")}</p>").xpath('normalize-space()'),
          )
        end
      rescue StandardError => e
        logger.error(e)
      end
    end

    # Clean up unneeded empty pages
    Search.where(entry: nil).each do |empty|
      empty.delete unless Search.where(volume: empty.volume, page: empty.page, paragraph: empty.paragraph).count == 1
    end
  end

  def parse_entry_with_page_breaks(entry_str)
    parts = entry_str.match(/(.*)(<pb[^>]*\/>)(.*)/im)

    # parts[1] # The start block
    # parts[2] # the last page number
    # parts[3] # the block after the last page number

    return [entry_str] unless parts

    parse_entry_with_page_breaks(parts[1]) + [parts[2], parts[3]]
  end

  def number_from_page_element(page_str)
    regex = /n="(.*)"/
    page_str.match(regex)[1].to_i
  end

  def parse_date_from_entry(entry)
    # Get date from when, failing that, from notBefore
    d = entry.xpath('ancestor::xmlns:div[1]//xmlns:date/@when', 'xmlns' => HISTEI_NS)
    d = entry.xpath('ancestor::xmlns:div[1]//xmlns:date/@notBefore', 'xmlns' => HISTEI_NS) if d.count.zero?

    # if date is an array, crunch to 1 string
    if d.count > 1
      date_str = ''
      d.each do |entry_date|
        entry_date_str = entry_date.to_s
        date_str = entry_date_str if date_str.length < entry_date_str.length
      end
    else
      date_str = d.to_s
    end

    # Get notAfter, if one exists
    d = entry.xpath('ancestor::xmlns:div[1]//xmlns:date/@notAfter', 'xmlns' => HISTEI_NS)
    date_not_after_str = d.count == 1 ? d.to_s : nil

    entry_date_incorrect = if date_format_correct?(date_str)
      date_from = entry.xpath("ancestor::xmlns:div[1]//xmlns:date/@from", 'xmlns' => HISTEI_NS).to_s
      date_to = entry.xpath("ancestor::xmlns:div[1]//xmlns:date/@to", 'xmlns' => HISTEI_NS).to_s
      entry_date_incorrect = date_from.length != 0 ? "#{date_from}-#{date_to}": 'N/A'
      entry_date = nil # The date is missing
    else
      date_str
    end
    entry_date = correct_date(date_str)
    entry_date_not_after = date_not_after_str ? correct_date(date_not_after_str) : nil

    {
      entry_date: entry_date,
      entry_date_not_after: entry_date_not_after,
      entry_date_incorrect: entry_date_incorrect
    }
  end

  def date_format_correct?(date_str)
    date_str.split('-').length == 3
  end

  def correct_date(date_str)
    if date_str.split('-').length == 3
      date_str.to_date
    elsif date_str.split('-').length == 2
      "#{date_str}-1".to_date # If the day is missing set ot 1-st
    elsif date_str.split('-').length == 1
      "#{date_str}-1-1".to_date # If the day and month are missing set ot 1-st Jan.
    end
  end
end
