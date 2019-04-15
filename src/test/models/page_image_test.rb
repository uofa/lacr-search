require 'test_helper'
require 'fileutils'

class PageImageTest < ActiveSupport::TestCase

	test_files_path = Rails.root.join('test/fixtures/files/')
	
	test 'should not save image if not tif format' do
		FileUtils.copy test_files_path.join('jpg/Awesome_Bridge_11658x6112.jpg'), \
		test_files_path.join('jpg/Awesome_Bridge_11658x6112-copy.jpg')
		img = PageImage.new
		img.image = File.open(test_files_path.join('jpg/Awesome_Bridge_11658x6112-copy.jpg'), 'r')
		img.parse_filename_to_volume_page 'Awesome_Bridge_11658x6112-copy.jpg'
		assert_not img.save, 'Saved the image if it was not tif format'
	end

	test 'should save image if tif format' do
		FileUtils.copy test_files_path.join('tif/GB0230CA000100001-00005-00001-09999-.tif'), \
		test_files_path.join('tif/GB0230CA000100001-00005-00001-09998-.tif')
		img = PageImage.new
		img.image = File.open(test_files_path.join('tif/GB0230CA000100001-00005-00001-09998-.tif'), 'r')
		img.parse_filename_to_volume_page 'GB0230CA000100001-00005-00001-09998-.tif'
		assert img.save!, 'It did not save the image in tif format'
	end

	test 'should not save image without volume' do
		FileUtils.copy test_files_path.join('tif/GB0230CA000100001-00005-00001-09999-.tif'), \
		test_files_path.join('tif/GB0230CA000100001-00005-00001-09998-.tif')
		img = PageImage.new
		img.image = File.open(test_files_path.join('tif/GB0230CA000100001-00005-00001-09998-.tif'), 'r')
		img.page = rand(0..9999)
		assert_not img.save, 'Saved the image without volume'
	end

	test 'should not save image without page' do
		FileUtils.copy test_files_path.join('tif/GB0230CA000100001-00005-00001-09999-.tif'), \
		test_files_path.join('tif/GB0230CA000100001-00005-00001-09998-.tif')
		img = PageImage.new
		img.image = File.open(test_files_path.join('tif/GB0230CA000100001-00005-00001-09998-.tif'), 'r')
		img.volume = rand(0..9999)
		assert_not img.save, 'Saved the image without page'
	end

	test 'should not save image with negative number for volume' do
		FileUtils.copy test_files_path.join('tif/GB0230CA000100001-00005-00001-09999-.tif'), \
		test_files_path.join('tif/GB0230CA000100001-00005-00001-09998-.tif')
		img = PageImage.new
		img.image = File.open(test_files_path.join('tif/GB0230CA000100001-00005-00001-09998-.tif'), 'r')
		img.volume = rand(-9999..-1)
		img.page = rand(0..9999)
		assert_not img.save, 'Saved the image with negative volume number'
	end

	test 'should not save image negative number for page' do
		FileUtils.copy test_files_path.join('tif/GB0230CA000100001-00005-00001-09999-.tif'), \
		test_files_path.join('tif/GB0230CA000100001-00005-00001-09998-.tif')
		img = PageImage.new
		img.image = File.open(test_files_path.join('tif/GB0230CA000100001-00005-00001-09998-.tif'), 'r')
		img.volume = rand(0..9999)
		img.page = rand(-9999..-1)
		assert_not img.save, 'Saved the image with negative page number'
	end

end
