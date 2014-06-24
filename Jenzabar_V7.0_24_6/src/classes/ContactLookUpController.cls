global with sharing class ContactLookUpController {
     public Contact contactInst{get;set;}
     public boolean isContent{get;set;}

     public List<String> strList{get;set;}
     public ContactLookUpController(ApexPages.standardController stdController){
          contactInst = (Contact)stdController.getRecord();
          contactInst = getContactDetail(contactInst.id);       
          isContent = true;
        
        strList = new List<String>();
    	strList.add('test1');
    	strList.add('test2');
    	strList.add('test3');
     }  
     private Contact getContactDetail(ID cid){
          Contact contactObj = [Select c.Id, 
                                        c.FirstName, 
                                        c.Class_Status_Code__c, 
                                        c.Citizen_Type__c, 
                                        c.Academic_Standing_Type__c,
                                        c.Institution_Status_Code__c,
                                        Religion_Type__c,
                                        Student_Status_Code__c,
                                        Instructor_Type__c,
                                        Part_Time_Full_Time_Status__c
                                        From Contact c where id =: cid]; 
          system.debug('contactInst--------'+contactObj);      
          return contactObj;                         
     }   
     public PageReference edit(){       
         isContent = false;
         return null;
     } 
     public PageReference cancel(){     
        isContent = true;
        return null;
     } 
     public void doSave(){
         try{
            update contactInst;
            isContent = true;
         }  
         catch(Exception ex){
               system.debug('Exception caught in update----'+ex.getMessage());
         }
     } 
     @RemoteAction
    global static List<String> populateList(String searchText1) {
    	system.debug('---------'+searchText1);
    	List<String> strList = new List<String>();
    	strList.add('test1');
    	strList.add('test2');
    	strList.add('test3');
    	/*
        String JSONString;
        List<Campaign> campaignList = new List<Campaign>();
        List<String> nameList = new List<String>();
        Id recTypeId = GirlRegistrationUtilty.getCampaignRecordTypeId(GirlRegistrationUtilty.VOLUNTEER_PROJECT_RECORDTYPE);

        Savepoint savepoint = Database.setSavepoint();

        try{
            String searchQueri = 'Select ParentId, Name From Campaign Where Name Like \'%'+searchText1+'%\'  and Display_on_Website__c = true and RecordTypeId = \'' + recTypeId + '\' order by Name' ;
            campaignList = database.query(searchQueri);

            if(!campaignList.isEmpty())
                for(Campaign campaign : campaignList)
                    nameList.add(campaign.Name);

            JSONString = JSON.serialize(nameList);
        } catch(System.exception pException) {
            system.debug('pException.getMessage==>'+pException.getMessage());
            //return addErrorMessageAndRollback(savepoint, pException);
        }*/
        return strList;
        
    }
}