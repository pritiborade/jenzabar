global class ReferenceCreateScheduler implements Schedulable{
      String CRON_EXP; 
      String JOB_NAME ;  
      List<Topic__c> createRefTopicList;
	  public ReferenceCreateScheduler(){
	  	   List<Topic__c> createRefTopicList = [Select t.Topic_Area_ID__c, 
  	   												   t.Name__c, 
  	   												   t.Name, 
  	   												   t.Level_ID__c, 
  	   												   t.Id 
  	   												   From Topic__c t 
  	   												   where Name__c =: System.Label.Create_Reference];
	  	   List<Publisher__c> createRefPublisherList = [Select  p.TopicID__c, 
							  	                                p.Schedule__c, 
							  	                                p.Retry_Attempts__c, 
							  	                                p.RetryInterval__c, 
							  	                                p.Retriever__c, 
							  	                                p.Publisher__c, 
							  	                                p.Name, p.Id 
							  	                                From Publisher__c p where TopicID__c =:createRefTopicList[0].id];
	  	   if(createRefPublisherList != null && createRefPublisherList.size()>0){                              
	  	   		CRON_EXP = createRefPublisherList[0].Schedule__c;
	  	   		JOB_NAME = 'CreateReferencePublisher';
	  	   } 
	  	   
	  }
      
	  global void execute(SchedulableContext sc){
	  	   													 
	  	   if(createRefTopicList != null && createRefTopicList.size()>0){
	  	   		List<Queue__c> referenceQueueList = new List<Queue__c>([Select q.Topic_Id__c, 
	  	   																	   q.Retriever__c, 
	  	   																	   q.Queue_State_ID__c, 
	  	   																	   q.Name, q.Id, 
	  	   																	   q.Event_ID__c From Queue__c q 
	  	   																	   where Topic_Id__c =: createRefTopicList[0].id and 
	  	   																	   Queue_State_ID__c=: 'Completed']);
	  	   	  if(CRON_EXP != null){																   
		  	       System.schedule(JOB_NAME, CRON_EXP, new ScheduleQueue());    																	   
		  	       ReferenceCreateController.insertPickListVal(referenceQueueList);
	  	   	  }
	  	   }
	  }
      
}