require 'test_helper'

class DocumentsControllerTest < ActionDispatch::IntegrationTest
	
	def create_admin_role
		user = User.create(email: 'admin@test.com', password: 'password', password_confirmation: 'password', admin: true)
		return user
	end
	
	test "should get documents index" do
		get "/doc"
		assert_response :success
	end

	test "user should not see document upload page" do
		get "/doc/new"
		assert_equal 302, status
		follow_redirect!
		assert_equal "/users/sign_in", path
		assert_equal 200, status
	end
	
	test "admin should see document upload page" do
		@admin = create_admin_role
  		get "/users/sign_in"
		assert_equal 200, status
		post "/users/sign_in", params:{ user: {email: @admin.email, password: @admin.password} }
		follow_redirect!
		assert_equal 200, status
		assert_equal 'Signed in successfully.', flash[:notice]
		get "/doc/new"
		assert_response :success
		assert_equal "/doc/new", path
	end

end
