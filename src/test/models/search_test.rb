require 'test_helper'

class SearchTest < ActiveSupport::TestCase

	def create_search
		s = Search.new
		s.tr_paragraph_id = 1
		s.transcription_xml_id = 1
		s.entry = "entry"
		s.lang = "lat"
		s.volume = 1
		s.page = 1
		s.paragraph = 1
		s.content = "hello"
		s.date = Date.current()
		s.date_incorrect = "yes"
		return s
	end

	def create_tr_paragraph(search_id)
		t = TrParagraph.new
		t.content_xml = ""
		t.content_html = ""
		t.search_id = search_id
		assert t.save!, "Did not save TrParagraph with valid search ID"
		return t
	end

	def create_transcription(search_id)
		FileUtils.copy Rails.root.join('test/fixtures/files/xml/ARO-5-9999-01_ARO-5-9999-11_WH_EF_AH.xml'), \
		Rails.root.join('test/fixtures/files/xml/ARO-5-9999-01_ARO-5-9998-11_WH_EF_AH.xml')
		transcription_xml = TranscriptionXml.new
		transcription_xml.filename = 'test_transcription'
		transcription_xml.xml = File.open(Rails.root.join('test/fixtures/files/xml/ARO-5-9999-01_ARO-5-9998-11_WH_EF_AH.xml'), 'r')
		assert transcription_xml.save, 'Saved transcription without xml'
		return transcription_xml
	end

	test "should not save Search without transcription xml" do
		s = create_search
		tr = create_tr_paragraph(s.id)
		s.tr_paragraph_id = tr.id
		assert_raises(ActiveRecord::InvalidForeignKey) do
			assert_not s.save!, "saved Search without transcription xml"
		end
	end

	test "should not save Search without tr_paragraph xml" do
		s = create_search
		t = create_transcription(s.id)
		s.transcription_xml_id = t.id
		assert_raises(ActiveRecord::InvalidForeignKey) do
			assert_not s.save!, "saved Search without tr_paragraph"
		end
	end

	test "Save Search with valid parameters" do
		s = create_search
		t = create_transcription(s.id)
		s.transcription_xml_id = t.id
		tr = create_tr_paragraph(s.id)
		s.tr_paragraph_id = tr.id
		assert s.save!
	end

end
