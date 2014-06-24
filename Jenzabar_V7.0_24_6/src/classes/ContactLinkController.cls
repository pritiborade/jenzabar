public with sharing class ContactLinkController {
	
    private static final String CONTACT_APINAME = 'Contact';
    public String baseUrl{get;set;}
    public Id sourceContactId{get;set;}
    public List<Contact_Link__c> contactLinkList{get;set;}
    public boolean isContactLinkTable{get; set;}
    
    Map<String,Contact_Link_RecordType__c> contactRecordTypeMap;
    public List<String> relationShipName{get;set;}
    
    public ContactLinkController(ApexPages.StandardController controller) {
    	
        sourceContactId = ApexPages.currentPage().getparameters().get('id');
        baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        contactRecordTypeMap = Contact_Link_RecordType__c.getAll();//Get all record type configured in custom setting
        if(sourceContactId != null){
        	 sourceContactId = String.escapeSingleQuotes(sourceContactId);
             getCopyContactLinksList(); 
        }
    }
    /**
    * Method to send back on source contact detail page on click of "Back" link.
    */
    public PageReference goBack(){
          return new PageReference('/'+sourceContactId);
    }
    /**
     * Method to get associated contact link records based on source contactId.
     * This will be called if component loads from "Link Contacts" button.
     */
    public void getCopyContactLinksList (){
    	  contactLinkList = new List<Contact_Link__c>();
		  contactLinkList = performDynamicSoql(sourceContactId);
    	  if(contactLinkList != null && contactLinkList.size()>0){
        	  isContactLinkTable = true;
          } 
          else{
          	  isContactLinkTable = false;
          }	
    }
     /**
     * Method to perform dynamic query to fetch all contact link records exists for source contact record.
     * Return fetched contact link records to caller method.
     */
    private List<Contact_Link__c> performDynamicSoql(String contactId){
    	 List<Contact_Link__c> tempContactLinkList = new List<Contact_Link__c>();
    	 String fieldsAPI = '';
	     String whereClause = '';
	     Schema.DescribeSObjectResult R = Contact.SObjectType.getDescribe();
		 relationShipName = new List<String>();
                  
	     for(Contact_Link_RecordType__c ct : contactRecordTypeMap.values()){
	          fieldsAPI = fieldsAPI +', '+ct.Contact_Link_FieldName__c+','+ct.Contact_Link_FieldName__c.replace('__c','__r.Name');
	          whereClause = whereClause + ct.Contact_Link_FieldName__c+ ' =:contactId' + ' OR ';	         
	          relationShipName.add(ct.Contact_Link_FieldName__c);	          	          
	     }
  	     whereClause = whereClause.subString(0,whereClause.length()-3);	 
	     String soql = 'Select id,Name '+fieldsAPI+' From Contact_Link__c where '+whereClause ;
	     try{
              tempContactLinkList = Database.query(soql);
         }
         catch(Exception ex){
         	  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage())); 
         }
	     return tempContactLinkList;
    }
}