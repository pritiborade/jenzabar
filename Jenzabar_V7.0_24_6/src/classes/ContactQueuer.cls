public with sharing class ContactQueuer implements BaseInterface{

	@future
    public static void execute(Id eventId){
        
        String conIdUpdated;
        Set<String> conIdstoUpdate = new Set<String>();
        Map<id,List<Id>> mapIdstoUpdate = new Map<Id,List<Id>>();
        List<String> fieldStrings = new List<String>();
        Map<Id,Contact> contoUpdates = new Map<Id,Contact>();
        String queryStrForAll;
        List<Contact> conObj;
        for(Event__c eventItr : [SELECT id,
                                        Content_JSON__c 
                                        FROM Event__c 
                                  		WHERE Id =: eventid LIMIT 1]){
        	conIdUpdated = ContactQueuer.parseAndGetId(String.valueOf(eventItr.Content_JSON__c));
        }
        
        String queryString = 'SELECT Id,';
        
        for(Contact_Link_RecordType__c cLinkSetItr : Contact_Link_RecordType__c.getAll().values()){
        	queryString += cLinkSetItr.Contact_Link_FieldName__c + ',';
        }
        
        queryString = queryString.subString(0, queryString.length() - 1);
        queryString += ' FROM Contact_Link__c WHERE ';
        
        for(Contact_Link_RecordType__c cLinkSetItr : Contact_Link_RecordType__c.getAll().values()){
        	queryString += cLinkSetItr.Contact_Link_FieldName__c + '=:conIdUpdated' + ' OR ';
        }
        
        queryString = queryString.subString(0, queryString.length() - 4);
       
        
        for(Contact_Link__c cLinkItr : Database.query(queryString)){
        	
        	for(Contact_Link_RecordType__c cLinkSetItr : Contact_Link_RecordType__c.getAll().values()){
        		if(cLinkItr.get(cLinkSetItr.Contact_Link_FieldName__c) != conIdUpdated &&
        		   cLinkItr.get(cLinkSetItr.Contact_Link_FieldName__c) != null){
        			
        			conIdstoUpdate.add(String.valueOf(cLinkItr.get(cLinkSetItr.Contact_Link_FieldName__c)));
        		}
        	}
        
        }
        
        if(!String.isBlank(conIdUpdated)){
        	queryStrForAll = getQuery() + ' WHERE id=:conIdUpdated LIMIT 1';
        	
    	}
        if(!conIdstoUpdate.isEmpty()){
	        conObj = new List<Contact>(); 
	        if(!String.isBlank(queryStrForAll)){
	        	conObj = Database.Query(queryStrforAll);
	        } 
	       
        }
        
        if(!conIdstoUpdate.isEmpty()){
	        for(Contact conObjItr : [SELECT id FROM Contact WHERE Id IN: conIdstoUpdate]){
	        	for(String StringItr : (TriggerSetting__c.getAll().get('Contact').Common_Fields__c).replaceAll( '\\s+', '').split(',')){
	        		conObjItr.put(StringItr,conObj[0].get(StringItr));
	        	}
	        	contoUpdates.put(conObjItr.id,conObjItr);
	        }
        }
        
        if(!contoUpdates.isEmpty()){
        	update contoUpdates.values();
        }
    } 
    
    public static String getQuery(){
        If(!String.isEmpty(TriggerSetting__c.getAll().get('Contact').Common_Fields__c)){
            return 'SELECT Id,'+TriggerSetting__c.getAll().get('Contact').Common_Fields__c+' FROM Contact ';
        }
        return 'SELECT Id FROM Contact';
    }
	
	
	public static String parseAndGetId(String pJsonContent){
		String idString = '';
		JSONParser parser = JSON.createParser(pJsonContent);
		
		while (parser.nextToken() != null) {
    		if (parser.getCurrentToken() == JSONToken.FIELD_NAME){
        		String fieldName = parser.getText();
        		
        		parser.nextToken();
		        if(fieldName == 'id'){
		            idString = parser.getText();
		        }
			}
		}
		return idString;
	}

}