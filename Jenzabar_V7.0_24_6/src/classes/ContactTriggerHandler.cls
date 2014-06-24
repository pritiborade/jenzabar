public with sharing class ContactTriggerHandler extends BaseTrigger  {
    
    // Constructor
    public ContactTriggerHandler()
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
       
        
     	
    }
 
    public void afterUpdate(Map<id,sObject> oldMap, Map<Id,sObject> newMap)
    {
    	Map<id,Contact> oldConMap = new Map<id,Contact>();
    	Map<id,Contact> NewConMap = new Map<id,Contact>();
    	
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
    	UpdateRecord(contoUpdate);
    }
 
    public void afterDelete(List<SObject> so)
    {
    }
 
    public void andFinally()
    {
        
    }
	
	
		
}