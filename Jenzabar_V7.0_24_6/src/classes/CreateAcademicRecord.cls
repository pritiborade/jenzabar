public with sharing class CreateAcademicRecord implements BaseInterface{
    
    @future
    public static void execute(Id eventId){ 
    
        String strTopicId = '';
        String jsonData = '';
        Map<String,List<Content_Mapping__c>> mapTopicRelatedContentMapping = 
                                                            new Map<String,List<Content_Mapping__c>>();
        Map<String,String> mapContent = new Map<String,String>();
        Map<String,String> mapJsonContent  = new Map<String,String>();
        Map<String,String> mapFields  = new Map<String,String>();
        
        for(Event__c eventItr : [SELECT id,
                                        Event_State_ID__c,
                                        Topic_ID__c,
                                        Content_JSON__c 
                                        FROM Event__c 
                                        WHERE Id =: eventId LIMIT 1]){
                  
        
            strTopicId = eventItr.Topic_ID__c;
            jsonData = eventItr.Content_JSON__c;
        }
        mapJsonContent = CreateAcademicRecord.jsonParser(jsonData); 
        mapContent =  ContentMappingHandler.contentMapping(strTopicId,mapJsonContent,'');
        System.debug('mapContent==='+mapContent);
        Academic_Record__c acRecObj = new Academic_Record__c();
        Map<String,Schema.SObjectField> acRecObjMap = Schema.SObjectType.Academic_Record__c.fields.getMap();
        System.debug('=====acRecObjMap===='+acRecObjMap);
        if(!mapContent.isEmpty()){
            for(String str : mapContent.keySet()){
                System.debug('====str==='+str);
                if(acRecObjMap.containsKey(str)){
                    Schema.DescribeFieldResult meta1 = acRecObjMap.get(str).getDescribe();
                    system.debug('=====mapContent===='+mapContent);
                    system.debug('=====str===='+str);
                    
                    if(mapContent.get(str) <> null && !mapContent.get(str).equals('') && !mapContent.get(str).equals('null')){
                        if(String.valueOf(meta1.getType()) == 'Double'){
                            System.debug('===Double===');
                            acRecObj.put(str,Decimal.valueOf(mapContent.get(str)));
                        }
                        
                        else if(String.valueOf(meta1.getType()) == 'Datetime' ){
                        	System.debug('===Double===');
                            System.debug('===test1==='+mapContent.get(str));
                            acRecObj.put(str,Datetime.valueOf(mapContent.get(str)));
                        }
                        else if(String.valueOf(meta1.getType()) == 'Boolean' ){
                        	System.debug('===Double===');
                            acRecObj.put(str,Boolean.valueOf(mapContent.get(str)));
                        }
                        else{
                        	System.debug('===Double===');
                            acRecObj.put(str,String.valueOf(mapContent.get(str)));
                        }   
                    }
                }
            }
        }
        
        System.debug('===acRecObj==='+acRecObj);
        insert acRecObj;
        System.debug('===acRecObj  id==='+acRecObj.id);
    }
    
    public static Map<String,String> jsonParser(String pJsonContent){
        Map<String,String> mapJsonContent  = new Map<String,String>();
        String jsonData = pJsonContent;
        JSONParser parser = JSON.createParser(jsonData);

        while (parser.nextToken() != null) {
            String fieldName = parser.getCurrentName();
            String fieldValue = parser.getText();
            if((fieldName != null && fieldValue != '{') || (fieldName != null && fieldValue != '}')){
                mapJsonContent.put(fieldName,fieldValue);
            }
        }
        
        if(mapJsonContent != null)
            return mapJsonContent;
        return null;    
    }
        
}