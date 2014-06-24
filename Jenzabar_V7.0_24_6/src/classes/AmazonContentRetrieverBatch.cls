public class AmazonContentRetrieverBatch implements Database.Batchable<EventBean>,Database.Stateful,EventInterface,Database.AllowsCallouts{
  
	public List<EventBean> eBeanList;
    public Map<Id, System__c> sysMap;
    public AmazonContentRetrieverBatch(){}
	public AmazonContentRetrieverBatch(List<EventBean> eList, Map<Id, System__c> sMap ){
		  eBeanList = new List<EventBean>();
		  eBeanList.addAll(eList);
		  sysMap = new Map<Id, System__c>();
		  sysMap.putAll(sMap);		  
	}
	/**
	 * Iterative start method. 
	 * It will iterate over list of EventBean Object considering defined scope.
	 */
	public Iterable<EventBean> start(Database.BatchableContext BC) { 
	      return eBeanList;
	}
	public void execute(Database.BatchableContext BC, List<EventBean> scope){
		  AmazonInfoRetriever.execute(eBeanList, sysMap);
	}
	public void finish(Database.BatchableContext BC){		
		  AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
		  //Send an email to the Apex job's submitter notifying of job completion.
		  Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		  String[] toAddresses = new String[] {a.CreatedBy.Email};
		  mail.setToAddresses(toAddresses);
		  mail.setSubject('Amazon Content Retriever Batch Status: ' + a.Status);
		  mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.');
		  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
	/* Method to call batch class and pass arugments to its parameterised constructor.
	 * This method is declared in EventInterface.
	 */
	public void newEventBatchExecute(List<EventBean> ebList,Map<Id,System__c> sysMap){
		  AmazonContentRetrieverBatch batchObj = new AmazonContentRetrieverBatch (ebList,sysMap);
          Id batchId = Database.executeBatch(batchObj,2);
	}

}