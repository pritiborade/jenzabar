public with sharing class ReferenceCreateController {
	   public static void insertPickListVal(List<Queue__c> referenceQueueList){
	   	
	       ReferenceMappingUtility refUtilityObj = new ReferenceMappingUtility();
	       ReferenceMappingUtility.ReferenceMappingBean referenceMappingBeanObj = refUtilityObj.setReferenceMapping(referenceQueueList);
	       
	       system.debug('referenceMappingBeanObj-----'+referenceMappingBeanObj);
	       List<Reference__c> newRefList = referenceMappingBeanObj.referenceList;
	       Map<String,List<Reference_Mapping__c>> recordTypeReferenceMap = referenceMappingBeanObj.recordTypeReferenceMap;
	       
	       List<String> picklistInfo = new List<String>();
	       
	       for(Reference__c refInst : newRefList){        
	           if(recordTypeReferenceMap != null){
		           List<Reference_Mapping__c> referenceMappingList = recordTypeReferenceMap.get(refInst.RecordType.Name);
		           system.debug('referenceMappingList----'+referenceMappingList);
		           for(Reference_Mapping__c refMapInst : referenceMappingList){	             
		           	     refInst.IsSynced__c = true;      
	                     //PickValController.createPickVal(refMapInst.Object_Name__c+'.'+refMapInst.API_Name__c, refInst.Name);
	                     picklistInfo.add(refMapInst.Object_Name__c+'.'+refMapInst.API_Name__c +','+ refInst.Name);	                        	                    
		           }
	           }
	       } 
	       try{
	       		PickValController.copyCreatePickVal(picklistInfo);   
	       		update newRefList;
	       }
	       catch(Exception ex){
	       	    system.debug('Exception caught in picklist insert------'+ex.getMessage());
	       }
	  } 
}