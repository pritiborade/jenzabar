public with sharing class DynamicDMLonSobjectRecord{
    
    public static void insertObj(String ObjectName){
        sObject sObj = Schema.getGlobalDescribe().get(ObjectName).newSObject() ;  
        sObj.put('LastName','Test');
        insert sObj;
        System.debug(sObj.id);
    }
    
    public static void updateObj(String ObjectName,Id sObjectId){
        sObject sObj = Schema.getGlobalDescribe().get(ObjectName).newSObject() ;  
        sObj.put('Id',sObjectId);
        sObj.put('LastName','Test 1');
        update sObj;
        System.debug(sObj.id);
    }
    
    public static void deleteObj(String ObjectName,Id sObjectId){
        sObject sObj = Schema.getGlobalDescribe().get(ObjectName).newSObject() ;  
        sObj.put('Id',sObjectId);
        delete sObj;
        System.debug(sObj.id);
    }
}