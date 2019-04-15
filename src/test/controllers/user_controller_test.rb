require 'test_helper'

class UserControllerTest < ActionDispatch::IntegrationTest

	test "user should see login page" do
		get "/sign_in"
		assert_equal 200, status
	end

	test "user should be able sign_up" do
  		get "/users/sign_up"
		assert_equal 200, status
		post "/users", params:{ user: {email: 'user@test.com', password: 'password', password_confirmation: 'password'} }
		follow_redirect!
		assert_equal 200, status
		assert_equal 'Welcome! You have signed up successfully.', flash[:notice]
	end

	test "user should not be able sign_up with already registered email" do
		@user = User.create(email: 'user@test.com', password: 'password', password_confirmation: 'password')
  		get "/users/sign_up"
		assert_equal 200, status
		post "/users", params:{ user: {email: 'user@test.com', password: 'password', password_confirmation: 'password'} }
		assert_equal 200, status
		assert_equal "/users", path
		assert_select 'div.alert' do
			assert_select 'h5', '1 error prohibited this user from being saved:'
			assert_select 'li', 'Email has already been taken'
		end
	end

	test "user should not be able sign_up with different password confirmation" do
  		get "/users/sign_up"
		assert_equal 200, status
		post "/users", params:{ user: {email: 'user@test.com', password: 'password2', password_confirmation: 'password'} }
		assert_equal 200, status
		assert_equal "/users", path
		assert_select 'div.alert' do
			assert_select 'h5', '1 error prohibited this user from being saved:'
			assert_select 'li', 'Password confirmation doesn\'t match Password'
		end
	end

	test "user should be able to login" do
		@user = User.create(email: 'user@test.com', password: 'password', password_confirmation: 'password')
  		get "/users/sign_in"
		assert_equal 200, status
		post "/users/sign_in", params:{ user: {email: @user.email, password: @user.password} }
		follow_redirect!
		assert_equal 200, status
		assert_equal 'Signed in successfully.', flash[:notice]
	end

	test "user should not be able to login with wrong password" do
		@user = User.create(email: 'user@test.com', password: 'password', password_confirmation: 'password')
		get "/users/sign_in"
		assert_equal 200, status
		post "/users/sign_in", params:{ user: {email: @user.email, password: 'password2'} }
		assert_equal 200, status
		assert_equal "/users/sign_in", path
		assert_equal 'Invalid Email or password.', flash[:alert]
	end

	test "user should not be able to login with wrong email" do
		@user = User.create(email: 'user@test.com', password: 'password', password_confirmation: 'password')
		get "/users/sign_in"
		assert_equal 200, status
		post "/users/sign_in", params:{ user: {email: 'user1@test.com', password: @user.password} }
		assert_equal 200, status
		assert_equal "/users/sign_in", path
		assert_equal 'Invalid Email or password.', flash[:alert]
	end

	test "user should be able to edit password" do
		@user = User.create(email: 'user@test.com', password: 'password', password_confirmation: 'password')
  		get "/users/sign_in"
		assert_equal 200, status
		post "/users/sign_in", params:{ user: {email: @user.email, password: @user.password} }
		follow_redirect!
		assert_equal 200, status
		assert_equal 'Signed in successfully.', flash[:notice]
		get "/users/edit"
		assert_equal 200, status
		put "/users", params:{ user: {email: @user.email, password: 'password2',
			password_confirmation: 'password2', current_password: @user.password} }
		follow_redirect!
		assert_equal 200, status
		assert_equal 'Your account has been updated successfully.', flash[:notice]
	end

	test "user should not be able to edit password without confirmation" do
		@user = User.create(email: 'user@test.com', password: 'password', password_confirmation: 'password')
  		get "/users/sign_in"
		assert_equal 200, status
		post "/users/sign_in", params:{ user: {email: @user.email, password: @user.password} }
		follow_redirect!
		assert_equal 200, status
		assert_equal 'Signed in successfully.', flash[:notice]
		get "/users/edit"
		assert_equal 200, status
		put "/users", params:{ user: {email: @user.email, password: 'password2',
			password_confirmation: 'password', current_password: @user.password} }
		assert_equal 200, status
		assert_equal "/users", path
		assert_select 'li', 'Password confirmation doesn\'t match Password'
	end

	test "user should not be able to edit password with invalid current password" do
		@user = User.create(email: 'user@test.com', password: 'password', password_confirmation: 'password')
  		get "/users/sign_in"
		assert_equal 200, status
		post "/users/sign_in", params:{ user: {email: @user.email, password: @user.password} }
		follow_redirect!
		assert_equal 200, status
		assert_equal 'Signed in successfully.', flash[:notice]
		get "/users/edit"
		assert_equal 200, status
		put "/users", params:{ user: {email: @user.email, password: 'password2',
			password_confirmation: 'password2', current_password: 'password3'} }
		assert_equal 200, status
		assert_equal "/users", path
		assert_select 'li', 'Current password is invalid'
	end


	test "user should be able to edit email" do
		@user = User.create(email: 'user@test.com', password: 'password', password_confirmation: 'password')
  		get "/users/sign_in"
		assert_equal 200, status
		post "/users/sign_in", params:{ user: {email: @user.email, password: @user.password} }
		follow_redirect!
		assert_equal 200, status
		assert_equal 'Signed in successfully.', flash[:notice]
		get "/users/edit"
		assert_equal 200, status
		put "/users", params:{ user: {email: 'user1@test.com', password: '',
			password_confirmation: '', current_password: @user.password} }
		follow_redirect!
		assert_equal 200, status
		assert_equal 'Your account has been updated successfully.', flash[:notice]
	end

	test "user should not be able to edit email if already registered" do
		@user = User.create(email: 'user@test.com', password: 'password', password_confirmation: 'password')
		@user1 = User.create(email: 'user1@test.com', password: 'password', password_confirmation: 'password')
  		get "/users/sign_in"
		assert_equal 200, status
		post "/users/sign_in", params:{ user: {email: @user.email, password: @user.password} }
		follow_redirect!
		assert_equal 200, status
		assert_equal 'Signed in successfully.', flash[:notice]
		get "/users/edit"
		assert_equal 200, status
		put "/users", params:{ user: {email: @user1.email, password: '',
			password_confirmation: '', current_password: @user.password} }
		assert_equal 200, status
		assert_equal "/users", path
		assert_select 'li', 'Email has already been taken'
	end

	test "user should be able to sign out" do
		@user = User.create(email: 'user@test.com', password: 'password', password_confirmation: 'password')
  		get "/users/sign_in"
		assert_equal 200, status
		post "/users/sign_in", params:{ user: {email: @user.email, password: @user.password} }
		follow_redirect!
		assert_equal 200, status
		assert_equal 'Signed in successfully.', flash[:notice]
		delete "/users/sign_out"
		follow_redirect!
		assert_equal 200, status
		assert_equal 'Signed out successfully.', flash[:notice]
	end

	test "user should be able to destroy the account" do
		@user = User.create(email: 'user@test.com', password: 'password', password_confirmation: 'password')
		get "/users/sign_in"
		assert_equal 200, status
		post "/users/sign_in", params:{ user: {email: @user.email, password: @user.password} }
		follow_redirect!
		assert_equal 200, status
		assert_equal 'Signed in successfully.', flash[:notice]
		delete "/users"
		follow_redirect!
		assert_equal 200, status
		assert_equal 'Bye! Your account has been successfully cancelled. We hope to see you again soon.', flash[:notice]
	end
end
