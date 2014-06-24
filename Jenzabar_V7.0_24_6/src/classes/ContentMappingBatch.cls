//Class for converting Local Fields of Content Mapping object to JSON format
global class ContentMappingBatch implements Database.Batchable<sObject>, Database.Stateful{    
        global Map<String, String> fieldsToJson;
        global Map<String, Schema.SobjectField> fieldsMap;     
      
      //Returns list of all Content Mapping records  
        global Database.querylocator start(Database.BatchableContext BC){            
            List<System__c> systemLst = [select Id from System__c];
            String query = 'Select LocalObject__c, Local_Field__c, Status__c from Content_Mapping__c where Source_ID__c IN :systemLst and Status__c=false';            
            return Database.getQueryLocator(query);
		}
        
        //Iterates over each of the records and converts the local fields to JSON format using serialize method              
        global void execute(Database.BatchableContext BC, List<sObject> scope){            
            List <Content_Mapping__c> updateContentMapList = new List<Content_Mapping__c>();
            for(sObject sobjectIter : scope){
	                Content_Mapping__c contentMapping = (Content_Mapping__c)sobjectIter;
					
					try{						
						if(contentMapping.LocalObject__c != null){		             
			                String objectName = contentMapping.LocalObject__c;
			                Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
			                Schema.SObjectType sobjType = gd.get(objectName);			                
			                fieldsMap = sobjType.getDescribe().fields.getMap();//getting the info for all the fields of the LocalObject__c
			                fieldsToJson = new Map<String, String>();		
							
							if(contentMapping.Local_Field__c != null){
			                    Schema.SObjectField localFieldVal = fieldsMap.get(contentMapping.Local_Field__c);//fetching the field info for the Local_Field__c			                    
			                    Schema.DescribeFieldResult localFieldResult = localFieldVal.getDescribe();//getting the description of the Local_Field__c			                    
			                    String localFieldResultval = localFieldResult.getType().name();
			                    List<SObjectType> referenceObject = new List<SObjectType>();			                    
			                   
			                    
			                    //If the Local_Field__c is of Data Type Reference
			                    if(localFieldResultval.equalsIgnoreCase('Reference')){		
			                        fieldsToJson.put(System.Label.Content_Mapping_FieldName,contentMapping.Local_Field__c);
			                        fieldsToJson.put(System.Label.Content_Mapping_Lookup,'LOOKUP');
			                        fieldsToJson.put(System.Label.Content_Mappng_ReferenceTo,String.valueOf(localFieldResult.getReferenceTo()));
			                        contentMapping.Local_Field__c = JSON.serialize(fieldsToJson);//serializing the Local_Field__c content
			                        contentMapping.Status__c = true;
			                    } 
			                    else {
			                        fieldsToJson.put(System.Label.Content_Mapping_FieldName,contentMapping.Local_Field__c);
			                        fieldsToJson.put(System.Label.Content_Mapping_Datatype,localFieldResultval);
			                        contentMapping.Local_Field__c = JSON.serialize(fieldsToJson);//serializing the Local_Field__c content
			                        contentMapping.Status__c = true;               
			                    }
			                    			                    
			                    updateContentMapList.add(contentMapping); 			
			                    
							}
						} 
					}
					catch(Exception ex){
					}
                }
                update updateContentMapList;//updating the Content Mapping Record
            }     
            
            global void finish(Database.BatchableContext BC){

 			// Get the AsyncApexJob that represents the Batch job using the Id from the BatchableContext
				 AsyncApexJob asynApexjob = [SELECT Id, 
							 						Status, 
							 						NumberOfErrors, 
							 						JobItemsProcessed,
							  						TotalJobItems, 
							  						CreatedBy.Email, 
							  						ExtendedStatus
							  						FROM AsyncApexJob 
							  						WHERE Id = :BC.getJobId()];
				 
				 // Email the Batch Job's submitter that the Job is finished.
				 Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				 String[] toAddresses = new String[] {asynApexjob.CreatedBy.Email};
				 mail.setToAddresses(toAddresses);
				 mail.setSubject('Batch Job Status: ' + asynApexjob.Status);
				 mail.setPlainTextBody('The batch Apex job processed ' + asynApexjob.TotalJobItems +
				  ' batches with '+ asynApexjob.NumberOfErrors + ' failures. ExtendedStatus: ' + asynApexjob.ExtendedStatus);
				 Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			}
				            
}