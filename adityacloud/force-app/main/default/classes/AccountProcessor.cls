public with sharing class AccountProcessor {
	@future
    public static void countContacts(List<Id> accountIds){
    	List<Account> accounts = 
        	[Select Id, Number_of_Contacts__c,(select Id from Contacts) from Account where Id in: accountIds];                
        for(Account acc : accounts){
        	integer contactCount = acc.contacts.size();
            acc.Number_of_Contacts__c = contactCount;
        }       
        update accounts;
	}
}