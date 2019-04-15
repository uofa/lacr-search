Feature: User Log out
	In order to log out
	As a valid user
	I need to be already logged in and click on log out

Scenario: Successful log out
  
	Where someone tries to log out
  
	Given I am logged in as a valid user
	When I click on log out
	Then I should be logged out 
	And I should be on the home page