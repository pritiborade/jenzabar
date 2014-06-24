global class ContentMappingScheduler implements Schedulable{
 global void execute(SchedulableContext sc) {
      ContentMappingBatch batchContent = new ContentMappingBatch(); 
      database.executebatch(batchContent);
   }
}