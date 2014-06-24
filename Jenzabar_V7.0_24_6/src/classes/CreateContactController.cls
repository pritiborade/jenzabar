public with sharing class CreateContactController {
	
	  private static final String CONTACT_APINAME = 'Contact';
      private static final String RECORDTYPE_APINAME = 'recordTypeId';
      private static final String LASTNAME_APINAME = 'LastName';
      private static final String FIRSTNAME_APINAME = 'FirstName';
      
      private Contact contactSObj;
      private List<String> commonFields;
      private List<Contact_Link__c> contactLinkList;
      private Map<String,RecordType> recordTypeMap;
      private Map<String,Contact_Link_RecordType__c> contactRecordTypeMap;
      private Map<String, Schema.SObjectField> fieldsMap;
      
      public Contact newContactSobj{get;set;}
      public String selectedRecordTypeName{get;set;}
      public String errorMessage{get;set;}
      public String errorLevel {get; set;}
      public String messageName {get; set;}
      public String mode{get;set;}
      public List<SelectOption> recordTypeOptions{get;set;}
      public boolean isPickListShow{get;set;}
      
      public CreateContactController(){
      	   newContactSobj = new Contact();   
      	   contactLinkList = new List<Contact_Link__c>();
      	   mode = ApexPages.currentPage().getParameters().get('mode');
      	   String contactId = ApexPages.currentPage().getParameters().get('cId'); 
      	   fieldsMap = new Map<String, Schema.SObjectField>();        
      	   fieldsMap = Schema.SObjectType.Contact.fields.getMap(); 
		   String soql = 'Select ';
		   for(String s : fieldsMap.keySet()){
			     soql = soql + s +', ';
		   }
		   soql = soql + 'recordType.Name';
		   soql = soql + ' FROM Contact WHERE ' + 'id=:contactId '; 			
		   contactSObj = Database.query(soql);
      	   getContactRecordTypes();                
      }
     /**
      * Method to get all record type options other than those whose contact link association record present based on source contact.
      */
      private void getContactRecordTypes(){
      	   recordTypeOptions = new List<SelectOption>();
      	   recordTypeMap = new Map<String, RecordType>();
      	   //Get all record type configured in custom setting
      	   contactRecordTypeMap = Contact_Link_RecordType__c.getAll(); 
		   String fieldsAPI = '';
		   String whereClause = '';
		   String contactId = contactSObj.id;	
		   //Creating dynmic SOQL to fetch contact link record having source contact id in any of its field.
		   for(Contact_Link_RecordType__c ct : contactRecordTypeMap.values()){
		        fieldsAPI = fieldsAPI +', '+ct.Contact_Link_FieldName__c;
		        whereClause = whereClause + ct.Contact_Link_FieldName__c+ ' =: contactId' + ' OR ';
		   }
      	   whereClause = whereClause.subString(0,whereClause.length()-3);
		   String soql = 'Select id, Name '+fieldsAPI+' From Contact_Link__c where '+whereClause ;
		   contactLinkList = Database.query(soql);
           List<RecordType> recordTypeList = [Select r.Name,r.Id,r.SobjectType, r.IsActive, 
  	                                                 r.DeveloperName From RecordType r 
  	                                                 where sObjectType =: CONTACT_APINAME and 
  	                                                 isActive= true];
  	       for(RecordType rt : recordTypeList){
  	       	    recordTypeMap.put(rt.Name,rt);
  	       }                                          
           for(Contact_Link_RecordType__c cLinkRtypeObj : contactRecordTypeMap.values()){
           	    if(cLinkRtypeObj.Name != contactSObj.recordType.Name){
	           	    if(contactLinkList != null && contactLinkList.size()>0){
		           	    if(contactLinkList[0].get(cLinkRtypeObj.Contact_Link_FieldName__c)==null){
		           	    	 recordTypeOptions.add(new SelectOption(cLinkRtypeObj.Name,cLinkRtypeObj.Name));
		           	    }
	           	    }
	           	    else{
	           	    	 recordTypeOptions.add(new SelectOption(cLinkRtypeObj.Name,cLinkRtypeObj.Name));
	           	    }
           	    }
           }
  	       if(recordTypeOptions != null && recordTypeOptions.size()>0){
  	       	     isPickListShow = true;
  	       }
  	       else{ 	       	    
  	       	    isPickListShow = false;
  	       	    errorMessage = System.label.Duplicate_Contact_Association_Message+'<a href=/'+contactLinkList[0].id +' TARGET="_blank" onClick = "javascript:window.close();"><font size="2" color="blue">'+contactLinkList[0].Name+'</font></a>';
  	            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, errorMessage));
  	       }
      }
    /**
     * Method to prepare list of contact common fields configured in custom setting.
     */
      private void fetchCommonFields(){
      	    ContactInsertFieldSetting__c contactCS = ContactInsertFieldSetting__c.getValues(CONTACT_APINAME);
      	    commonFields = new List<String>(); 
      	    if(contactCS != null){
			     if(contactCS.Common_Fields__c.contains('\n')){
			     	  commonFields = contactCS.Common_Fields__c.split('\n');
			     }
			     else{
			     	  commonFields = contactCS.Common_Fields__c.split(',');
			     }
      	    }
      }
     /**
      *Method to populate contact common fields from source contact record while creating new contact.
      */
      private void populateCommonFields(){
      	    fetchCommonFields();
      	    newContactSobj.put(LASTNAME_APINAME,String.valueOf(contactSObj.get(LASTNAME_APINAME)));
      	    newContactSobj.put(FIRSTNAME_APINAME,String.valueOf(contactSObj.get(FIRSTNAME_APINAME)));
      	    if(recordTypeMap.get(selectedRecordTypeName) != null){
      	    	newContactSobj.put(RECORDTYPE_APINAME,recordTypeMap.get(selectedRecordTypeName).id);
      	    }
      	    Map <String, String> labelToAPIName = new Map <String, String> ();
			//Map<String, Schema.SObjectField> fieldsMap = Schema.SObjectType.Contact.fields.getMap();
			for (Schema.SObjectField field : fieldsMap.values()){
			    labelToAPIName.put(field.getDescribe().getLabel(), field.getDescribe().getName());
			}
      	    for(String fieldAPIName : commonFields){
      	    	  Schema.Sobjectfield field = fieldsMap.get(fieldAPIName);   
      	    	  if(field!= null){  	  
	                  Schema.Describefieldresult fieldDesc = field.getDescribe();
	                  Schema.DisplayType fldType = fieldDesc.getType();
	                  newContactSobj.put(fieldAPIName,contactSObj.get(fieldAPIName));
      	    	  }
      	    }  
      }
      /**
       * Method to create contact and link it in contact link table with source contact id and newly created contact id.
       */ 
      public void createContact(){
      	    populateCommonFields();
      	    Contact_Link__c contactLinkInst = new Contact_Link__c();
      	    PageReference recordDetailPage = null;
      	    
      	    Savepoint sp = Database.setSavepoint(); // If contact link is not created, it should roll back to contact record also
      	    try{      	    
      	        insert newContactSobj;     	        
      	        if(contactLinkList == null || contactLinkList.size() == 0){
      	        	 for(Contact_Link_RecordType__c cLinkRtypeObj : contactRecordTypeMap.values()){
					     if(contactSObj.RecordType.Name == cLinkRtypeObj.Name){
						       contactLinkInst.put(cLinkRtypeObj.Contact_Link_FieldName__c,contactSObj.id);   
						 }
						 if(selectedRecordTypeName == cLinkRtypeObj.Name){
						      if(contactRecordTypeMap.get(selectedRecordTypeName) != null){
									contactLinkInst.put(contactRecordTypeMap.get(selectedRecordTypeName).Contact_Link_FieldName__c,newContactSobj.id);
					          }		  
						 }
					 }
      	        	 insert contactLinkInst;
      	        }
      	        else{ 
      	        	 for(Contact_Link_RecordType__c cLinkRtypeObj : contactRecordTypeMap.values()){
						 if(selectedRecordTypeName == cLinkRtypeObj.Name){
						      if(contactRecordTypeMap.get(selectedRecordTypeName) != null){
							        if(contactLinkList[0].get(contactRecordTypeMap.get(selectedRecordTypeName).Contact_Link_FieldName__c) == null){
									    contactLinkList[0].put(contactRecordTypeMap.get(selectedRecordTypeName).Contact_Link_FieldName__c,newContactSobj.id);
									}
									else{
									    errorMessage = 'There already exists an association for'+ selectedRecordTypeName+', please remove the existing link before creating New.';
									}
					          }		  
						 }
					 }	
      	        	 if(errorMessage == null){
      	        	      update contactLinkList[0];      	        	      
      	        	 }
      	        	 else{
      	        	 	 isPickListShow = false; 
      	        	 	 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));
      	        	 }
      	        }
      	    }
      	    catch(Exception ex){
                 errorMessage = ex.getMessage();
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));
                 Database.rollback(sp);
      	    }
      } 
      /**
       * Method to show standard error message using javascript 
       */ 
      public void showMessage() {
		  if(errorLevel == 'ERROR') {
		       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, messageName));
	      }
      }
}