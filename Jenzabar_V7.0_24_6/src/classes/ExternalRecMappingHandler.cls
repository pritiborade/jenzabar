/*
 * Description : A class that contains the method that are related to the
 *               External Records mapping which handles all the functionality related 
 *               to External Records.
 */

public class ExternalRecMappingHandler{
  
    /* This method will set all the lookup field those required ID to be mapped to false
     * so that we can check for stub record creation for those are not present.
     */
    public static Map<String,Boolean> init(Map<String,String> pJsonContent){
        Map<String,Boolean> returnMap = new Map<String,Boolean>();
        for(String strItr : pJsonContent.keySet()){
            returnMap.put(strItr,false);
        }
        
        return returnMap;
    }
    
    /* This method will assign the internal ids to json content by mapping it through
     * external record mapping
     */
    public static Map<String,String> getExternalRecordsFieldsVal(Map<String,String> jsonContentMap,Map<String,String> jsonData,Set<String> internalType,String systemId){
        
        Map<String,Boolean> refJsonContent = init(jsonContentMap);
        for(External_Record__c extItr : [SELECT Internal_ID__c,
                                                External_ID__c,
                                                Internal_Type__c
                                                FROM External_Record__c
                                                WHERE External_ID__c IN: jsonContentMap.values() 
                                                AND Internal_Type__c IN: internalType]
                                                ){
            
            if(jsonContentMap.containsKey(extItr.Internal_Type__c+','+extItr.External_ID__c)){
                refJsonContent.put(extItr.Internal_Type__c+','+extItr.External_ID__c,true);
                jsonContentMap.put(extItr.Internal_Type__c+','+extItr.External_ID__c,extItr.Internal_ID__c);
            }
         }
         
         for(String str : refJsonContent.keySet()){
         	if(refJsonContent.get(str) == true){
         		refJsonContent.remove(str);
         	}
         }
         
         if(!refJsonContent.isEmpty()){
         	NotificationUtilityController.createStubRec(jsonContentMap,refJsonContent,systemId);
         }
        return jsonContentMap;
    }
}