public class SearchComponentController {
    private Map<String,Contact_Link_RecordType__c> contactRecordTypeMapNew;
    public List<Contact> contactList{get; set;}
    public String radioButtonId{get; set;}
    public Integer flag {get;set;}
    public String nameValue{get; set;}
    
    public List<Contact> contactSearchResult{get; set;}
    public Contact con{get; set;}   
    public String contactRedirectURL{get; set;}
    public string currContactId;
    public List<Contact> contctList;
    public boolean isSearchBlock{get;set;}
    public boolean isSearchResult{get;set;}
    public boolean isNoSearchResult{get;set;}
    
    public List<Contact> contactListMatchedVales{get;set;}
    public boolean isMatchingContact{get;set;}
    public boolean isSearchParam;
    public boolean isComponentLoad{get;set;}
    public String cntctId{get; set;}
    public String recordTypeName{get; set;}
    public String contactLinkName{get; set;}
    
    public List<String> searchFields{get;set;}
    public List<Contact_Link__c> contactLinkList;
   
    Map<String,Contact_Link_RecordType__c> contactRecordTypeMap;
    List<Contact> contacts_LinksValuesNew;
    
    /**
     *Search component constructor
     */
    public SearchComponentController() {
        con = new Contact();
        isComponentLoad = true;
        flag = 1;        
        getSearchableFields();
        isSearchParam = false;
        //Get all record type configured in custom setting
        contactRecordTypeMap = Contact_Link_RecordType__c.getAll();
    }
   /**
    * Settor method to initialize component variables
    * It will accept source contactId if it loads from "Link Contacts" Button on Contact detail page else argument will be null.
    */
    public void setcurrContactId(string ctId){
        currContactId = ctid;
        if(currContactId == null){ //Search component loads from "Contact Link/Search" List button.       	
            isSearchBlock = isComponentLoad = true;
        }
        else{ 
            isSearchBlock= false;
            contctList = new List<Contact>([select id, Name, Email,FirstName,LastName,Phone,RecordTypeId, RecordType.Name from Contact where Id = :currContactId]);
            if(contctList != null && contctList.size()>0){
	            List<String> tempRecordTypeList = new List<String>();
	            for(String rt: contactRecordTypeMap.keySet()){
	                 if(rt != contctList[0].RecordType.Name){
	                      tempRecordTypeList.add(rt);
	                 }
	            }
	            getCopyContactLinksList(currContactId); 
	            Map<Id,Contact> contactMap;
	            //If search param is true, it should not refresh contact search result.
	            if(isSearchParam == false){ 
	                  contactMap = new Map<Id,Contact>([select Id, Name, Email, RecordType.Name from Contact where Name=:contctList[0].Name AND Email=:contctList[0].Email AND RecordType.Name IN : tempRecordTypeList]);
	            }
	            //Remove contact records which are already associated in contact link
	            if(contactMap != null && !contactMap.isEmpty()){
	                if(contactLinkList != null && contactLinkList.size()>0){
	                    for(String recordTypeName : contactRecordTypeMap.keySet()){                                     
	                          if(contactRecordTypeMap.get(recordTypeName) != null && contactLinkList[0].get(contactRecordTypeMap.get(recordTypeName).Contact_Link_FieldName__c) != null){
	                                contactMap.remove((Id)(contactLinkList[0].get(contactRecordTypeMap.get(recordTypeName).Contact_Link_FieldName__c)));
	                          }                      
	                    }
	                }
                    contactListMatchedVales = new List<Contact>();  
                    contactListMatchedVales.addAll(contactMap.values());
	            }
	           if(contactListMatchedVales!= null && contactListMatchedVales.size()>0){
	                 isMatchingContact = true;
	           }
	           else{
	               isMatchingContact = false;
	           }
	        }
	        else{
	        	isComponentLoad = false;
	        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.label.Source_Contact_Deletion_Message)); 
	        }
        }
    }
    /**
     * Getter method for currContactId
     */
    public String getcurrContactId(){
         return currContactId;
    }
    /**
     * Method to get associated contact link records based on source contactId.
     * This will be called if component loads from "Link Contacts" button.
     */
    private void getCopyContactLinksList (String sourceContactId){
          contactLinkList = new List<Contact_Link__c>();
          contactLinkList = prepareDynamicSoql(sourceContactId);
    }
    /**
     * Method to perform dynamic query to fetch all contact link records exists for source contact record.
     * Return fetched contact link records to caller method.
     */
    private List<Contact_Link__c> prepareDynamicSoql(String contactId){
         List<Contact_Link__c> tempContactLinkList = new List<Contact_Link__c>();
         String fieldsAPI = '';
         String whereClause = '';
         for(Contact_Link_RecordType__c ct : contactRecordTypeMap.values()){
              fieldsAPI = fieldsAPI +', '+ct.Contact_Link_FieldName__c+','+ct.Contact_Link_FieldName__c.replace('__c','__r.Name');
              whereClause = whereClause + ct.Contact_Link_FieldName__c+ ' =:contactId' + ' OR ';             
                                      
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
    /**
     * Method to redirect on contact edit page on click of "Create New Contact" on search page.
     */
    public PageReference createNew(){
        PageReference pageRef1 = ApexPages.currentPage();
        contactRedirectURL = Label.ContactRecordTypeURL;
        return new PageReference(contactRedirectURL);
    }
   /**
    * Method catch contact id of selected contact on search page.
    * Contact gets selected by click of radio button.
    */
    public void next(){
        radioButtonId = apexpages.currentPage().getParameters().get('selected');
    }
    /**
    * Method to fetch all search fields API name configured in custom setting.
    */
    public void getSearchableFields() { 
         
        Set<String> setStrList = new set<String>();
        List<String> tempSearchFieldList = new List<String>();
        searchFields = new List<String>();        
        SearchContactFields__c searchFieldsSetting = SearchContactFields__c.getOrgDefaults() ;
        if(searchFieldsSetting != null){
            searchFields = new List<String>();
            if(searchFieldsSetting.Contact_Fields__c != null && searchFieldsSetting.Contact_Fields__c != ''){
                tempSearchFieldList = searchFieldsSetting.Contact_Fields__c.split(',');
                for(String s : tempSearchFieldList){
                     if(setStrList.add(s)){    //To remove duplicate fields name configured in custom setting.
			             searchFields.add(s);
			        }
                }
            }
        } 
    }
    /**
    * Method to search contact based on search fields on page.
    * Search results would be different for search and link button.
    * If loads from Link button, it will filter those contacts whose contact association already exists in contact link record of source contact.
    */
    public PageReference doSearch() {
        contactSearchResult = new list<Contact>();
        Map<Id,Contact> tempContactMap = new Map<Id,Contact>();
        string whereCond = ' WHERE ';
        
        try{
            Map<String, Schema.SObjectField> contactFieldMap = Schema.SObjectType.Contact.fields.getMap();       
            String query = 'Select id, ';
            for(String s : searchFields) {
                if (contactFieldMap.containsKey(s)) {
                	if(!s.toLowerCase().contains('name')){
                        query = query + s+', ';
                	}
                    Schema.DescribeFieldResult f = contactFieldMap.get(s).getDescribe();//Describe field 
                    if(con.get(s) != null && con.get(s) != '') {
                        if(con.get(s) != null && con.get(s) != '' && con.get(s) != false) {
							if(f.getType().name() == 'PHONE' || f.getType().name() == 'TEXT' || f.getType().name() == 'PICKLIST' || f.getType().name() == 'EMAIL' || f.getType().name() == 'STRING' || f.getType().name() == 'TEXTAREA' || f.getType().name() == 'URL') {
								whereCond += s + ' = \'' + con.get(s) + '\''+' AND ';
							} else if (f.getType().name() == 'MULTIPICKLIST') {
								String multipicStr = String.valueof(con.get(s));
								if(multipicStr.contains(';')){
									String str = '\'' +','+'\'';
									multipicStr = multipicStr.replace(';',str);
									whereCond += s + ' includes (\'' + multipicStr + '\')'+' AND '; 
								}else{
									whereCond += s + ' includes (\'' + con.get(s) + '\')'+' AND '; 
								}
							} else if (f.getType().name() == 'DATE') {
								whereCond += s + ' = ' + string.valueof(con.get(s)).substring(0,10)+' AND ';
							} else if(f.getType().name() == 'DATETIME') {
								//whereCond += s + ' = \'' +datetime.now()+'\''+' AND ';
								Datetime createdDateTime = (Datetime)con.get(s);
								String dateTimeFormat = createdDateTime.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
								system.debug('Date time param ------'+dateTimeFormat);
								whereCond += s + ' = ' +dateTimeFormat+' AND ';
							} else if (f.getType().name() == 'BOOLEAN' || f.getType().name() == 'CURRENCY' || f.getType().name() == 'DOUBLE' || f.getType().name() == 'INTEGER' || f.getType().name() == 'PERCENT') {
								whereCond += s + ' = ' + con.get(s)+' AND ';     
							}else if ((f.getType().name() == 'REFERENCE')){
								whereCond += s + ' =  \''+ con.get(s)+'\''+' AND ';
							}
						}
                    }
                }
                isSearchParam = true;
            }
            
            if(!(query.contains('Email') || query.contains('email'))){
            	 query = query + 'Email, ';
            }
            query = query +'Name, '+ 'RecordType.Name';
            query = query+' From Contact';
           
            if(nameValue != null && !nameValue.equals('')){
                 whereCond = whereCond+' Name LIKE \''+'%'+nameValue+'%\'';   
            }
            else{
                whereCond = whereCond.subString(0,whereCond.length()-4);
            }
            contactSearchResult = dataBase.query(query + whereCond); //Query contact based on dynamic soql string
            if(contactSearchResult != null && contactSearchResult.size()>0){
                 isSearchResult = true;
                 isNoSearchResult = false;
                 for(Contact ct : contactSearchResult){
                	   tempContactMap.put(ct.id,ct);
                 }
            }
            else{
                 isSearchResult = false;
                 isNoSearchResult = true;
            }
            contactListMatchedVales = new List<Contact>();
            if(currContactId != null){
                if(tempContactMap != null && !tempContactMap.isEmpty()){
                    if(contactLinkList != null && contactLinkList.size()>0){
                        for(String recordTypeName : contactRecordTypeMap.keySet()){                                     
                            if(contactRecordTypeMap.get(recordTypeName) != null && contactLinkList[0].get(contactRecordTypeMap.get(recordTypeName).Contact_Link_FieldName__c) != null){
                                 tempContactMap.remove((Id)(contactLinkList[0].get(contactRecordTypeMap.get(recordTypeName).Contact_Link_FieldName__c)));
                            }                      
                        }
                    }
                    contactListMatchedVales.addAll(tempContactMap.values());
                }
                if(contactListMatchedVales !=null && contactListMatchedVales.size()>0){
                     isMatchingContact = true;
                }
                else{
                     isMatchingContact = false;
                }
            }
        }
        catch(Exception ex){}
        return null;
    }
    /**
    * Helper Method of updateContactLink() to remove contact record from "Related Contact Section" once contact is linked.
    */
    private void updateContactListMatchedVales(){
         for(Integer i =0 ; i<contactListMatchedVales.size();i++){
               if(contactListMatchedVales[i].id == cntctId){
                     contactListMatchedVales.remove(i);
               }
         }
         if(contactListMatchedVales.size()> 0){
              isMatchingContact = true;
         }
         else{
             isMatchingContact = false;
         }
    }
    /**
    * Helper Method of createLink() to update contact link record.
    * If Record type already exists in contact link record, it will throw message.
    */
    private String updateContactLink(List<Contact_Link__c> tempContactLinkList,String recordTypeName,String contactID){
        String errorMsg;
        for(Contact_Link_RecordType__c cLinkRtypeObj : contactRecordTypeMap.values()){
             if(recordTypeName == cLinkRtypeObj.Name){
                  if(contactRecordTypeMap.get(recordTypeName) != null){
                        if(tempContactLinkList[0].get(contactRecordTypeMap.get(recordTypeName).Contact_Link_FieldName__c) == null){
                            tempContactLinkList[0].put(contactRecordTypeMap.get(recordTypeName).Contact_Link_FieldName__c,contactID);
                        }
                        else{
                            errorMsg = 'There already exists an association for '+ recordTypeName+', please remove the existing link before creating New.';
                        }
                  }       
             }
        }   
        try{
             if(errorMsg == null){
                 update tempContactLinkList;  
                 updateContactListMatchedVales();                
             }
        }
        catch(Exception ex){
             errorMsg = ex.getMessage();
        }
        return errorMsg;
    }
   /**
    * Method to create link/update contact link record.
    * If record type is not present in contact link record, it will update contact link record with target contact record type
    * Else it will create new contact link record with source contact and contact to which link is clicked.
    */
    public void createLink(){
        String errorMsg;
        List<Contact_Link__c> tempContactLinkList = prepareDynamicSoql(cntctId);
        if(recordTypeName !=null && contactLinkList != null && contactLinkList.size()>0){
                  if(tempContactLinkList == null || tempContactLinkList.size()== 0){
                        errorMsg = updateContactLink(contactLinkList,recordTypeName,cntctId);                       
                  }
                  else{
                       for(Contact_Link_RecordType__c cLinkRtypeObj : contactRecordTypeMap.values()){
                             if(recordTypeName == cLinkRtypeObj.Name){
                                  if(contactRecordTypeMap.get(recordTypeName) != null && tempContactLinkList[0].get(contactRecordTypeMap.get(recordTypeName).Contact_Link_FieldName__c) != null){
                                        errorMsg = System.Label.Duplicate_Contact_Link_Association_Message;
                                  }    
                             }
                       }
                  }
                  if(errorMsg != null){
                       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMsg));                   
                  }
        }      
        else if(contctList[0].RecordType.Name != null && tempContactLinkList != null && tempContactLinkList.size()>0){
             
             errorMsg = updateContactLink(tempContactLinkList,contctList[0].RecordType.Name,CurrContactId);
             if(errorMsg != null){
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.Duplicate_Contact_Link_Association_Message));
             }
        }                                                      
        else{                 
             Contact_Link__c contactLinkObj = new Contact_Link__c();
             for(Contact_Link_RecordType__c cLinkRtypeObj : contactRecordTypeMap.values()){
                 if(contctList[0].RecordType.Name == cLinkRtypeObj.Name){
                       contactLinkObj.put(cLinkRtypeObj.Contact_Link_FieldName__c,contctList[0].id);   
                 }
                 if(recordTypeName == cLinkRtypeObj.Name){
                      if(contactRecordTypeMap.get(recordTypeName) != null){
                            contactLinkObj.put(contactRecordTypeMap.get(recordTypeName).Contact_Link_FieldName__c,cntctId);
                      }       
                 }
              }
              try{
                   insert contactLinkObj;
                   updateContactListMatchedVales();
              }
              catch(Exception ex){
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage())); 
              }
          }          
    }   
}