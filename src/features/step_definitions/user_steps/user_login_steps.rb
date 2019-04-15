Given(/^I am on the home page$/) do
	if User.find_by_email('testuser@test.com').nil?
		User.create!(email: 'testuser@test.com', password: 'password', password_confirmation: 'password')
	end
 	visit '/'
	page.current_path == '/'
end

Given(/^I have chosen to log in$/) do
	click_on 'Login'
	page.current_path == '/login'
end

When(/^I enter my email$/) do
	fill_in 'Email', with: 'testuser@test.com'
end

When(/^I enter my password$/) do
	fill_in 'Password', with: 'password'
end

When(/^I enter invalid password$/) do
	fill_in 'Password', with: 'password2'
end

Then(/^I should be on the login page$/) do
	page.current_path == '/login'
end

When(/^I enter an email which is not registered yet$/) do
	fill_in 'Email', with: 'testuser1@test.com'
end
