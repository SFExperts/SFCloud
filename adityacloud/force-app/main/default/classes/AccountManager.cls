@RestResource(urlMapping='/Accounts/*/contacts')
global class AccountManager {
    @HttpGet
    global static Account getAccount(){
        RestRequest request = RestContext.request;
		List<String> url = (request.requestURI).split('/');
        String accountId = url[url.size()-2];
        Account result  =  [Select Id, Name, 
                            (select Id, Name from Contacts where AccountId =:accountId )
                            from Account where Id =:accountId];
        return result;
    }
}