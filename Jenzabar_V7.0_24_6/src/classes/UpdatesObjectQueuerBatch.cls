global class UpdatesObjectQueuerBatch implements Database.batchable<sObject>,QueuerInterface{
    
    public static final string queryString = 'SELECT Id,Event_ID__c FROM Queue__c WHERE Id IN: queueIdsforBatch ';
    Set<Id> queueIdsforBatch = new Set<Id>();
    
    global UpdatesObjectQueuerBatch(){}
    global UpdatesObjectQueuerBatch(Set<Id> pQueIds){
        queueIdsforBatch.addAll(pQueIds);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        for(sObject scopeItr : scope){
          UpdatesObjectQueuerController.execute(scopeItr.id);
        }
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
    public static void batchExecute(Set<Id> pQueIds,Integer pScope){
        UpdatesObjectQueuerBatch batchObj = new UpdatesObjectQueuerBatch (pQueIds);
        Id batchId = Database.executeBatch(batchObj,pScope);
    }

}