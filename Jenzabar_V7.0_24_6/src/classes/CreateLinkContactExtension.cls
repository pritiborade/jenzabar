public with sharing class CreateLinkContactExtension {
    
      private static final String CONTACT_APINAME = 'Contact';
      private static final String RECORDTYPE_APINAME = 'recordTypeId';
      private static final String LASTNAME_APINAME = 'LastName';
      private static final String FIRSTNAME_APINAME = 'FirstName';
      
      private Contact contactSObj;
      public Contact newContactSobj{get;set;}
      private List<String> commonFields;
      public String selectedRecordTypeId{get;set;}
      public String errorMessage{get;set;}
      Map<Id,RecordType> contactRecordTypeMap;
      public String contactId;
      public String insertText{get; set;}
      public String mode{get;set;}
      public List<Contact_Link__c> contactListSelectOptions;
      public List<ID>SelOptContList;
      public boolean flagPopContactDetail{get; set;}
      public boolean flagPopupErrorMessage{get; set;}
      
      public CreateLinkContactExtension(){
      	   flagPopContactDetail = true;
      	   
           mode = ApexPages.currentPage().getParameters().get('mode');
           newContactSobj = new Contact();   
           contactId = ApexPages.currentPage().getParameters().get('contactId');          
           contactSObj = [Select c.LastName, c.Id, c.Gender__c, c.FirstName, c.Email, c.Death_Date__c, 
                          c.Birthdate, c.Age__c, c.AccountId, c.Academic_Standing_Type__c,c.Salutation,
                          recordTypeId,recordType.Name From Contact c where id=:String.escapeSingleQuotes(contactId)];
                       
      }
      public List<SelectOption> getContactRecordTypes(){
           List<SelectOption> options = new List<SelectOption>();
           SelOptContList = NEW List<ID>();
           contactRecordTypeMap = new Map<Id,RecordType>([Select r.Id,r.SobjectType, r.IsActive, 
                                                          r.DeveloperName From RecordType r 
                                                          where sObjectType =: CONTACT_APINAME and 
                                                          isActive= true]);
           contactListSelectOptions = new List<Contact_Link__c>();
		   contactListSelectOptions =  [select id,Name,Applicant_Id__c,Instructor_Id__c,Student_Id__c, Student_Id__r.recordTypeId, Applicant_Id__r.recordTypeId, Instructor_Id__r.recordTypeId from Contact_Link__c where Applicant_Id__c =:contactId OR 
      	                                                 Instructor_Id__c =:contactId OR 
      	                                                 Student_Id__c =:contactId];
			system.debug('Called list options');                               
			if(contactListSelectOptions.size()>0){
				
				if(contactListSelectOptions[0].Applicant_Id__c == contactId){
					
					if(contactListSelectOptions[0].Instructor_Id__c == null && contactListSelectOptions[0].Student_Id__c != null)
						SelOptContList.add(contactListSelectOptions[0].Student_Id__r.recordTypeId);
						//options.add(contactListSelectOptions[0].Student_Id__r.recordTypeId,contactListSelectOptions[0].Student_Id__r.recordTypeId);
						
					else if(contactListSelectOptions[0].Student_Id__c == null && contactListSelectOptions[0].Instructor_Id__c != null)
						SelOptContList.add(contactListSelectOptions[0].Instructor_Id__r.recordTypeId);
						
					else if(contactListSelectOptions[0].Student_Id__c == null && contactListSelectOptions[0].Instructor_Id__c == null){
						//SelOptContList.add(contactListSelectOptions[0].Instructor_Id__c);
						//SelOptContList.add(contactListSelectOptions[0].Student_Id__c);
					}
				
					
				}
				
				else if(contactListSelectOptions[0].Instructor_Id__c == contactId){
					
					if(contactListSelectOptions[0].Applicant_Id__c == null && contactListSelectOptions[0].Student_Id__c != null){
						system.debug('in here of instructor and applicant');
						SelOptContList.add(contactListSelectOptions[0].Student_Id__r.recordTypeId);
						
					}
						
						
					else if(contactListSelectOptions[0].Student_Id__c == null && contactListSelectOptions[0].Applicant_Id__c != null){
						system.debug('in here of instructor and student');
						SelOptContList.add(contactListSelectOptions[0].Applicant_Id__r.recordTypeId);
						}
						
					else if(contactListSelectOptions[0].Student_Id__c == null && contactListSelectOptions[0].Applicant_Id__c == null){
						//SelOptContList.add(contactListSelectOptions[0].Applicant_Id__c);
						//SelOptContList.add(contactListSelectOptions[0].Student_Id__c);
					}
					
					
				}
				
				else if(contactListSelectOptions[0].Student_Id__c == contactId){
					
					if(contactListSelectOptions[0].Instructor_Id__c == null && contactListSelectOptions[0].Applicant_Id__c != null)
						SelOptContList.add(contactListSelectOptions[0].Applicant_Id__r.recordTypeId);
						
					else if(contactListSelectOptions[0].Applicant_Id__c == null && contactListSelectOptions[0].Instructor_Id__c != null)
						SelOptContList.add(contactListSelectOptions[0].Instructor_Id__r.recordTypeId);
					
					else if(contactListSelectOptions[0].Applicant_Id__c == null && contactListSelectOptions[0].Instructor_Id__c == null){
						//SelOptContList.add(contactListSelectOptions[0].Instructor_Id__c);
						//SelOptContList.add(contactListSelectOptions[0].Applicant_Id__c);
					}
					
					
					
					
				}
				
			}	
	          
	                                                  
			 	                                                      
           for(ID rtId : contactRecordTypeMap.keySet()){
           	    RecordType rt = contactRecordTypeMap.get(rtId);
           	    //system.debug('The rt.id is:' +SelOptContList[0]);
           	    //system.debug('The Value is:' +SelOptContList[0]);
           	    //system.debug('The value is:' +ID.valueOf(String.valueOf(contactSObj.get(RECORDTYPE_APINAME))));
 				if(SelOptContList.size()>0){
 					flagPopContactDetail = true;
      				
 					system.debug('The rt.id is:' +SelOptContList[0]);
           	    	system.debug('The Value is:' +SelOptContList[0]);
           	    	system.debug('The value is:' +ID.valueOf(String.valueOf(contactSObj.get(RECORDTYPE_APINAME))));
 					
           	    if(contactSObj !=null && rt.id != ID.valueOf(String.valueOf(contactSObj.get(RECORDTYPE_APINAME))) && rt.id!=SelOptContList[0]){
           	    	 options.add(new SelectOption(rt.Id,rt.DeveloperName));
           	    }
           	    
 			  }
 			  
 			  else{
 			  	system.debug('No contact relationships exist');
 			  	flagPopContactDetail = false;
      			
 			  	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'There already exists Contact association for all the Record Types');
				ApexPages.addMessage(myMsg);
				return null;
 			  }
           }
           return options;
      }
      private void fetchCommonFields(){
           
            TriggerSetting__c contactCS = TriggerSetting__c.getValues(CONTACT_APINAME);
            commonFields = new List<String>(); 
            if(contactCS != null){
                 if(contactCS.Common_Fields__c.contains('\n')){
                      commonFields = contactCS.Common_Fields__c.split('\n');
                 }
                 else{
                      commonFields = contactCS.Common_Fields__c.split(',');
                 }
            }
            system.debug('commonFields----'+commonFields);
      }
      private void populateCommonFields(){
            fetchCommonFields();
            newContactSobj.put(LASTNAME_APINAME,String.valueOf(contactSObj.get(LASTNAME_APINAME)));
            newContactSobj.put(FIRSTNAME_APINAME,String.valueOf(contactSObj.get(FIRSTNAME_APINAME)));
            
            newContactSobj.put(RECORDTYPE_APINAME,selectedRecordTypeId);
            
            Map <String, String> labelToAPIName = new Map <String, String> ();
            Map<String, Schema.SObjectField> fieldsMap = Schema.SObjectType.Contact.fields.getMap();
            
            for (Schema.SObjectField field : fieldsMap.values()){
                labelToAPIName.put(field.getDescribe().getLabel(), field.getDescribe().getName());
            }
             
            for(String fieldAPIName : commonFields){
                 
                  Schema.Sobjectfield field = fieldsMap.get(fieldAPIName);   
                  system.debug('field-----'+field);       
                  if(field!= null){       
                      Schema.Describefieldresult fieldDesc = field.getDescribe();
                      Schema.DisplayType fldType = fieldDesc.getType();
                      system.debug('-----type----'+fldType);
                      if(String.valueOf(fldType) == 'Boolean'){
                             newContactSobj.put(fieldAPIName,Boolean.valueOf(contactSObj.get(fieldAPIName)));
                      }
                      else if(String.valueOf(fldType) == 'Double'){
                          newContactSobj.put(fieldAPIName,Double.valueOf(contactSObj.get(fieldAPIName)));
                      }
                      else{
                           newContactSobj.put(fieldAPIName,String.valueOf(contactSObj.get(fieldAPIName)));
                      }
                  }
                  else{
                       system.debug('Field API not found -----');
                  }
            }  
      }
      public void createContact(){
            populateCommonFields();
            Contact_Link__c contactLinkInst = new Contact_Link__c();
            PageReference recordDetailPage = null;
            String selectedRecordTypeName;
            if(contactRecordTypeMap.get(ID.valueOf(selectedRecordTypeId)) != null){
                 selectedRecordTypeName = contactRecordTypeMap.get(ID.valueOf(selectedRecordTypeId)).developerName;
            }
            Savepoint sp = Database.setSavepoint();
            try{            
                system.debug('newContactSobj-----'+newContactSobj);
                insert newContactSobj;  
                system.debug('Records inserted.............');            
                List<Contact_Link__c> contactLinkList = [select id,Name,Applicant_Id__c,Instructor_Id__c,Student_Id__c, Applicant_Id__r.Name, Instructor_Id__r.Name, Student_Id__r.Name
                                                         from Contact_Link__c where Applicant_Id__c =:contactSObj.id OR 
                                                         Instructor_Id__c =:contactSObj.id OR 
                                                         Student_Id__c =:contactSObj.id];
                
                system.debug('after contactLinkList'); 
                //system.debug('contactLinkList-----'+contactLinkList);  
                //system.debug('selectedRecordTypeName------'+selectedRecordTypeName);    
                
                //by chaitanya
                
                Contact contactFields = [select RecordTypeId, RecordType.Name from Contact where Id = :contactId];
                
                
                //system.debug('The recordtype name is' +contactLinkList[0].Applicant_Id__r.Name +' or'+contactLinkList[0].Instructor_Id__r.Name+' or:'+contactLinkList[0].Student_Id__r.Name);
                
                system.debug('after contactFields ');
                system.debug('contactId is********** '+contactId);
                      
                List<Contact_Link__c> contactLinkSourceValues = [select id,Name,Applicant_Id__c,Instructor_Id__c,Student_Id__c from Contact_Link__c where Applicant_Id__c =:contactId OR 
                                                         Instructor_Id__c =:contactId OR 
                                                         Student_Id__c =:contactId];
               if(contactLinkSourceValues.size()>0){      
               system.debug('contactLinkSourceValues');   
               system.debug('Source record type is:' +contactFields.RecordType.Name);
               system.debug('The selected record type is:' +selectedRecordTypeName);
               system.debug('The values are applicant:' +contactLinkSourceValues[0].Applicant_Id__c +' and student:'+contactLinkSourceValues[0].Student_Id__c+' and instructor:'+contactLinkSourceValues[0].Instructor_Id__c);                                    
               system.debug('newContactSobj id is:'+newContactSobj.Id);
                  
                if(selectedRecordTypeName.equalsIgnoreCase('Instructor') && contactLinkSourceValues[0].Instructor_Id__c!=null){
                system.debug('In here of Instructor*****************');
                errorMessage = 'There already exists an association for Instructor, please remove the existing link before creating New.';
                //insertText = contactFields.RecordType.Name+ 'Instructor';
                //displayPopUp = true;
               }   
                                                         
               else if(selectedRecordTypeName.equals('Applicant') && contactLinkSourceValues[0].Applicant_Id__c!=null){
                system.debug('In here of applicant*****************');
                errorMessage = 'There already exists an association for Applicant, please remove the existing link before creating New.';
                //insertText = contactFields.RecordType.Name+ 'Applicant';
                //displayPopUp = true;
               }
               
               else if(selectedRecordTypeName.equals('Student') && contactLinkSourceValues[0].Student_Id__c!=null){
                system.debug('In here of Student*****************');
                errorMessage = 'There already exists an association for Student, please remove the existing link before creating New.';
                //insertText = contactFields.RecordType.Name+ 'Student';
                //displayPopUp = true;
               }

            }

        else{
                Contact_Link__c contactLinkNewRecord = new Contact_Link__c();
                if(selectedRecordTypeName.equalsIgnoreCase('Instructor') && contactFields.RecordType.Name.equalsIgnoreCase('Applicant')){
                system.debug('In here of Instructor & applicant*****************');
                system.debug('The Id is:'+newContactSobj.Id);
                system.debug('The contact id is:'+contactId);
                //errorMessage = 'There already exists an association for Instructor, please remove the existing link before creating New.';
                //insertText = contactFields.RecordType.Name+ 'Instructor';
                //displayPopUp = true;
                
                contactLinkNewRecord.Instructor_Id__c = newContactSobj.Id;
                contactLinkNewRecord.Applicant_Id__c = contactId;
                insert contactLinkNewRecord;
                errorMessage = 'The contact and association have been created successfully';
               }   
                                                         
               else if(selectedRecordTypeName.equalsIgnoreCase('Instructor') && contactFields.RecordType.Name.equalsIgnoreCase('Student')){
                system.debug('In here of Instructor & Student*****************');
                system.debug('The Id is:'+newContactSobj.Id);
                system.debug('The contact id is:'+contactId);
                
                //errorMessage = 'There already exists an association for Instructor, please remove the existing link before creating New.';
                //insertText = contactFields.RecordType.Name+ 'Instructor';
                //displayPopUp = true;
                
                contactLinkNewRecord.Instructor_Id__c = newContactSobj.Id;
                contactLinkNewRecord.Student_Id__c= contactId;
                insert contactLinkNewRecord;
                errorMessage = 'The contact and association have been created successfully';
               }
               
               else if(selectedRecordTypeName.equalsIgnoreCase('Applicant') && contactFields.RecordType.Name.equalsIgnoreCase('Instructor')){
                system.debug('In here of Applicant & Instructor*****************');
                system.debug('The Id is:'+newContactSobj.Id);
                system.debug('The contact id is:'+contactId);
                //errorMessage = 'There already exists an association for Instructor, please remove the existing link before creating New.';
                //insertText = contactFields.RecordType.Name+ 'Instructor';
                //displayPopUp = true;
                
                contactLinkNewRecord.Applicant_Id__c= newContactSobj.Id;
                contactLinkNewRecord.Instructor_Id__c = contactId;
                insert contactLinkNewRecord;
                errorMessage = 'The contact and association have been created successfully';
               }
               
              
               else if(selectedRecordTypeName.equalsIgnoreCase('Student') && contactFields.RecordType.Name.equalsIgnoreCase('Instructor')){
                system.debug('In here of Student& Instructor*****************');
                system.debug('The Id is:'+newContactSobj.Id);
                system.debug('The contact id is:'+contactId);
                //errorMessage = 'There already exists an association for Instructor, please remove the existing link before creating New.';
                //insertText = contactFields.RecordType.Name+ 'Instructor';
                //displayPopUp = true;
                
                contactLinkNewRecord.Student_Id__c= newContactSobj.Id;
                contactLinkNewRecord.Instructor_Id__c = contactId;
                insert contactLinkNewRecord;
                errorMessage = 'The contact and association have been created successfully';
               }
               
               else if(selectedRecordTypeName.equalsIgnoreCase('Applicant') && contactFields.RecordType.Name.equalsIgnoreCase('Student')){
                system.debug('In here of Applicant& Student*****************');
                system.debug('The Id is:'+newContactSobj.Id);
                system.debug('The contact id is:'+contactId);
                //errorMessage = 'There already exists an association for Instructor, please remove the existing link before creating New.';
                //insertText = contactFields.RecordType.Name+ 'Instructor';
                //displayPopUp = true;
                
                contactLinkNewRecord.Applicant_Id__c= newContactSobj.Id;
                contactLinkNewRecord.Student_Id__c= contactId;
                insert contactLinkNewRecord;
                errorMessage = 'The contact and association have been created successfully';
               }
               
               else if(selectedRecordTypeName.equalsIgnoreCase('Student') && contactFields.RecordType.Name.equalsIgnoreCase('Applicant')){
                system.debug('In here of Student& Applicant*****************');
                system.debug('The Id is:'+newContactSobj.Id);
                system.debug('The contact id is:'+contactId);
                //errorMessage = 'There already exists an association for Instructor, please remove the existing link before creating New.';
                //insertText = contactFields.RecordType.Name+ 'Instructor';
                //displayPopUp = true;
                
                contactLinkNewRecord.Student_Id__c= newContactSobj.Id;
                contactLinkNewRecord.Applicant_Id__c = contactId;
                insert contactLinkNewRecord;
                errorMessage = 'The contact and association have been created successfully';
               }
            
            

        }
                              
                /*if(contactLinkList == null || contactLinkList.size() == 0){
                     if(contactSObj.RecordType.Name == System.Label.Contact_Applicant_RecordType){
                           contactLinkInst.Applicant_Id__c = contactSObj.id;
                     }
                     else if(contactSObj.RecordType.Name == System.Label.Contact_Student_RecordType){
                          contactLinkInst.Student_Id__c = contactSObj.id;
                     }
                     else if(contactSObj.RecordType.Name == System.Label.Contact_Instructor_RecordType){
                          contactLinkInst.Instructor_Id__c = contactSObj.id;
                     }
                     if(selectedRecordTypeName == System.Label.Contact_Applicant_RecordType){
                           contactLinkInst.Applicant_Id__c = newContactSobj.id;
                     }
                     else if(selectedRecordTypeName == System.Label.Contact_Student_RecordType){
                          contactLinkInst.Student_Id__c = newContactSobj.id;
                     }
                     else if(selectedRecordTypeName == System.Label.Contact_Instructor_RecordType){
                          contactLinkInst.Instructor_Id__c = newContactSobj.id;
                     }
                     system.debug('contactLinkInst----'+contactLinkInst);
                     insert contactLinkInst;
                }
                else{                
                     if(selectedRecordTypeName == System.Label.Contact_Applicant_RecordType){
                           contactLinkList[0].Applicant_Id__c = newContactSobj.id;
                     }
                     else if(selectedRecordTypeName == System.Label.Contact_Student_RecordType){
                          contactLinkList[0].Student_Id__c = newContactSobj.id;
                     }
                     else if(selectedRecordTypeName == System.Label.Contact_Instructor_RecordType){
                          contactLinkList[0].Instructor_Id__c = newContactSobj.id;
                     }  
                     system.debug('contactLinkList[0]----'+contactLinkList[0]);
                     update contactLinkList[0];
                }*/
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Problem'));
            }
            catch(Exception ex){
                 system.debug('Exception occurs on insert-----'+ex.getMessage());
                 errorMessage = ex.getMessage();
                 //Database.rollback(sp);
            }
      } 

}