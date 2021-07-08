public class AccountHandler {
    
    public static Account insertNewAccount(String accountName){
        Account account = new Account(name=accountName);
        try{
        	insert account;
        } catch(DMLException accountException){
            return null;
        }
        return account;        
    }

}