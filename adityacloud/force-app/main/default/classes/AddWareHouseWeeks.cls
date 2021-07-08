global class AddWareHouseWeeks implements Database.Batchable<warehouse_week__c> {
    
    global Iterable<warehouse_week__c> start(Database.BatchableContext bc) {
        //Current Year
        FiscalYear fiscalYear = new FiscalYear(Date.today().year(), Date.today().year()+1);
        // Previous year
        //FiscalYear fiscalYear = new FiscalYear(Date.today().year()-1, Date.today().year());
        return this.makeListWeeks(fiscalYear);
    }
    
    global void execute(Database.BatchableContext bc, List<Warehouse_Week__c> scope){
        upsert scope Name;
		// For each warehouse - create capacityweeks for all weeks. 
		List<warehousecapacity__c> wcapacityList = new List<warehousecapacity__c>();
        List<warehouse__c> warehouses = [select Id,Name from warehouse__c];
        for(warehouse__c warehouse: warehouses){
            for(Warehouse_Week__c week: scope){
                wcapacityList.add(newcapacity(warehouse, week,0,warehouse.name + '-' + week.name ));
            }
        }
        system.debug('wcapacityList size' + wcapacityList.size());
        system.debug('wcapacityList: ' + wcapacityList);
        upsert wcapacityList;        
    }

    private warehousecapacity__c newcapacity(final warehouse__c warehouse, final warehouse_week__c week, final double capvalue, final string name){
        warehousecapacity__c wcapacity = new warehousecapacity__c();
        wcapacity.warehouse__c 			= warehouse.Id;
        wcapacity.Warehouseweek__c 		= week.Id;
        wcapacity.capacity__c 			= capvalue;
        wcapacity.name  				= name;
        return wcapacity;
    }    
    
    global void finish(Database.BatchableContext bc){        
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
                            JobItemsProcessed,
                            TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()];        
    }    
    
    // Returns a list of warehouseweeks for a fiscal year.
    private List<Warehouse_Week__c> makeListWeeks(FiscalYear fiscalYear){
        print('in makeListWeeks');
        // Get start date of fiscal year.
        Date fy_april01 = Date.newInstance(fiscalYear.fromYear, 4,1);
        Date fy_fromDate = fy_april01.toStartOfWeek(); 
        
        // Get end date of fiscal year. april01
        Date nfy_startDate =  Date.newInstance(fiscalYear.toYear, 4,1);
        
        // Current year's last date = Start of next fiscal year's first week -(minus) 1 day.
        Date fy_LastDate = nfy_startDate.toStartOfWeek() -1;  
        
        Date  dateCursor = fy_fromDate;
        
        List<Warehouse_Week__c> listWeeks =  new List<Warehouse_Week__c>();
        integer position_Week =  1;
        
        do {
            listWeeks.add(newWeek(dateCursor, position_Week,fiscalYear,getquarter(dateCursor)));                      
            dateCursor = dateCursor.addDays(7);
            position_Week++;
        } while(dateCursor < fy_LastDate);            
        
        return listWeeks;
    }
    
    double  getquarter(final Date weekstartdate ){
        Date localdate	= Date.newInstance(weekstartdate.year(), weekstartdate.month(), weekstartdate.day());
        integer month 	= (localdate.addDays(7)).month();
        double session 	= 1;
        switch on month {
        	when 1,2,3,4,5,6 	{ session = 1;}
            when 7,8,9,10,11,12 { session = 2;}
        }
        return session;
    }
    
	/* Position: Week's number in a year - from 1- 52.
	 */    
    private Warehouse_Week__c newWeek(Date weekstartDate, integer position, FiscalYear fiscalYear, double quarter ){
        Warehouse_Week__c newWeek  = new Warehouse_Week__c();
	    newWeek.Name = monthInEnglish(weekstartDate.month()) + weekstartdate.day() + '/' + position;
        newWeek.Fiscal_Year_Start__c = fiscalYear.fromYear;
        newWeek.Fiscal_Year_End__c = fiscalYear.toYear;
        newWeek.position__c = position;
        newWeek.quarter__c = quarter;
        newWeek.weekstartdate__c =  weekstartDate;
        
        return newWeek;          
    }    
    private void print(string message){
        system.debug(message);
    }    
    
    private string monthInEnglish(integer month){
        string str_month = '';
        switch on month{
            when 1 {str_month = 'Jan';}
            when 2 {str_month = 'Feb';}
            when 3 {str_month = 'March';}
            when 4 {str_month = 'April';}
            when 5 {str_month = 'May';}
            when 6 {str_month = 'Jun';}
            when 7 {str_month = 'Jul';}
            when 8 {str_month = 'Aug';}
            when 9 {str_month = 'Sep';}
            when 10 {str_month = 'Oct';}
            when 11 {str_month = 'Nov';}
            when 12 {str_month = 'Dec';}
            when else {str_month = 'DEFAULT'; }
        }
        return str_month;
    }
}