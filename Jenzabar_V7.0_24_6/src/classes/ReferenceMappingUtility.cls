public with sharing class ReferenceMappingUtility {
	
	 public class ReferenceMappingBean{
	 	 public List<Reference__c> referenceList;
	 	 public Map<String,List<Reference_Mapping__c>> recordTypeReferenceMap;
	 	 public ReferenceMappingBean(){
	 	 	  referenceList = new List<Reference__c>();
 	 	   	  recordTypeReferenceMap = new Map<String,List<Reference_Mapping__c>>();
	 	 }	 	 
	 } 
	 public ReferenceMappingBean setReferenceMapping(List<Queue__c> referenceQueueList){
	 	   ReferenceMappingBean referenceMappingBeanInst = new ReferenceMappingBean();
	 	   Set<ID> retrieverIds = new Set<ID>();
	       Set<String> recordTypeSet = new Set<String>();
	       Map<String,List<Reference_Mapping__c>> rTypeReferenceMap = new Map<String,List<Reference_Mapping__c>>();
	       
	       for(Queue__c queueInst : referenceQueueList){
	       	    retrieverIds.add(queueInst.Retriever__c);  
	       }
	       List<Reference__c> newRefList = new List<Reference__c>([Select id,
	                                                                      Name,
	                                                                      RecordType.Name,
	                                                                      RecordTypeId,Description__c,
	                                                                      External_Id__c,
	                                                                      IsActive__c,
	                                                                      oca__c,
	                                                                      Source__c,
	                                                                      IsSynced__c,
	                                                                      Previous_Value__c 
	                                                                      from Reference__c where id IN : retrieverIds]);
	       system.debug('newRefList-----'+newRefList);                                                        
	       for(Reference__c newRefInst : newRefList){
	       	     recordTypeSet.add(newRefInst.RecordType.Name);
	       }   
	       List<Reference_Mapping__c> refMappingList = new List<Reference_Mapping__c>([Select id,
	                                                                                          Name,
	                                                                                          Reference_Record_Type__c,
	                                                                                          Object_Name__c,API_Name__c 
	                                                                                          from Reference_Mapping__c 
	                                                                                          where Reference_Record_Type__c IN : recordTypeSet]);                                                     
           system.debug('refMappingList------'+refMappingList);
	       for(Reference_Mapping__c refMappingInst : refMappingList){
	       	     if(rTypeReferenceMap != null && rTypeReferenceMap.containsKey(refMappingInst.Reference_Record_Type__c)){
	       	     	  rTypeReferenceMap.get(refMappingInst.Reference_Record_Type__c).add(refMappingInst);
	       	     }
	       	     else{	       	     	  
	       	     	  rTypeReferenceMap.put(refMappingInst.Reference_Record_Type__c, new Reference_Mapping__c[]{refMappingInst});
	       	     }
	       }
	      
	       referenceMappingBeanInst.referenceList.addAll(newRefList);
	       referenceMappingBeanInst.recordTypeReferenceMap.putAll(rTypeReferenceMap);
	       
	       return referenceMappingBeanInst;
	 }
}