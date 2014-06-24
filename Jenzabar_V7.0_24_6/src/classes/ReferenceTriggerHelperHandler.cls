public with sharing class ReferenceTriggerHelperHandler {
    public static void insertPickVal(List<Reference__c> newRefLst){
        List<String> recordTypeLst = new List<String>();
        Set<Id> referenceIds = new Set<Id>();
        Map<String,List<String>> objectFieldMap = new Map<String,List<String>>(); 
        for(Reference__c refItr: newRefLst){
            referenceIds.add(refItr.id);
        }
        
        for(Reference__c refItr : [SELECT id, RecordType.Name 
                                     FROM Reference__c
                                    WHERE id IN: referenceIds]){
            recordTypeLst.add('===refItr==='+refItr.RecordType.Name);
        }
        
        for(Reference_Mapping__c rfMappingItr : [SELECT Object_Name__c,API_Name__c,Reference_Record_Type__c
                                                   FROM Reference_Mapping__c 
                                                  WHERE  Reference_Record_Type__c IN: recordTypeLst]){
//            PickValController.createPickVal(rfMappingItr.Object_Name__c+'.'+rfMappingItr.API_Name__c, rfMappingItr.Reference__r.Description__c);
            
            System.debug('=====rfMappingItr===='+rfMappingItr);
        }
    }
}