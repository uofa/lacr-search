begin
  namespace :import do
    desc 'Imports all xml and image in the uploads directory'
    task :uploads, [:uploads_location] => [:environment] do |_t, args|
      args.with_defaults(uploads_location: '/docker/lacr-search/public/uploads')

      directory = args[:uploads_location]

      xml_files_content = []
      xml_dir = Dir.new(File.join(directory, 'xml'))
      xml_dir.entries.reject { |f| ['.','..'].include?(f) }.each do |filename|
        file_path = File.join(xml_dir.path, filename)
        file_content = []

        puts("Loading: #{filename} as #{file_path}")

        # Create the TranscriptionXml Object
        nokogiri_obj = Nokogiri::XML(File.open(file_path))
        if nokogiri_obj.collect_namespaces.values.include? TranscriptionXml::HISTEI_NS
          t = TranscriptionXml.find_or_create_by(filename: filename)
          # Store the information about the uploaded file
          t.xml = File.new(file_path)
          # If the save was successful

          if t.save!
            # Store file content and filename for import to BaseX
            xml_files_content.push([filename, nokogiri_obj.to_xml.gsub('xml:lang="sc"', 'xml:lang="sco"').gsub('xml:lang="la"', 'xml:lang="lat"').gsub('xml:lang="nl"', 'xml:lang="nld"')])
            # Proccess the XML file
            t.histei_split_to_paragraphs
          end
        end
      end

      # Upload xml content to BaseX
      begin
        session = BaseXClient::Session.new(ENV['BASEX_URL'], 1984, "createOnly", ENV['BASEX_CREATEONLY'])
        session.execute('open xmldb') # Open XML database
        xml_files_content.each do |file_name, file_content|
          begin
            session.replace(file_name, file_content)
          rescue Exception => e
            logger.error(e)
          end
        end
        session.close
      rescue Exception => e
        logger.error(e)
      end

      # Generate new index for Elasticsearch
      Search.reindex

      image_dir = Dir.new(File.join(directory, 'images'))
      image_dir.entries.reject { |f| ['.','..'].include?(f) }.each do |filename|
        # file_path = File.join(image_dir.path, filename)
        t = PageImage.new
        t.image = filename
        t.parse_filename_to_volume_page filename
        t.save!
      end
    end
  end
end
