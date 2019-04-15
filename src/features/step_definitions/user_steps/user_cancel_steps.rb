Given(/^I am logged in as a valid user$/) do
  if User.find_by_email('testuser@test.com').nil?
    User.create!(email: 'testuser@test.com', password: 'password', password_confirmation: 'password')
  end
  visit '/'
  click_on 'Login'
  page.current_path == '/login'
  fill_in 'Email', with: 'testuser@test.com'
  fill_in 'Password', with: 'password'
  click_on 'Sign in'
  page.current_path == '/'
  page.has_content? 'Signed in successfully.'
end

Given(/^I have chosen to cancel my account$/) do
  click_on 'Edit registration'
  page.current_path == '/users/edit'
end

When(/^I approve it$/) do
  accept_alert do
    click_on 'Cancel my account'
  end
end

Then(/^I am notified that it is canceled$/) do
  page.has_content? 'Bye! Your account has been successfully cancelled. We hope to see you again soon.'
end

Then(/^I should be on the home page$/) do
  page.current_path == '/'
end

When(/^I disapprove it$/) do
  dismiss_confirm do
    click_on 'Cancel my account'
  end
end

Then(/^my account should not be canceled$/) do
  !User.find_by_email('testuser@test.com').nil?
end

Then(/^I should be on the edit account page$/) do
  page.current_path == '/users/edit'
end