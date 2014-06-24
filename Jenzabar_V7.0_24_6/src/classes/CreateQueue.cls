public with sharing class CreateQueue {
    
    public class queuerWrapper{
        public Queue__c queueRec;
        public String jsonContent;
        public String queuer;
        public String eventId;
        
        public queuerWrapper(Queue__c queRec,String pQueuer, String pJson,String pEventId){
            queueRec = queRec;
            queuer = pQueuer;
            jsonContent = pJson;
            eventId = pEventId;
        }
    }
    
    
    public static void createQueuewithHandler(Map<id,List<Event__c>> eventMap){
        
         List<Queue__c> queuetoInsert = new List<Queue__c>();
         Integer counter = 0;
         for(Event_Queuer__c eventQueuerItr : [SELECT id,
                                                     Topic_ID__c, 
                                                     SubscriberID__c, 
                                                     Queuer__c
                                                     FROM Event_Queuer__c 
                                                     WHERE Topic_ID__c =: eventMap.keySet()]){
              
           if(eventMap.containsKey(eventQueuerItr.Topic_ID__c)){
               for(Event__c eventItr : eventMap.get(eventQueuerItr.Topic_ID__c)){
                    System.debug('===counter==='+(counter++));
                    Queue__c queRec = new Queue__c();
                    queRec.Event_ID__c = eventItr.id;
                    queRec.Event_Queuer_ID__c = eventQueuerItr.id;
                    queRec.Topic_Id__c = eventItr.Topic_ID__c;
                    queRec.Queue_State_ID__c = Label.Event_New;
                    queRec.Source_System_Id__c = eventItr.SourceSystem_ID__c;
                    queuetoInsert.add(queRec);      
               } 
           }
               
               //queuerWrapLst.add(new queuerWrapper(queueRec,eventQueuerItr.Queuer__c,jsonContent,eventId));
        }
        
        if(!queuetoInsert.isEmpty()){
            System.debug('====queuetoInsert==='+queuetoInsert);
            insert queuetoInsert;
        }
    }
    
    
    public static void createQueueRec(String topicId, String eventId,String jsonContent){
        
        List<Queue__c> queueLst = new List<Queue__c>();
        List<queuerWrapper> queuerWrapLst = new List<queuerWrapper>();
        for(Event_Queuer__c eventQueuerItr : [SELECT id,
                                                     Topic_ID__c, 
                                                     SubscriberID__c, 
                                                     Queuer__c
                                                     FROM Event_Queuer__c 
                                                     WHERE Topic_ID__c =: topicId]){
                                               
            Queue__c queueRec = new Queue__c();
            queueRec.Event_ID__c = eventId;
            queueRec.Event_Queuer_ID__c = eventQueuerItr.id;
            queueRec.Queue_State_ID__c = 'New';
            queueRec.Retriever__c = '';
            queuerWrapLst.add(new queuerWrapper(queueRec,eventQueuerItr.Queuer__c,jsonContent,eventId));
        }
        
        if(!queuerWrapLst.isEmpty()){
            CreateQueue.createQueueRetriever(queuerWrapLst);
        }
        
        if(!queueLst.isEmpty()){
            insert queueLst;
        }
    }
    
    public static void createQueueRetriever(List<queuerWrapper> wrapList){
        List<Queue__c> queueLst = new List<Queue__c>();
        
        for(queuerWrapper queueWrapItr : wrapList){
            JSONGenerator jsonGenObj = JSON.createGenerator(true);
            JSONParser jsonParObj = JSON.createParser(queueWrapItr.jsonContent);
            jsonGenObj.writeStartObject(); 
            if(!String.isBlank(QueuerHandlers__c.getAll().get(queueWrapItr.queuer).Handler_Name__c)){
                jsonGenObj.writeStringField('HandlerName',QueuerHandlers__c.getAll().get(queueWrapItr.queuer).Handler_Name__c);
            }
            jsonGenObj.writeObjectField('EventId',queueWrapItr.eventId);
            jsonGenObj.writeObjectField('JSONContent',queueWrapItr.jsonContent);
            jsonGenObj.writeEndObject();
            queueWrapItr.queueRec.Retriever__c =  jsonGenObj.getAsString();
            queueLst.add(queueWrapItr.queueRec);
        }
        
        if(!queueLst.isEmpty()){
            insert queueLst;
        }
        System.debug('====queueLst===='+queueLst);
    }
}