public with sharing class ReferenceDeleteController {
	  public static void deletePickListVal(List<Queue__c> referenceQueueList){
    	   Set<ID> retrieverName = new Set<ID>();
	       Set<String> recordTypeSet = new Set<String>();
	       Map<String,List<Reference_Mapping__c>> rTypeReferenceMap = new Map<String,List<Reference_Mapping__c>>();
	       
	       for(Queue__c queueInst : referenceQueueList){
	       	    retrieverName.add(queueInst.Retriever__c);  
	       }
	       List<Reference__c> newRefList = new List<Reference__c>([Select id,Name,RecordType.Name,RecordTypeId,Description__c,
	                                                               External_Id__c,IsActive__c,oca__c,Source__c,
	                                                               IsSynced__c,Previous_Value__c from Reference__c 
	                                                               where Name IN : retrieverName]);
	       system.debug('newRefList-----'+newRefList);                                                        
	       for(Reference__c newRefInst : newRefList){
	       	     recordTypeSet.add(newRefInst.RecordType.Name);
	       }   
	       List<Reference_Mapping__c> refMappingList = new List<Reference_Mapping__c>([Select id,Name,Reference_Record_Type__c,Object_Name__c,API_Name__c from Reference_Mapping__c where Reference_Record_Type__c IN : retrieverName]);                                                     
           system.debug('refMappingList------'+refMappingList);
	       for(Reference_Mapping__c refMappingInst : refMappingList){
	       	     if(rTypeReferenceMap != null && rTypeReferenceMap.containsKey(refMappingInst.Reference_Record_Type__c)){
	       	     	  rTypeReferenceMap.get(refMappingInst.Reference_Record_Type__c).add(refMappingInst);
	       	     }
	       	     else{	       	     	  
	       	     	  rTypeReferenceMap.put(refMappingInst.Reference_Record_Type__c, new Reference_Mapping__c[]{refMappingInst});
	       	     }
	       }
	      
	       for(Reference__c refInst : newRefList){  
	       	   if(rTypeReferenceMap != null){      
		           List<Reference_Mapping__c> referenceMappingList = rTypeReferenceMap.get(refInst.RecordType.Name);
		           system.debug('referenceMappingList----'+referenceMappingList);
		           for(Reference_Mapping__c refMapInst : referenceMappingList){
	                    try{
	                         PickValController.deletePickVal(refMapInst.Object_Name__c+'.'+refMapInst.API_Name__c, refInst.Name);
	                    }
	                    catch(Exception ex){
	                         system.debug('Exception caught in picklist Delete----'+ex.getMessage());
	                    }    
		           }
	       	   }
	       }
	  }   
}