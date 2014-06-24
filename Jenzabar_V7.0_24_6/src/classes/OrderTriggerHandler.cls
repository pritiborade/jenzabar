public with sharing class OrderTriggerHandler extends BaseTrigger{
    
    // Constructor
    public OrderTriggerHandler()
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
        List<Order> orderLst = new List<Order>();
        for(Sobject soItr : so){
            orderLst.add((Order)soItr);
        }
        OrderTriggerHelperHandler.addOppProduct(orderLst);
        
    }
 
    public void afterUpdate(Map<id,sObject> oldMap, Map<Id,sObject> newMap)
    {
        Map<Id,Order> orderNewMap = new Map<Id,Order>();
        for(sObject orderItr : newMap.values()){
            orderNewMap.put(orderItr.id,(Order)orderItr);
        }
        
        Map<Id,Order> orderOldMap = new Map<Id,Order>();
        for(sObject orderItr : oldMap.values()){
            orderOldMap.put(orderItr.id,(Order)orderItr);
        }
        
        
        //OrderTriggerHelperHandler.addOppProduct(orderNewMap.values());
        OrderTriggerHelperHandler.updateProduct(orderOldMap,orderNewMap);
    }
 
    public void afterDelete(List<SObject> so)
    {
    }
 
    public void andFinally()
    {
        
    }
}