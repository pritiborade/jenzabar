public with sharing class ReferenceUpdateController {
       public static void updatePickListVal(List<Queue__c> referenceQueueList){
       	
       	   ReferenceMappingUtility refUtilityObj = new ReferenceMappingUtility();
	       ReferenceMappingUtility.ReferenceMappingBean referenceMappingBeanObj = refUtilityObj.setReferenceMapping(referenceQueueList);
	       system.debug('referenceMappingBeanObj-----'+referenceMappingBeanObj);
	       List<Reference__c> newRefList = referenceMappingBeanObj.referenceList;
	       Map<String,List<Reference_Mapping__c>> recordTypeReferenceMap = referenceMappingBeanObj.recordTypeReferenceMap;
	       
	       for(Reference__c refInst : newRefList){  
	       	   if(recordTypeReferenceMap != null){      
		           List<Reference_Mapping__c> referenceMappingList = recordTypeReferenceMap.get(refInst.RecordType.Name);
		           system.debug('referenceMappingList----'+referenceMappingList);
		           for(Reference_Mapping__c refMapInst : referenceMappingList){
	                    try{
	                         PickValController.updatePickValue(refMapInst.Object_Name__c+'.'+refMapInst.API_Name__c, refInst.Previous_Value__c,refInst.Name);
	                    }
	                    catch(Exception ex){
	                         system.debug('Exception caught in picklist update----'+ex.getMessage());
	                    }    
		           }
	       	   }
	       }                                             
	  } 
}