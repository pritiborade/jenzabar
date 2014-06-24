public with sharing class CaseTriggerHandler extends BaseTrigger{

 // Constructor
    public CaseTriggerHandler()
    {
    }
 
    public void bulkBefore()
    {
    }
 
    public void bulkAfter()
    {
    }
 
    public void afterInsert(List<SObject> so)
    {
    }
 
    public void beforeUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap)
    {
			Map<Id,Case> caseNewMap = new Map<Id,Case>();
	    	List<Case> caseLst = new List<Case>();
	    	List<Case> caseLstNew = new List<Case>();
	        
	        for(sObject caseItr : newMap.values()){
	            caseNewMap.put(caseItr.id,(Case)caseItr);
	            caseLstNew.add((Case)caseItr);
	        }
	        Map<Id,Case> caseOldMap = new Map<Id,Case>();
	        
	        for(sObject caseItr : oldMap.values()){
	            caseOldMap.put(caseItr.id,(Case)caseItr);
	            caseLst.add((Case)caseItr);
	        }

	        CaseTriggerHelperHandler caseTriggerHelperHandler = new CaseTriggerHelperHandler();
	        caseTriggerHelperHandler.updateContact(caseLstNew,caseLst);//handler class method for performing before update functions

    }
    
    public void beforeDelete(List<SObject> so)
    {
        
    }
 
    public void beforeInsert(List<SObject> so) 
    {
	        List<Case> caseLst = new List<Case>();
	        for(Sobject soItr : so){
	            caseLst.add((Case)soItr);
	        }
	        CaseTriggerHelperHandler caseTriggerHelperHandler = new CaseTriggerHelperHandler();
	        caseTriggerHelperHandler.searchAddContact(caseLst); //handler class method for performing before insert functions
    }
    
    public void afterUpdate(Map<id,sObject> oldMap, Map<Id,sObject> newMap)
    {
    	
    }
    
 
    public void afterDelete(List<SObject> so)
    {
    }
 
    public void andFinally()
    {
        
    }

}