require 'test_helper'

class TrParagraphTest < ActiveSupport::TestCase

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
	test "Should not save tr_paragraph with invalit foreign key" do
		t = TrParagraph.new
		t.content_xml = ""
		t.content_html = ""
		t.search_id = 999999
		assert_raises(ActiveRecord::InvalidForeignKey) do
			assert_not t.save!, "saved TrParagraph with invalid foreign key"
		end
	end

	test "Should save tr_paragraph with valid foreign key" do
		s = create_search
		t = TrParagraph.new
		t.content_xml = ""
		t.content_html = ""
		t.search_id = s.id
		assert t.save!, "Did not save TrParagraph with valid search ID"
	end

	test "Should return pdf" do
		s = create_search
		a = []
		a << s
		t = TrParagraph.new().print_data(a)
		assert_not t.empty?, "Did not return PDF file"
	end
end
