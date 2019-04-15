Given(/^I have chosen to edit my account$/) do
  click_on 'Edit '
  page.current_path == '/login'
end

When(/^I enter valid email which is not already registered$/) do
  fill_in 'Email', with: 'testuser@test.com'
end

When(/^I enter my current password$/) do
  fill_in 'Password', with: 'password'
end

Then(/^I should see "([^"]*)"$/) do |arg1|
  page.has_content? arg1
end

When(/^I enter valid email which is already registered$/) do
  User.create!(email: 'testuser1@test.com', password: 'password', password_confirmation: 'password')
  fill_in 'Email', with: 'testuser1@test.com'
end

Then(/^I should be on the edit page$/) do
  page.current_path == '/users/edit'
end

When(/^I enter invalid email$/) do
  fill_in 'Email', with: 'testuser@test'
end

When(/^I enter valid password$/) do
  fill_in 'Password', with: 'password1'
end

When(/^I enter valid password confirmation$/) do
  fill_in 'Password confirmation', with: 'password1'
end

When(/^I enter invalid current password$/) do
  fill_in 'Password', with: 'password2'
end

When(/^I enter different valid password confirmation$/) do
  fill_in 'Password confirmation', with: 'password3'
end

When(/^I enter password with less than (\d+) characters$/) do |arg1|
  fill_in 'Password', with: 'passw'
end

When(/^I enter password confirmation with less than (\d+) characters$/) do |arg1|
  fill_in 'Password', with: 'passw'
end