public with sharing class CaseTriggerHelperHandler {

	public List<Contact> contactList{get; set;}
	public List<Lead> leadList{get; set;}
	public String descriptionField{get; set;}
	public String baseUrl{get; set;}

	public void searchAddContact(List<Case> newCase){
		descriptionField = '';
		contactList = new List<Contact>();
		leadList = new List<Lead>();
		
		//If the External Id is given
		if(newCase[0].Contact_External_Id__c != null){
			contactList = [select Id from Contact where Person_Id__c = :newCase[0].Contact_External_Id__c];
		
		//Incase the Contact exists containing the External Id
			if(contactList.size()>=1){
				newCase[0].ContactId = contactList[0].Id;

			}
			
		//Incase of no Contacts with the External Id
			else if(contactList.size()==0){
				Contact contactObj = new Contact();
				if(newCase[0].Name__c!=null)
				contactObj.LastName = newCase[0].Name__c;
				else
				contactObj.LastName = newCase[0].Contact_External_Id__c;
				contactObj.Person_Id__c = newCase[0].Contact_External_Id__c;				
				insert contactObj;				
				newCase[0].ContactId = contactObj.Id;
			}
		}
		
		//If name and Email are provided with no External Id
		else if((newCase[0].Name__c != null && newCase[0].SuppliedEmail!=null) && newCase[0].Contact_External_Id__c == null){			
			contactList = [select Id from Contact where Name = :newCase[0].Name__c AND Email = :newCase[0].SuppliedEmail];
			leadList = [select Id, Description from Lead where Name = :newCase[0].Name__c AND Email = :newCase[0].SuppliedEmail];
		
		//In case of single Contact with the given Name and Email	
			if(contactList.size()==1){
				newCase[0].ContactId = contactList[0].Id;
			}
		
		//In case of single Lead with the given Name and Email	
			if(leadList.size()==1){
				baseUrl = URL.getSalesforceBaseUrl().toExternalForm()+'/'+leadList[0].Id;
				newCase[0].Lead_Link__c = baseUrl;
			}
			
			
		//In case of more than one Contact with the given Name and Email - No values of mapped Contacts are stored
			if(contactList.size()>1){
				for(Contact contactIter : contactList){
					descriptionField = descriptionField + ','+contactIter.Id;
				}
				if(descriptionField.startsWith(','))
				descriptionField = descriptionField.subString(1,descriptionField.length());				
			}
			
		//In case of more than one Lead with the given Name and Email - No values of mapped Leads are stored
			if(leadList.size()>1){
				for(Lead leadIterator : leadList){
					descriptionField = descriptionField + ','+leadIterator.Id;
				}
				if(descriptionField.startsWith(','))
				descriptionField = descriptionField.subString(1,descriptionField.length());
			}
		}
	}
	
	//For update
	public void updateContact(List<Case> newCase, List<Case> updatedCase){

		descriptionField = '';
		contactList = new List<Contact>();
		leadList = new List<Lead>();
		
		//If the External Id is given
		if(newCase[0].Contact_External_Id__c != null){
			contactList = [select Id from Contact where Person_Id__c = :newCase[0].Contact_External_Id__c];
			if(newCase[0].Name__c != null && newCase[0].SuppliedEmail!=null)
			leadList = [select Id, Description from Lead where Name = :newCase[0].Name__c AND Email = :newCase[0].SuppliedEmail];
		
		//Incase the Contact exists containing the External Id
			if(contactList.size()>=1){
				newCase[0].ContactId = contactList[0].Id;
				if(leadList.size()!=1)
				newCase[0].Lead_Link__c = null;
			}
			
		//Incase no Contact exists with the External Id
			else if(contactList.size()==0){
				Contact contactObj = new Contact();				
				if(newCase[0].Name__c!=null)
				contactObj.LastName = newCase[0].Name__c;
				else
				contactObj.LastName = newCase[0].Contact_External_Id__c;
				contactObj.Person_Id__c = newCase[0].Contact_External_Id__c;				
				Database.insert(contactObj);				
				newCase[0].ContactId = contactObj.Id;
				if(leadList.size()!=1)
				newCase[0].Lead_Link__c = null;
			}
		}
		
		//Incase Name and Email fields values are provided 
		else if((newCase[0].Name__c != null && newCase[0].SuppliedEmail!=null) && newCase[0].Contact_External_Id__c == null){
			contactList = [select Id from Contact where Name = :newCase[0].Name__c AND Email = :newCase[0].SuppliedEmail];
			leadList = [select Id, Description from Lead where Name = :newCase[0].Name__c AND Email = :newCase[0].SuppliedEmail];
		
		//Incase a single contact is matched with name and email - Contact Lookup is populated for the case
			if(contactList.size()==1){				
				newCase[0].ContactId = contactList[0].Id;				
			}
		//Incase no Contact exists
			else if(contactList.size()==0){
				newCase[0].ContactId = null;
			}
		
		//If a single Lead Contact is associated with the Name and Email values provided	
			if(leadList.size()==1){
				baseUrl = URL.getSalesforceBaseUrl().toExternalForm()+'/'+leadList[0].Id;
				newCase[0].Lead_Link__c = baseUrl;
				ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Warning,'Association made successfully with Lead' );
      			if(ApexPages.currentPage()!=null)
      			ApexPages.addmessage(msg);
			}
			
			else if(leadList.size()==0){				
				newCase[0].Lead_Link__c = null;
			}
			
		//If more than one contact exists for the same name and email - the contact Ids are not stored
			if(contactList.size()>1){
				for(Contact contactIter : contactList){
					descriptionField = descriptionField + ','+contactIter.Id;
				}
				if(descriptionField.startsWith(','))
				descriptionField = descriptionField.subString(1,descriptionField.length());
				if(leadList.size()>1)
				newCase[0].Lead_Link__c = null;
				newCase[0].ContactId = null;
			}
		//If more than one Lead exists for the same name and email - the Lead Ids are not stored
			if(leadList.size()>1){
				for(Lead leadIterator : leadList){
					descriptionField = descriptionField + ','+leadIterator.Id;
				}
				if(descriptionField.startsWith(','))
				descriptionField = descriptionField.subString(1,descriptionField.length());
				newCase[0].Lead_Link__c = null;
				if(contactList.size()>1)
				newCase[0].ContactId = null;
			}
		}
		
		//If External Id and Email are not provided
		else{
			newCase[0].ContactId = null;
			newCase[0].Lead_Link__c = null;
		}
		
	}
	
	
	
	
}