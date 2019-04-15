Feature: User account cancelation
	In order to cancel my account
	As a registered and logged in user
	I need to click on cancel my account on edit page

Background:
	Given I am logged in as a valid user
	And I have chosen to cancel my account
	
@javascript
Scenario: Successful cancelation

	Where someone decided to cancel the account

	When I approve it
	Then I am notified that it is canceled
	And I should be on the home page
	
@javascript
Scenario: Unfinished cancelation

	Where someone tries to cancel the account but rethinks it
	
	When I disapprove it
	Then my account should not be canceled
	And I should be on the edit account page
