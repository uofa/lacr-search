Feature: User registration
	In order to register on the web page
	As a new user
	I need to complete and send registration form

Background:
	Given I am on the home page
	And I have chosen to register
	

Scenario: Successful registration

	New user should be able to register easily.

	When I enter valid details
	And I click on "Sign up"
	Then I should see "Welcome! You have signed up successfully."
	

Scenario: Duplicate email

	Where someone tries to create an account for an email address 
	that already exists.

	When I enter an email address that has already registered
	And I click on "Sign up" 
	Then I should see "Email has already been taken"
	And I should see the option to recovery my password
	And I should be on the registration page
	

Scenario: Invalid email address

	Where someone tries to register with an invalid email address.

	When I enter an invalid email address
	And I enter valid password
	And I enter valid password confirmation
	And I click on "Sign up"
	Then I should see "Email is invalid"
	And I should be on the registration page
	

Scenario: Password confirmation does not match

	Where someone tries to register with different password and password confirmation

	When I enter valid email address
	And I enter valid password
	And I enter different password confirmation
	And I click on "Sign up"
	Then I should see "Password confirmation doesn't match Password"
	And I should be on the registration page
	

Scenario: Password is too short

	Where someone tries to register with short password

	When I enter valid email address
	And I enter short password with less than 6 characters
	And I enter short password confirmation with less than 6 characters
	And I click on "Sign up"
	Then I should see "Password is too short (minimum is 6 characters)"
	And I should be on the registration page