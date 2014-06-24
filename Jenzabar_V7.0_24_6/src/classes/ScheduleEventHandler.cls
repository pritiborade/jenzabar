public with sharing class ScheduleEventHandler  {
	private static final String TYPE = 'type';
	private static final String LINK = 'link';
	
	/**
	 * Method to fetch all new events and group them by retriever type.
	 * Based on retriever type it will call batch class and pass list of EventBean and Map of System.
	 * EventBean is a wrapper class consists of Event object and parsed Retriever type and Retriever Link.
	 */
    public static void fetchNewEvent(){
		  set<ID> sourceSystemIds = new Set<ID>(); 
		  List<EventBean> eventBeanList = new List<EventBean>();  		  
		  List<Event__c> newEventList = [Select id,
												Event_State_ID__c,
												Topic_ID__c ,
												Retriever_Info__c,
												SourceSystem_ID__c,
												Content_JSON__c
												FROM Event__c 
												WHERE Event_State_ID__c =: Label.Event_New];

		  for(Event__c eventInst : newEventList){
				sourceSystemIds.add(eventInst.SourceSystem_ID__c);
		  }
		  Map<Id,System__c> systemMap = new Map<Id,System__c>([Select id,
		                                                              Name,
		                                                              Credentials__c,
		                                                              Name__c,
		                                                              Token__c,
		                                                              URL__c,
		                                                              (Select LocalObject__c,JSONObject__c,Local_Field__c,JSONField__c FROM Content_Mappings__r) 
		                                                              from System__c where id IN : sourceSystemIds]);
		  for(Event__c eInst : newEventList){
		  	
		  	    String rtype,rlink;
		  	    EventBean eventBeanObj = new EventBean();
				Map<String, String> InfoRetrievalMap = retrieverMap(eInst.Retriever_Info__c);//Parsing retreval info jason content
				if(InfoRetrievalMap != null && !InfoRetrievalMap.isEmpty()){
					 System__c systemObj = systemMap.get(Id.ValueOf(eInst.SourceSystem_ID__c));
					 if(systemObj != null){
						 for(Content_Mapping__c contentMapInst : systemObj.Content_Mappings__r){
							  if(contentMapInst.Local_Field__c.equalsIgnoreCase(TYPE)){
							  	    rtype = InfoRetrievalMap.get(contentMapInst.JSONField__c);
							  }
							  else if(contentMapInst.Local_Field__c.equalsIgnoreCase(LINK)){
							  	    rlink = InfoRetrievalMap.get(contentMapInst.JSONField__c);
							  }
						 }
						 eventBeanObj.eventObj = eInst;
						 eventBeanObj.retriverType = rtype;
						 eventBeanObj.link = rlink;
						 eventBeanList.add(eventBeanObj);
					 }
				}
		  }	
		  Map<String, List<EventBean>> retriverTypeEventMap = new Map<String, List<EventBean>>();
		  for(EventBean beanInst : eventBeanList){
		        if(retriverTypeEventMap != null && retriverTypeEventMap.containsKey(beanInst.retriverType)){
		        	  retriverTypeEventMap.get(beanInst.retriverType).add(beanInst);
		        }
		        else{
		        	 retriverTypeEventMap.put(beanInst.retriverType,new EventBean[]{beanInst}); 
		        }
		  }
		  List<EventCustomSetting__c> eventSettingList = EventCustomSetting__c.getall().values();
		  Map<String, String> eventSettingMap = new Map<String, String>(); 
		  for(EventCustomSetting__c ec : eventSettingList){
			  eventSettingMap.put((String)ec.Event_Type__c,(String)ec.Type_Handler__c);
		  }
		  for(String rType : retriverTypeEventMap.keySet()){
		  	    System.Type typeObj = System.Type.forName(eventSettingMap.get(rType));
		  	    Object obj = typeObj.newInstance();
		        if(typeObj != null){
		            EventInterface eInterface = (EventInterface)obj;
		            if(eInterface != null){
            	    	eInterface.newEventBatchExecute(retriverTypeEventMap.get(rType),systemMap);
		            }
		        }
		  }
    }		 
    /**
     * Method to fetch list of ready events and group them by TopicId.
     * Based on TopicId, it will call queuer and pass list of ready event.
     */ 
    @future
    public static void createReadyQueue(){
        Map<Id,Event__c> eventMapToUpdate = new Map<Id,Event__c>();
        Map<id,List<Event__c>> eventMap = new Map<Id,List<Event__c>>();
        for(Event__c eventItr : [SELECT Id,
                                        Event_State_ID__c,
                                        Topic_ID__c ,
                                        Retriever_Info__c,
                                        Content_JSON__c
                                        FROM Event__c 
                                        WHERE Event_State_ID__c =: Label.Event_Ready
                                       ]){
       
	        if(!String.isEmpty(eventItr.Content_JSON__c)){
	                if(eventMap.containsKey(eventItr.Topic_ID__c)){
	                    eventMap.get(eventItr.Topic_ID__c).add(eventItr);
	                }
	                else{
	                    List<Event__c> eventLst = new List<Event__c>();
	                    eventLst.add(eventItr);
	                    eventMap.put(eventItr.Topic_ID__c,eventLst);
	                }
	         }
         }
         CreateQueue.createQueuewithHandler(eventMap);
    }
    /**
     * Method to parse jason content available in retrieverInfo field of event record.
     * Argument: RetrieverInfo field value.
     * Return: Map of field name and field value of jason content.
     */
    private static Map<String, String> retrieverMap(String retInfo){
    	String retrieverInfo = '\''+retInfo+'\'';
    	Map<String, String> retrievedValMap = new Map<String, String>();
    	JSONParser parser = JSON.createParser(retInfo);
    	parser.nextToken();

    	while (parser.nextToken() != null){
			parser.nextValue();
			String fieldName = parser.getCurrentName();			
			String fieldVal = parser.getText();
			if(fieldName != null && fieldVal != null){
				retrievedValMap.put(fieldName, fieldVal);
			}
    	}
    	return retrievedValMap;
    }
}