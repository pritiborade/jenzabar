/*
 *  Description : A class that contains 
 */
public with sharing class ContentMappingHandler{
    
    /** A method that returns the Map of ContentMapping object which are related ot the Topic which 
    **    is passed down to the method as a parameter.
    **/
    public static final string Id = 'Id';
    
    // This wrapper class will hold all type of fields those are required for content mapping.
    public class FieldWrapper{
        String fieldName;
        String datatype;
        String referenceTo;
        String jsonField;
        String jsonValue;
        public FieldWrapper(String pFieldName,String pDatatype,String pReference,String pJsonField,String pJsonValue){
            fieldName = pFieldName;
            datatype = pDatatype;
            referenceTo = pReference;
            jsonField = pJsonField;
            jsonValue = pJsonValue;
        }
    }
    public static Map<String,String> contentMapping(Id pStrTopicId,Map<String,String> jsonData,String ObjectType,String systemId){
    
        Map<String,String> fieldDTtypeMap = new Map<String,String>();
        Map<String,FieldWrapper> valueFieldMap = new Map<String,FieldWrapper>();
        Map<String,String> fieldValue = new Map<String,String>();
        Map<String,String> sffieldValueMap = new Map<String,String>();
        Set<String> objectString = new Set<String>();
        String internalType = '';
        
        for(Content_Mapping__c objContentMappingRec : [SELECT Id,
                                                              JSONField__c,
                                                              JSONObject__c,
                                                              Local_Field__c,
                                                              LocalObject__c,
                                                              Source_ID__c 
                                                       FROM Content_Mapping__c 
                                                       WHERE  Source_ID__c =: systemId
                                                       AND Id IN (SELECT Content_Mapping__c
                                                                            FROM Topic_Content__c
                                                                            WHERE Topic__c =: pStrTopicId)
                                                              ]){
                                                      
              internalType = objContentMappingRec.LocalObject__c;
              if(objContentMappingRec.JSONField__c != null && objContentMappingRec.Local_Field__c != null)
              {
                valueFieldMap.put(objContentMappingRec.JSONField__c,parseField(objContentMappingRec.Local_Field__c,objContentMappingRec.JSONField__c,jsonData.get(objContentMappingRec.JSONField__c)));
              }
        }
            
        for(FieldWrapper wrapItr : valueFieldMap.values()){
            
            if(String.valueOf(wrapItr.datatype).equalsIgnoreCase(Label.Content_Mapping_Lookup)){
                if(wrapItr.referenceTo != null){
                	fieldDTtypeMap.put(wrapItr.referenceTo+','+jsonData.get(wrapItr.jsonField),jsonData.get(wrapItr.jsonField));
            		objectString.add(wrapItr.referenceTo);
            	}
            }
            else if(String.valueOf(wrapItr.datatype).equalsIgnoreCase(Id)){
                fieldDTtypeMap.put(ObjectType+','+jsonData.get(wrapItr.jsonField),jsonData.get(wrapItr.jsonField));
            	objectString.add(ObjectType);
            }
        }
        
        fieldValue = ExternalRecMappingHandler.getExternalRecordsFieldsVal(fieldDTtypeMap,jsonData,objectString,systemId);
        
        for(FieldWrapper wrapItr : valueFieldMap.values()){
            
            if(fieldValue.containsKey(wrapItr.referenceTo+','+wrapItr.jsonValue))
            {
                jsonData.put(wrapItr.jsonField,fieldValue.get(wrapItr.referenceTo+','+wrapItr.jsonValue));
                sffieldValueMap.put(wrapItr.fieldName,fieldValue.get(wrapItr.referenceTo+','+wrapItr.jsonValue));
            }
            else if(fieldValue.containsKey(objectType+','+wrapItr.jsonValue))
            {
                jsonData.put(wrapItr.jsonField,fieldValue.get(wrapItr.referenceTo+','+wrapItr.jsonValue));
                sffieldValueMap.put(wrapItr.fieldName,fieldValue.get(objectType+','+wrapItr.jsonValue));
            }
            else
            {
                sffieldValueMap.put(wrapItr.fieldName,jsonData.get(wrapItr.jsonField));
            }
        }       
        
        return sffieldValueMap;
    }
    
    public static FieldWrapper parseField(String jsonLfield,String jsonField,String jsonValue){
        
        JSONParser parser = JSON.createParser(jsonLfield);
        FieldWrapper wrapperObj;
        Map<String,String> wrapperMap = new Map<String,String>();
        String fieldName,fieldValue;
        String reference = '';
       
        while(parser.nextToken() != null){
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME){
                
                    fieldName = parser.getText();
                    parser.nextToken();
                    fieldValue = parser.getText();
                    wrapperMap.put(fieldName,fieldValue);
            }
        }
          
        if(!wrapperMap.containsKey(Label.Content_Mappng_ReferenceTo)){
            wrapperMap.put(Label.Content_Mappng_ReferenceTo,'');
        }
       
        wrapperObj = new FieldWrapper(wrapperMap.get(Label.Content_Mapping_FieldName),wrapperMap.get(Label.Content_Mapping_Datatype),wrapperMap.get(Label.Content_Mappng_ReferenceTo),jsonField,jsonValue);
        return wrapperObj;
    }
}