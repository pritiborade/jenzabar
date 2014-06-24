public with sharing class ReferenceTriggerHandler extends BaseTrigger {

    
    // Constructor
    public ReferenceTriggerHandler()
    {
    }
 
    public void bulkBefore()
    {
    }
 
    public void bulkAfter()
    {
    }
 
    public void beforeInsert(List<SObject> so)
    {
    }
 
    public void beforeUpdate(Map<Id,SObject> oldSo, Map<Id,SObject> so)
    {
    }
    
    public void beforeDelete(List<SObject> so)
    {
        
    }
 
    public void afterInsert(List<SObject> so)
    {
       
        List<Reference__c> newRefLst = new List<Reference__c>();
        for(sObject sObjectItr : so){
        	newRefLst.add((Reference__c)sObjectItr);
        }
     	ReferenceTriggerHelperHandler.insertPickVal(newRefLst);
    }
 
    public void afterUpdate(Map<id,sObject> oldMap, Map<Id,sObject> newMap)
    {
    	Map<id,Contact> oldConMap = new Map<id,Contact>();
    	Map<id,Contact> newConMap = new Map<id,Contact>();
    	
    	for(sObject conItr : oldMap.values())
    	{
    		oldConMap.put(conItr.id,(Contact)conItr);
    	}
    	
    	for(sObject conItr : newMap.values())
    	{
    		NewConMap.put(conItr.id,(Contact)conItr);
    	}
    	ContactTriggerHelperHandler conTrgHelperObj = new ContactTriggerHelperHandler();
    	List<Contact> conTrgHelperLst = conTrgHelperObj.onAfterUpdate(oldConMap,NewConMap);
    	//update conTrgHelperLst;
    	List<Contact> contoUpdate = new List<Contact>();
    	for(Contact conTrigger : conTrgHelperLst){
    		if(conTrigger.id != null){
    			contoUpdate.add(conTrigger);
    		}
    	}
    	updateRecord(contoUpdate);
    }
 
    public void afterDelete(List<SObject> so)
    {
    }
 
    public void andFinally()
    {
        
    }
	
	
		

}