public class ContactSearchController {

	public boolean flagErrorMessage  {get;set;}
    public boolean flagContactsListPanel{get; set;}
    public boolean flagContactLinkButton{get; set;}
    public Integer flagDeleteRedirect {get;set;}
    public String nameValue{get; set;}
    public List<Contact> displayList{get; set;}
	public Contact contactVal{get; set;}
	private static final String CONTACT_QUERY = 'SELECT Id, Name, Email, RecordType.Name, FirstName, LastName FROM Contact';
	public String contactRedirectURL{get; set;}
	
    public ContactSearchController(ApexPages.StandardController controller) {
    	contactVal = new Contact();
        flagContactsListPanel = false;
        flagErrorMessage = false;
        flagContactLinkButton = false;
        flagDeleteRedirect = 1;
    }

    
    public PageReference createNew(){
    	
    	PageReference pageRef1 = ApexPages.currentPage();
    	system.debug('The current page URL is: '+pageRef1);
    	contactRedirectURL = Label.ContactRecordTypeURL;
    	return new PageReference(contactRedirectURL);
    
    }

    
    //return all the values from custom settings
    public List<String> editableFields { 
        get {
            if (editableFields == null) {
                List<String> lstString = new List<String>();
                SearchContactFields__c searchFields=SearchContactFields__c.getOrgDefaults() ;
                if(searchFields != null){
                	String strFields='';
                	editableFields = new List<String>();
                	if(searchFields.Contact_Fields__c != null && searchFields.Contact_Fields__c!=''){
                    	strFields = searchFields.Contact_Fields__c;
                    	lstString = strFields.split(',');
		                for(String s:lstString){
		                    editableFields.add(s);
		                }
		               
                	}
                
                }
            }
            system.debug('editableFields********'+editableFields);
            return editableFields ;
        }
        private set;
    }
    
    

    public PageReference doSearch() {
    	try{
    	system.debug('In here of doSearch.....');
    	Map<String, Schema.SObjectField> contactFields = Schema.SObjectType.Contact.fields.getMap();//get all the contact object fields
     	system.debug('In here of doSearch.....');	     
        String query = CONTACT_QUERY;
        String whereCond =' WHERE Name != null';

            for(String editableFieldsIterator : editableFields) {
               
             
                if (contactFields.containsKey(editableFieldsIterator)) {
                    Schema.SObjectField res = contactFields.get(editableFieldsIterator);
                    Schema.DescribeFieldResult f = res.getDescribe();
                    
                    if(contactVal.get(editableFieldsIterator) != null && contactVal.get(editableFieldsIterator) != '') {
                        if(f.getType().name() == 'PHONE' || f.getType().name() == 'TEXT' || f.getType().name() == 'PICKLIST' || f.getType().name() == 'EMAIL' || f.getType().name() == 'STRING' || f.getType().name() == 'TEXTAREA' || f.getType().name() == 'URL') {
                        	system.debug('In here of Name.....');	
                            whereCond += ' AND ' + editableFieldsIterator + ' = \'' + contactVal.get(editableFieldsIterator) + '\'';
                        }  else if (f.getType().name() == 'DATE') {
                            whereCond += ' AND ' + editableFieldsIterator + ' = ' + string.valueof(contactVal.get(editableFieldsIterator)).substring(0,10);
                        } else if(f.getType().name() == 'DATETIME') {
                            whereCond += ' AND ' + editableFieldsIterator + ' = \'' +datetime.now()+'\'';
                        } else if (f.getType().name() == 'BOOLEAN' || f.getType().name() == 'CURRENCY' || f.getType().name() == 'DOUBLE' || f.getType().name() == 'INTEGER' || f.getType().name() == 'PERCENT') {
                            whereCond += ' AND ' + editableFieldsIterator + ' = ' + contactVal.get(editableFieldsIterator);     
                        }else if ((f.getType().name() == 'REFERENCE')){
                            whereCond += ' AND ' + editableFieldsIterator + ' =  \''+ contactVal.get(editableFieldsIterator)+'\'';
                        }
                    }
                }
                
            }
            system.debug('<<>>finalquery'+string.escapeSingleQuotes(query + whereCond));
            displayList = new list<Contact>();
            if(nameValue!=null && !nameValue.equals('')){
			 whereCond = whereCond+' AND Name LIKE \''+'%'+nameValue+'%\'';
			 displayList = dataBase.query(query + whereCond);
            }
            else{
            displayList = dataBase.query(query + whereCond);
            
            }
            if(displayList.size()>0){
            flagContactLinkButton = true;
    		flagErrorMessage = true;
    		flagContactsListPanel = false;
            }
            
            else{
    		flagContactsListPanel = true;
    		flagErrorMessage = false;
    		}
	 
    }
    catch(Exception ex){
    	
    }
     system.debug('displayList'+displayList);
	  return null;
    }
    
}