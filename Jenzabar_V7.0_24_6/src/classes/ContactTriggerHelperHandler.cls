public with sharing class ContactTriggerHelperHandler {

    public List<Contact> onAfterUpdate(Map<Id,Contact> oldMap,Map<Id,Contact> newMap){
        Map<Id,Contact> conToUpdateLst = new Map<Id,Contact>();
        Set<Id> contactId = new Set<Id>();
        Set<Id> conIdswithCLink = new Set<Id>();
        List<Contact> contactList = new List<Contact>();
        Map<Id,Contact> contactMap = new Map<Id,Contact>();
        Map<String, Schema.SObjectField> ContactFieldsMap = Schema.SObjectType.Contact.fields.getMap();
        List<String> commonFieldStrings = new List<String>();
        
        if(!String.isEmpty(TriggerSetting__c.getAll().get('Contact').Common_Fields__c)){
            commonFieldStrings = ((TriggerSetting__c.getAll().get('Contact').Common_Fields__c).replaceAll( '\\s+', '')).split(',');
        }
        
        for(Contact conItr : newMap.values()){
            
            Contact conOldRec = new Contact();
            conOldRec = oldMap.get(conItr.id);
            
            Contact conNewRec = new Contact();
            conNewRec = NewMap.get(conItr.id);
            
            if(!commonFieldStrings.isEmpty()){
                for(String strItr : commonFieldStrings){
                    if(ContactFieldsMap.containsKey(strItr)){
                        if(conOldRec.get(strItr) != conNewRec.get(strItr)){
                            contactId.add(conItr.id);
                        }
                    }
                    else{
                        conItr.addError('Invalid Field Name : '+ strItr + 'in Custom Setting.');
                    }
                }
            }
            System.debug('====='+contactId);
        }
        
        for(Contact_Link__c cLinkItr : [SELECT Applicant_Id__c,Instructor_Id__c,Student_Id__c FROM Contact_Link__c WHERE Applicant_Id__c IN: contactId or Instructor_Id__c IN: contactId or Student_Id__c IN: contactId]){
        	if(cLinkItr.Applicant_Id__c != null){
        		conIdswithCLink.add(cLinkItr.Applicant_Id__c);
        	}
        	if(cLinkItr.Instructor_Id__c != null){
        		conIdswithCLink.add(cLinkItr.Instructor_Id__c);
        	}
        	if(cLinkItr.Student_Id__c != null){
        		conIdswithCLink.add(cLinkItr.Student_Id__c);
        	}
        }
        
        String theQuery = 'SELECT ';
        for(Schema.SObjectField s : ContactFieldsMap.values()) {
            String theName = s.getDescribe().getName();
            theQuery += theName + ',';
        }
        theQuery = theQuery.subString(0, theQuery.length() - 1);
        theQuery += ' FROM Contact';
        theQuery += ' WHERE Id IN: xxx';
       
        System.debug('theQuery==='+theQuery);
        if(!conIdswithCLink.isEmpty()){
        	contactList = Database.query(theQuery.replace('xxx','conIdswithCLink')); 
        }
        
        if(!contactList.isEmpty()){ 
            for(Contact conLstItr : contactList){
                contactMap.put(conLstItr.id,conLstItr);
            }
        }
        
        if(!contactId.isEmpty()){
            String queryString = getQuery()+'WHERE Id IN : xxx';
            System.debug('===queryString'+queryString);
            List<contact> conList = Database.query(queryString.replace('xxx','contactId'));
            System.debug('conList==='+conList);
        }
        
        for(Contact_Link__c contactLinkItr : [SELECT Applicant_Id__c,Instructor_Id__c,Student_Id__c FROM Contact_Link__c WHERE Applicant_Id__c IN: contactId or Instructor_Id__c IN: contactId or Student_Id__c IN: contactId ]){
            
            Contact ApplicantCon = new Contact();
            if(contactMap.containsKey(contactLinkItr.Applicant_Id__c)){
                ApplicantCon = contactMap.get(contactLinkItr.Applicant_Id__c);
            }
            
            Contact InstructorCon = new Contact();
            if(contactMap.containsKey(contactLinkItr.Instructor_Id__c)){
                InstructorCon = contactMap.get(contactLinkItr.Instructor_Id__c);
            }
            
            Contact StudentCon = new Contact();
            if(contactMap.containsKey(contactLinkItr.Student_Id__c)){
                StudentCon = contactMap.get(contactLinkItr.Student_Id__c);
            }
            
            if(newMap.containsKey(contactLinkItr.Applicant_Id__c)){
                
                if(InstructorCon != null){
                    for(String strItr : commonFieldStrings){
                        InstructorCon.put(strItr,ApplicantCon.get(strItr));
                    }
                    conToUpdateLst.put(InstructorCon.id,InstructorCon);
                }
                
                if(StudentCon != null){
                    for(String strItr : commonFieldStrings){
                        StudentCon.put(strItr,ApplicantCon.get(strItr));
                    }
                    conToUpdateLst.put(StudentCon.id,StudentCon);
                }
            }
            
            else if(newMap.containsKey(contactLinkItr.Instructor_Id__c)){
                
                if(ApplicantCon != null){
                    for(String strItr : commonFieldStrings){
                        ApplicantCon.put(strItr,InstructorCon.get(strItr));
                    }
                    conToUpdateLst.put(ApplicantCon.id,ApplicantCon);
                }
                
                if(StudentCon != null){
                    for(String strItr : commonFieldStrings){
                        StudentCon.put(strItr,InstructorCon.get(strItr));
                    }
                    conToUpdateLst.put(StudentCon.id,StudentCon);
                }
            }
            
            else if(newMap.containsKey(contactLinkItr.Student_Id__c)){
                if(InstructorCon != null){
                    
                    for(String strItr : commonFieldStrings){
                        InstructorCon.put(strItr,StudentCon.get(strItr));
                    }
                    conToUpdateLst.put(InstructorCon.id,InstructorCon);
                }
                
                if(ApplicantCon != null){
                    for(String strItr : commonFieldStrings){
                        ApplicantCon.put(strItr,StudentCon.get(strItr));
                    }
                    conToUpdateLst.put(ApplicantCon.id,ApplicantCon);
                }
            }
        }
        
        ContactTriggerUtil.triggerFlag1 = false;
        System.debug('contactListtoUpdate==='+conToUpdateLst);
        return conToUpdateLst.values();
    } 
    
    public String getQuery(){
        If(!String.isEmpty(TriggerSetting__c.getAll().get('Contact').Common_Fields__c)){
            return 'SELECT Id,'+TriggerSetting__c.getAll().get('Contact').Common_Fields__c+' FROM Contact ';
        }
        return 'SELECT Id FROM Contact';
    }
}