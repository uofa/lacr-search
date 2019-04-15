require 'test_helper'

class UserTest < ActiveSupport::TestCase

	test "should not save user without email" do
		user = User.new(email: '', password: 'password', password_confirmation: 'password')
		assert_not user.save, "Saved the user without an email"
	end

	test "should not save user without password" do
		user = User.new(email: 'user@test.com', password: '', password_confirmation: 'password')
		assert_not user.save, "Saved the user without a password"
	end

	test "should not save user without password confirmation" do
		user = User.new(email: 'user@test.com', password: 'password', password_confirmation: '')
		assert_not user.save, "Saved the user without a password confirmation"
	end

	test "should not save user with different password confirmation" do
		user = User.new(email: 'user@test.com', password: 'password', password_confirmation: 'password2')
		assert_not user.save, "Saved the user with different password confirmation"
	end

	test "should not save user with illegal email" do
		user = User.new(email: 'user@test', password: 'password', password_confirmation: 'password')
		assert_not user.save, "Saved the user with illegal email user@test"

		user = User.new(email: 'usertest.com', password: 'password', password_confirmation: 'password')
		assert_not user.save, "Saved the user with illegal email usertest.com"

		user = User.new(email: '@test.com', password: 'password', password_confirmation: 'password')
		assert_not user.save, "Saved the user with illegal email @test.com"

		user = User.new(email: 'user@.com', password: 'password', password_confirmation: 'password')
		assert_not user.save, "Saved the user with illegal email user@.com"

		user = User.new(email: 'user.com', password: 'password', password_confirmation: 'password')
		assert_not user.save, "Saved the user with illegal email user.com"

		user = User.new(email: 'user', password: 'password', password_confirmation: 'password')
		assert_not user.save, "Saved the user with illegal email user"
	end

	test "should not save user with short password" do
		user = User.new(email: 'user@test.com', password: 'passw', password_confirmation: 'passw')
		assert_not user.save, "Saved the user with a password shorter than 6 chars"
	end

	test "should save user" do
		user = User.new(email: 'user@test.com', password: 'password', password_confirmation: 'password')
		assert user.save!, "Did not save the user with legal entirs"
	end

	test "should destroy user" do
		user = User.new(email: 'user@test.com', password: 'password', password_confirmation: 'password')
		assert user.save!, "Did not save the user with legal entirs"
		user = User.find_by!(email: 'user@test.com')
		assert user.destroy!, "Did not destroyed the user"
	end

	test "should not save duplicite users" do
		user = User.new(email: 'user@test.com', password: 'password', password_confirmation: 'password')
		assert user.save!, "Did not save the user with legal entirs"
		user = User.new(email: 'user@test.com', password: 'password', password_confirmation: 'password')
		assert_not user.valid?
		assert_raises(ActiveRecord::RecordInvalid) do
	  	assert_not user.save!, "Saved the duplicite users"
		end
	end

	test "should create admin" do
		user = User.new(email: 'admin@test.com', password: 'password', password_confirmation: 'password', admin: true)
		assert user.save!, "Did not save the user with legal entirs"
		user = User.find_by!(email: 'admin@test.com')
		assert user.admin, "Saved the duplicite users"
	end


end
