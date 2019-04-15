Feature: User account editing
	In order to edit my password or email
	As a valid user
	I need to click on edit account and change email 
	or password or both at the same time

Background:
	Given I am logged in as a valid user
	And I have chosen to edit my account
	

Scenario: Successful email edit

	Where someone tries to edit email address

	When I enter valid email which is not already registered
	And I enter my current password
	And I click on "Update"
	Then I should see "Your account has been updated successfully."
	And I should be on the home page
	
	
Scenario: Duplicate email

	Where someone tries to edit email which is already registered

	When I enter valid email which is already registered
	And I enter my current password
	And I click on "Update"
	Then I should see "Email has already been taken"
	And I should be on the edit page
	
	
Scenario: Invalid email

	Where someone tries to edit email which is not valid

	When I enter invalid email
	And I enter my current password
	And I click on "Update"
	Then I should see "Email is invalid"
	And I should be on the edit page
	
	
Scenario: Successful password edit

	Where someone tries to edit the password

	When I enter valid password
	And I enter valid password confirmation
	And I enter my current password
	And I click on "Update"
	Then I should see "Your account has been updated successfully."
	And I should be on the home page
	
	
Scenario: Edit email but invalid current password

	Where someone tries to edit email but enters invalid current password

	When I enter valid email which is not already registered
	And I enter invalid current password
	And I click on "Update"
	Then I should see "Current password is invalid"
	And I should be on the edit page
	
	
Scenario: Edit password but invalid current password

	Where someone tries to edit the password but enters invalid current password

	When I enter valid password
	And I enter valid password confirmation
	And I enter invalid current password
	And I click on "Update"
	Then I should see "Current password is invalid"
	And I should be on the edit page
	
	
Scenario: Pasword confirmation is different

	Where someone tries to edit the password but password confirmation is not the same

	When I enter valid password
	And I enter different valid password confirmation
	And I enter my current password
	And I click on "Update"
	Then I should see "Password confirmation doesn't match Password"
	And I should be on the edit page
	

Scenario: New password is too short

	Where someone tries to edit the password but it is too short

	When I enter password with less than 6 characters
	And I enter password confirmation with less than 6 characters
	And I enter my current password
	And I click on "Update"
	Then I should see "Password is too short (minimum is 6 characters)"
	And I should be on the edit page