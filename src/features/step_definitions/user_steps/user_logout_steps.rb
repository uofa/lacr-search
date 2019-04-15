When(/^I click on log out$/) do
  click_on 'Logout'
end

Then(/^I should be logged out$/) do
  page.has_content? 'Signed out successfully.'
  page.current_path == '/'
end