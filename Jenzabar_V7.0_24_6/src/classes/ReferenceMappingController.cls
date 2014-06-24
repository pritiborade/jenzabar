public with sharing class ReferenceMappingController {

   
    public static void execute(Id eventId){
        String strTopicId = '';
        String jsonData = '';
        Map<String,List<Content_Mapping__c>> mapTopicRelatedContentMapping = new Map<String,List<Content_Mapping__c>>();
        Map<String,String> mapContent = new Map<String,String>();
        Map<String,String> mapJsonContentMap  = new Map<String,String>();
        Map<String,String> mapFields  = new Map<String,String>();
        
        Map<String, Schema.Sobjecttype> globalDescribeMap = Schema.getGlobalDescribe();
        Map<Id,Schema.RecordTypeInfo> referenceRecordTypeInfo = globalDescribeMap.get('Reference__c').getDescribe().getRecordTypeInfosById();
        
        List<Reference_Mapping__c> refMappingList;
       
        for(Event__c eventItr : [SELECT id,
                                        Event_State_ID__c,
                                        Topic_ID__c,
                                        Content_JSON__c 
                                        FROM Event__c 
                                        WHERE Id =: eventId LIMIT 1]){
                  
        
            strTopicId = eventItr.Topic_ID__c;
            jsonData = eventItr.Content_JSON__c;
        }
        mapJsonContentMap = ReferenceMappingController.jsonParser(jsonData);
        system.debug('mapJsonContentMap-----'+mapJsonContentMap);
        mapContent =  ContentMappingHandler.contentMapping(strTopicId,mapJsonContentMap);
        System.debug('mapContent-----'+mapContent);
        Reference__c refObj = new Reference__c();
        Map<String,Schema.SObjectField> refObjMap = Schema.SObjectType.Reference__c.fields.getMap();
        System.debug('refObjMap===='+refObjMap);
        if(!mapContent.isEmpty()){
            for(String str : mapContent.keySet()){
                System.debug('str==='+str);
                if(refObjMap.containsKey(str)){
                    Schema.DescribeFieldResult meta1 = refObjMap.get(str).getDescribe();
                    System.debug('mapContent.get(str)-------'+mapContent.get(str));
                    
                    if(mapContent.get(str) != null && mapContent.get(str) != ''){
                        if(String.valueOf(meta1.getType()) == 'Double'){
                            refObj.put(str,Decimal.valueOf(mapContent.get(str)));
                        }
                        else if(String.valueOf(meta1.getType()) == 'Datetime' ){
                            refObj.put(str,Datetime.valueOf(mapContent.get(str)));
                        }
                        else if(String.valueOf(meta1.getType()) == 'Boolean' ){
                            refObj.put(str,Boolean.valueOf(mapContent.get(str)));
                        }
                        else{
                            refObj.put(str,String.valueOf(mapContent.get(str)));
                        }   
                    }
                }
            }
        }
        
        System.debug('refObj-----'+refObj);
        refObj.IsSynced__c = false;

        try{
            insert refObj;
        }
        catch(Exception ex){
            system.debug('Exception caught in reference creation----'+ex.getMessage());
        }
    }
    public static Map<String,String> jsonParser(String pJsonContent){
        Map<String,String> mapJsonContentMap  = new Map<String,String>();
        String jsonData = pJsonContent;
        JSONParser parser = JSON.createParser(jsonData);
        system.debug('parser----');
        while (parser.nextToken() != null) {
            String fieldName = parser.getCurrentName();
            String fieldValue = parser.getText();
            if((fieldName != null && fieldValue != '{') || (fieldName != null && fieldValue != '}')){
                mapJsonContentMap.put(fieldName,fieldValue);
            }
        }
        
        if(mapJsonContentMap != null)
            return mapJsonContentMap;
        return null;    
    }
}