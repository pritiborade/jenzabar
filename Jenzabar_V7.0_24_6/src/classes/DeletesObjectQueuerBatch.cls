global class DeletesObjectQueuerBatch implements Database.batchable<sObject>,QueuerInterface {
    
    public static final string queryString = 'SELECT Id,Event_ID__c FROM Queue__c WHERE Id IN: queueIdsforBatch ';
    Set<Id> queueIdsforBatch = new Set<Id>();
    
    global DeletesObjectQueuerBatch(){}
    
    global DeletesObjectQueuerBatch(Set<Id> pQueIds){
        queueIdsforBatch.addAll(pQueIds);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        for(sObject scopeItr : scope){
          DeletesObjectQueuerController.execute(scopeItr.id);
        }
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
    public static void batchExecute(Set<Id> pQueIds,Integer pScope){
        DeletesObjectQueuerBatch batchObj = new DeletesObjectQueuerBatch (pQueIds);
        Id batchId = Database.executeBatch(batchObj,pScope);
    }
}