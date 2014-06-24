/* Description : This controller is utility controller for Notification model */

public with sharing class NotificationUtilityController {
     
    
    public static final string DT_DOUBLE = 'Double';
    public static final string DT_DATETIME = 'Datetime';
    public static final string DT_BOOLEAN = 'Boolean';
    public static final string DT_Date = 'Date';
    public static final string REFRENCE = 'REFERENCE';
    public static final Map<String,Set<String>> requiredMap = new Map<String,Set<String>>{
        'Contact' => new Set<String>{'Name','IsEmailBounced','HasOptedOutOfEmail','HasOptedOutOfFax'}
     };
     
    public static final Set<String> objecttoExcludeforName = new Set<String>{'Contact'}; 
    public static final Set<String> excludingObject = new Set<String>{'User','Group'}; 
    public static final Set<String> fieldtoExclude = new Set<String>{'isDeleted','CreatedDate','IsDeleted','LastModifiedDate','SystemModstamp','Id'};
    private static Set<String> keyPrefixSet; 
    private static Map<String,Schema.SObjectType> describeObj;  
    private static Map<String, String> keyPrefixMap;  
    private static Map<String,Stub_Data__c> stubMap = Stub_Data__c.getAll();
    private static Map<String,Stub_sObject_Id_Mapping__c> sObjectIdMapping = Stub_sObject_Id_Mapping__c.getAll();
    public static Set<String> objectProcessed = new Set<String>();
    public static Map<Integer,Set<String>> referenceMap = new Map<Integer,Set<String>>();
    public static integer index = 0;
    public static Map<Integer,Boolean> isAllProcessed = new Map<Integer,Boolean>();
    public static Map<String,Schema.SObjectType> globalFieldResult = Schema.getGlobalDescribe();
     
    public static Map<String,String> jsonParser(String pJsonContent){
        Map<String,String> MapJsonContent  = new Map<String,String>();
        String jsonData = pJsonContent;
        JSONParser parser = JSON.createParser(jsonData);

        while (parser.nextToken() != null) {
            String fieldName = parser.getCurrentName();
            String fieldValue = parser.getText();
            
            if((fieldName != null && fieldValue != '{') || 
               (fieldName != null && fieldValue != '}') || 
               (fieldName != null && fieldValue != null) ||
               (fieldName != 'null' && fieldValue != 'null') && (parser.getCurrentToken() == JSONToken.FIELD_NAME))
            {
                MapJsonContent.put(fieldName,fieldValue);
            }
        }
        
        if(!MapJsonContent.isEmpty()){
            return MapJsonContent;
        }
        return null;    
    }
    
    public static sObject getsObjectRec(String sObjectName,Map<String,String> MapContent){
        
        Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjectName);
        SObject sObjRec = t.newSObject();
        Schema.Describesobjectresult dsr = Schema.getGlobalDescribe().get(sObjectName).getDescribe();
        Map<String, Schema.SObjectField> acRecObjMap = dsr.fields.getMap();
      
        if(!MapContent.isEmpty()){
            for(String str : MapContent.keySet()){
                
                if(acRecObjMap.containsKey(str)){
                    Schema.DescribeFieldResult meta1 = acRecObjMap.get(str).getDescribe();
                    
                    if(MapContent.get(str) <> null && !MapContent.get(str).equals('') && !MapContent.get(str).equals('null')){
                        if(String.valueOf(meta1.getType()) == DT_DOUBLE){
                            sObjRec.put(str,Decimal.valueOf(MapContent.get(str)));
                        }
                        
                        else if(String.valueOf(meta1.getType()) == DT_DATETIME){
                            sObjRec.put(str,Datetime.valueOf(MapContent.get(str)));
                        }
                        else if(String.valueOf(meta1.getType()) == DT_BOOLEAN){
                            sObjRec.put(str,Boolean.valueOf(MapContent.get(str)));
                        }
                        else if(String.valueOf(meta1.getType()) == DT_DATE){
                            sObjRec.put(str,Date.valueOf(MapContent.get(str)));
                        }
                        else{
                            sObjRec.put(str,String.valueOf(MapContent.get(str)));
                        }
                           
                    }
                }
            }
        }
        return sObjRec;
    }
    
    // This method is used to create to External Record for Id Cross footing
    public static void createExeternalRecord(String sObjectName,sObject sobjRec,String sourceSystemId){
        External_Record__c externalRec = new External_Record__c();
        externalRec.Internal_Type__c = sObjectName;
        externalRec.Internal_ID__c = sObjRec.Id;
        externalRec.External_ID__c = String.valueOf(sobjRec.get((Notification_CreateExternalRecordMapping__c.getAll().get(sObjectName)).sObject_External_Id_Field_API__c));
        externalRec.System_ID__c = sourceSystemId;
        List<RecordType> rc = new List<RecordType>();
        rc = [SELECT id,SobjectType  FROM RecordType WHERE SobjectType =: sObjectName];
        
        if(externalRec != null){
            try{
                
                 if(!rc.isEmpty()){
                     externalRec.Record_Type__c = String.valueOf(sObjRec.get('RecordTypeId'));
                 }
                 Database.Saveresult result = Database.insert(externalRec);
                 System.debug('external record'+externalRec.id);
                 if(result.isSuccess()){
                    Event__c eventRec = new Event__c();
                    eventRec.Topic_ID__c = Label.TopicID_ExternalRecord;
                    eventRec.SourceSystem_ID__c = sourceSystemId;
                    eventRec.Content_JSON__c = NotificationUtilityController.returnExternalJsonforEvent(externalRec.Internal_Type__c,
                                                                                                        externalRec.Internal_ID__c,
                                                                                                        externalRec.External_ID__c, externalRec.System_ID__c,externalRec.Record_Type__c);
                    insert eventRec;
                    System.debug('====eventRec==='+eventRec.id);
                 }
            }catch(Exception e){
                System.debug('Exception '+e.getMessage());
            }
            
        }
    }
    
    // This method will return a string for Event's JSON content for External Record Id Crossfooting
    public static String returnExternalJsonforEvent(String internalType,String internalId,String externalId,Id systemId,String recordTypeId){
         return '{"InternalType":"'+ internalType+'",'
                 +'"InternalId":'+'":'+ internalId+'",'
                 +'"ExternalId":'+ externalId+'",'
                 +'"SystemId":'+'"'+ systemId+'",'
                 +'"RecordTypeId":'+'"'+ recordTypeId+'}';
    }
    
    // This method will be used for creating keyPrefix & Object Name map
    private static void init() {  
        
        describeObj = Schema.getGlobalDescribe();  
        keyPrefixMap = new Map<String, String>{};  
        keyPrefixSet = describeObj.keySet();  
        
        for(String sObj : keyPrefixSet)  
        {  
            Schema.DescribeSObjectResult dsResult =  describeObj.get(sObj).getDescribe();  
            String objName = dsResult.getName();  
            String objPrefix = dsResult.getKeyPrefix();  
            keyPrefixMap.put(objPrefix, objName);  
        }  
    }  
    
    // This method will be used to create stub record when external record is not found for external Id
    public static void createStubRec(Map<String,String> jsonContentMap,Map<String,Boolean> refJsonContent,String systemId){
        init();
        List<SObject> sObjtoInsert = new List<sObject>();
        List<External_Record__c> extLst = new List<External_Record__c>();
        List<Event__c> eventLst = new List<Event__c>();
                
        for(String str : refJsonContent.keySet()){
          
            String objectName = str.subString(0,str.indexOf(','));
            sObject sObj = Schema.getGlobalDescribe().get(ObjectName).newSObject() ;
            NotificationUtilityController.getRequiredValues(objectName,sObj);
            sObj.put((Notification_CreateExternalRecordMapping__c.getAll().get(objectName)).sObject_External_Id_Field_API__c,str.subString(str.indexOf(',')+1,str.length()));
            sObjtoInsert.add(sObj);
        }
        
        if(!sObjtoInsert.isEmpty()){
           
           Database.saveresult[] result = Database.insert(sObjtoInsert);
            
           for(Database.saveResult resultItr : result){
                if(resultItr.isSuccess()){
                    
                    
                    for(String strItr : refJsonContent.keySet()){
                        if(strItr.subString(0,strItr.indexOf(',')) == keyPrefixMap.get(String.valueOf((resultItr.id)).subString(0,3))){
                            
                            External_Record__c externalRec = new External_Record__c();
                            externalRec.Internal_Type__c = keyPrefixMap.get(String.valueOf((resultItr.id)).subString(0,3));
                            externalRec.Internal_ID__c = resultItr.Id;
                            externalRec.External_ID__c = strItr.subString(strItr.indexOf(',')+1,strItr.length());
                            externalRec.System_ID__c = systemId;
                            extLst.add(externalRec);
                            
                            Event__c eventRec = new Event__c();
                            eventRec.SourceSystem_ID__c = systemId;
                            eventRec.Topic_ID__c = sObjectIdMapping.get(strItr.subString(0,strItr.indexOf(','))).Topic_Id__c;
                            eventRec.Content_Json__c = '{"Id":"'+resultItr.id+'}';
                            eventLst.add(eventRec);
                            jsonContentMap.put(strItr,resultItr.id);
                        }
                        
                    }
                }
            }
        }
        
        if(!extLst.isEmpty()){
            insert extLst;
        }
        
        if(!eventLst.isEmpty()){
            insert eventLst;
        }
    }
    
    public static sObject getRequiredValues(String sObjectName,sObject sObjRec){
        
        Schema.Describesobjectresult dsr = Schema.getGlobalDescribe().get(sObjectName).getDescribe();
        Map<String, Schema.SObjectField> acRecObjMap = dsr.fields.getMap();
        String couter = '0';
        
        for(Schema.Sobjectfield fieldItr : acRecObjMap.values()){
            Schema.Describefieldresult fieldResult = fieldItr.getDescribe();
         
                
             if(!fieldResult.isNillable()  && fieldResult.getType().Name() != 'BOOLEAN' && fieldResult.getType().Name() != 'Reference' && 
                !fieldResult.isAutoNumber() && !fieldtoExclude.contains(fieldResult.getName()) && 
                (String.valueOf(fieldResult.getSobjectField()) == 'Name' || objecttoExcludeforName.contains(sObjectName)) &&
                !requiredMap.get(sObjectName).contains(String.valueOf(fieldResult.getName()))){
                
                if(String.valueOf(fieldResult.getType()) == DT_DOUBLE){
                    sObjRec.put(String.valueOf(fieldItr),stubMap.get('sObject').Double__c);
                }
                
                else if(String.valueOf(fieldResult.getType()) == DT_DATETIME){
                    sObjRec.put(String.valueOf(fieldItr),stubMap.get('sObject').Datetime__c);
                }
                else if(String.valueOf(fieldResult.getType()) == DT_DATE){
                    sObjRec.put(String.valueOf(fieldItr),stubMap.get('sObject').Date__c);
                }
                else{
                    sObjRec.put(String.valueOf(fieldItr),stubMap.get('sObject').Text__c);
                }
            }
            else if(!fieldResult.isNillable() && fieldResult.getType().name() == REFRENCE){
                sObjRec.put(String.valueOf(fieldItr),sObjectIdMapping.get(String.valueOf(fieldResult.getReferenceTo())).Stub_Id__c);
            }
        
        }
        
        
        System.debug('referenceMap===='+referenceMap);
        return sObjRec;
    }
    
    
}