require 'test_helper'

class TranscriptionXmlTest < ActiveSupport::TestCase

	test_files_path = Rails.root.join('test/fixtures/files/')

	test 'should not save transcription if not xml extension' do
		FileUtils.copy test_files_path.join('xml/ARO-5-9999-01_ARO-5-9999-11_WH_EF_AH.xml'), \
		test_files_path.join('xml/ARO-5-9999-01_ARO-5-9998-11_WH_EF_AH.rb')
		transcription_xml = TranscriptionXml.new
		transcription_xml.filename = 'ARO-5-9999-01_ARO-5-9998-11_WH_EF_AH.rb'
		transcription_xml.xml = File.open(test_files_path.join('xml/ARO-5-9999-01_ARO-5-9998-11_WH_EF_AH.rb'), 'r')
		assert_not transcription_xml.save, 'Saved transcription despite it was not xml extension'
	end

	# this test fails because carrierwave does not support file checking
	# it tests only the extension
	# it could be done in the future by using unix 'file' command
	test 'should not save transcription if content is not xml' do
		skip('To be implemented: check file type with unix command file. carrierwave determines content based on extension.')
		FileUtils.copy test_files_path.join('xml/landscape.jpg'), \
		test_files_path.join('xml/ARO-5-9999-01_ARO-5-9998-12_WH_EF_AH.xml')
		transcription_xml = TranscriptionXml.new
		transcription_xml.filename = 'ARO-5-9999-01_ARO-5-9998-12_WH_EF_AH.xml'
		transcription_xml.xml = File.open(test_files_path.join('xml/ARO-5-9999-01_ARO-5-9998-12_WH_EF_AH.xml'), 'r')
		assert_not transcription_xml.save, 'Saved transcription despite content was not xml'
	end

	test 'should not save transcription without filename' do
		FileUtils.copy test_files_path.join('xml/ARO-5-9999-01_ARO-5-9999-11_WH_EF_AH.xml'), \
		test_files_path.join('xml/ARO-5-9999-01_ARO-5-9998-11_WH_EF_AH.xml')
		transcription_xml = TranscriptionXml.new
		transcription_xml.xml = File.open(test_files_path.join('xml/ARO-5-9999-01_ARO-5-9998-11_WH_EF_AH.xml'), 'r')
		assert_not transcription_xml.save, 'Saved transcription without filename'
	end

	test 'should not save transcription without xml' do
		FileUtils.copy test_files_path.join('xml/ARO-5-9999-01_ARO-5-9999-11_WH_EF_AH.xml'), \
		test_files_path.join('xml/ARO-5-9999-01_ARO-5-9998-11_WH_EF_AH.xml')
		transcription_xml = TranscriptionXml.new
		transcription_xml.filename = 'ARO-5-9999-01_ARO-5-9998-12_WH_EF_AH.xml'
		assert_not transcription_xml.save, 'Saved transcription without xml'
	end
	
	test 'should save transcription with xml and filename' do
		FileUtils.copy test_files_path.join('xml/ARO-5-9999-01_ARO-5-9999-11_WH_EF_AH.xml'), \
		test_files_path.join('xml/ARO-5-9999-01_ARO-5-9998-11_WH_EF_AH.xml')
		transcription_xml = TranscriptionXml.new
		transcription_xml.filename = 'ARO-5-9999-01_ARO-5-9998-12_WH_EF_AH.xml'
		transcription_xml.xml = File.open(test_files_path.join('xml/ARO-5-9999-01_ARO-5-9998-11_WH_EF_AH.xml'), 'r')
		assert transcription_xml.save, 'Did not save transcription with valid parameters'
	end
	
	test 'should split the xml to paragraphs' do
		FileUtils.copy test_files_path.join('xml/ARO-5-9999-01_ARO-5-9999-11_WH_EF_AH.xml'), \
		test_files_path.join('xml/ARO-5-9999-01_ARO-5-9998-11_WH_EF_AH.xml')
		transcription_xml = TranscriptionXml.new
		transcription_xml.filename = 'ARO-5-9999-01_ARO-5-9998-12_WH_EF_AH.xml'
		transcription_xml.xml = File.open(test_files_path.join('xml/ARO-5-9999-01_ARO-5-9998-11_WH_EF_AH.xml'), 'r')
		assert transcription_xml.save, 'Saved transcription without xml'
		assert transcription_xml.histei_split_to_paragraphs
	end

end
