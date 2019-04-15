Feature: User Log in
	In order to log in
	As a valid user
	I need to fill in log in form and submit.

Background:
	Given I am on the home page
	And I have chosen to log in
	

Scenario: Successful login
  
	Where someone tries to login with valid credentials

	When I enter my email 
	And I enter my password
	And I click on "Sign in"
	Then I should see "Signed in successfully."
	And I should be on the home page
	
	
Scenario: Invalid password
  
	Where someone tries to login with incorrect password

	When I enter my email 
	And I enter invalid password
	And I click on "Sign in"
	Then I should see "Invalid Email or password."
	And I should be on the login page
	

Scenario: Registration does not exist
  
	Where someone tries to login with email which is not registered
  
	When I enter an email which is not registered yet 
	And I enter valid password
	And I click on "Sign in"
	Then I should see "Invalid Email or password."
	And I should be on the login page