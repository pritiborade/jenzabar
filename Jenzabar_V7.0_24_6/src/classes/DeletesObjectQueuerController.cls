public with sharing class DeletesObjectQueuerController {
    
    public static void execute(Id queueId){
        String strTopicId = '';
        String jsonData = '';
        String sObjectName = '';
        String systemId = '';
        Map<String,List<Content_Mapping__c>> mapTopicRelatedContentMapping = new Map<String,List<Content_Mapping__c>>();
        Map<String,String> mapContent = new Map<String,String>();
        Map<String,String> mapJsonContent  = new Map<String,String>();
        Map<String,String> mapFields  = new Map<String,String>();
        List<Topic__c> topicObjLst = new List<Topic__c>();
        
        List<Queue__c> queObjLst = [SELECT Id,
                                           Event_ID__c,
                                           Attempt_Count__c,
                                           Queue_State_ID__c,
                                           Retriever__c,
                                           Topic_Id__c
                                           FROM Queue__c 
                                           WHERE Id=: queueId];
        if(!queObjLst.isEmpty()){                                   
            topicObjLst = [SELECT Id,
                                  Object_Name__c
                                  FROM Topic__c 
                                  WHERE Id=: queObjLst[0].Topic_Id__c];
    	}
        
        if(!queObjLst.isEmpty()){                                       
            for(Event__c eventItr : [SELECT id,
                                            Event_State_ID__c,
                                            Topic_ID__c,
                                            Content_JSON__c 
                                            FROM Event__c 
                                            WHERE Id=: queObjLst[0].Event_ID__c]){
                      
            
                strTopicId = eventItr.Topic_ID__c;
                jsonData = eventItr.Content_JSON__c;
                systemId = eventItr.SourceSystem_ID__c;
            }
        }
        
        if(!topicObjLst.isEmpty()){
            sObjectName = topicObjLst[0].Object_Name__c;
        }
        
        mapJsonContent = NotificationUtilityController.jsonParser(jsonData);
        mapContent =  ContentMappingHandler.contentMapping(strTopicId,mapJsonContent,sObjectName,systemId);
        sObject sObjRec = NotificationUtilityController.getsObjectRec(sObjectName,mapContent);
        Id idString = sObjRec.Id;
        String str = DeletesObjectQueuerController.getDeletingString(idString,sObjectName);
        System.debug('str==='+str);
        Database.DeleteResult result;
        try{
            result = Database.delete(sObjRec);
            System.debug('result.getE=='+result.getErrors());
            queObjLst[0].Retriever__c = str;
            queObjLst[0].Queue_State_ID__c = 'Complete';  
        }
        catch(Exception e){
            queObjLst[0].Retriever__c = String.valueOf(e.getMessage());
            queObjLst[0].Queue_State_ID__c = 'Error';
        }
        finally{
            queObjLst[0].Attempt_Count__c = queObjLst[0].Attempt_Count__c != null ? queObjLst[0].Attempt_Count__c+1 : 1; 
            Database.saveResult queueResult = Database.update( queObjLst[0]);
        }
    }
    
     public static Map<String,String> jsonParser(String pJsonContent){
        Map<String,String> mapJsonContent  = new Map<String,String>();
        String jsonData = pJsonContent;
        JSONParser parser = JSON.createParser(jsonData);

        while (parser.nextToken() != null) {
            String fieldName = parser.getCurrentName();
            String fieldValue = parser.getText();
            if((fieldName != null && fieldValue != '{') || (fieldName != null && fieldValue != '}')&&(fieldName!= 'ObjectType')){
                mapJsonContent.put(fieldName,fieldValue);
            }
        }
        
        if(mapJsonContent != null)
            return mapJsonContent;
        return null;    
    }
    
    
    public static String getDeletingString(String idString,String sObjectName){
        List<String> fieldString = new List<String>();
        fieldString = ((DeletingFieldJson__c.getAll().get(sObjectName).Field_API_Name__c).replaceAll( '\\s+', '')).split(',');
        String jsonString = '{';
        String fieldStringValue = String.valueOf(fieldString).remove('(');
        fieldStringValue = fieldStringValue.remove(')');
        String queryString = 'SELECT '+fieldStringValue+' FROM '+ sObjectName +' WHERE ID=:idString';
        System.debug('queryString===='+queryString);
       
        for(sObject sObjItr : Database.query(queryString)){
            System.debug('test');
            for(String str : fieldString){
                jsonString += '"' +str+ '":';
                jsonString += '"' + sObjItr.get(str) + '",';
                System.debug('for=='+jsonString);
            }
        }
        
        jsonString = jsonString.subString(0, jsonString.length() - 1);
        jsonString += '}';
        System.debug('jsonString===='+jsonString);
        return jsonString;
    }
}