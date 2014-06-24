public with sharing class UpdatesObjectQueuerController {

   
    public static void execute(Id queueId){
        String sObjectName = '';
        String strTopicId = '';
        String jsonData = '';
        String systemId = '';
        Map<String,List<Content_Mapping__c>> mapTopicRelatedContentMapping = 
                                                            new Map<String,List<Content_Mapping__c>>();
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
                                           WHERE Id=: queueId LIMIT 1];
                                           
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
                                            Content_JSON__c, 
                                            SourceSystem_ID__c 
                                            FROM Event__c 
                                            WHERE Id=: queObjLst[0].Event_ID__c LIMIT 1]){
                      
            
                strTopicId = eventItr.Topic_ID__c;
                jsonData = eventItr.Content_JSON__c;
                systemId = eventItr.SourceSystem_ID__c;
            }
        }
        System.debug(jsonData);
        if(!topicObjLst.isEmpty()){
            sObjectName = topicObjLst[0].Object_Name__c;
        }
        
        mapJsonContent = NotificationUtilityController.jsonParser(jsonData);
        mapContent =  ContentMappingHandler.contentMapping(strTopicId,mapJsonContent,sObjectName,systemId);
        
        sObject sObjRec = NotificationUtilityController.getsObjectRec(sObjectName,mapContent);
       
        Database.saveResult result;
        try{
            result = Database.update(sObjRec);
           
            queObjLst[0].Retriever__c = result.getId();
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
}