/* Batch class for creating sObject */
global class CreatesObjectQueuerBatch implements Database.Batchable<sObject>,QueuerInterface {

    global String queueId;
    public static final string queryString = 'SELECT Id,Event_ID__c FROM Queue__c WHERE Id IN: queueIdsforBatch ';
    Set<Id> queueIdsforBatch = new Set<Id>();
    
    global CreatesObjectQueuerBatch(){}
    global CreatesObjectQueuerBatch(Set<Id> pQueIds){
        queueIdsforBatch.addAll(pQueIds);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        for(sObject scopeItr : scope){
        	CreatesObjectQueuerController.execute(scopeItr.id);
        }
    }
    
    global void finish(Database.BatchableContext BC){
    
    }
    
    public static void batchExecute(Set<Id> pQueIds,Integer pScope){
        CreatesObjectQueuerBatch batchObj = new CreatesObjectQueuerBatch (pQueIds);
        Id batchId = Database.executeBatch(batchObj,pScope);
    }
}