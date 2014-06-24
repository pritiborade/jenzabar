public with sharing class CustomLookUpController {
      public Reference__c referenceObj {get;set;} // new account to create
	  public List<Reference__c> results{get;set;} // search results
	  public string searchString{get;set;} // search keyword
	  public string ObjName{get;set;}
	  public string fieldName{get;set;}
	  
	  public CustomLookUpController() {
		  	referenceObj = new Reference__c();
		  	// get the current search string
		  	searchString = System.currentPageReference().getParameters().get('lksrch');
		  	string searchString1 = System.currentPageReference().getParameters().get('txt');
		  	ObjName = System.currentPageReference().getParameters().get('objname');
		  	fieldName = System.currentPageReference().getParameters().get('fapi');
		  	system.debug('searchString1-----'+searchString1);
		  	runSearch();  
	  }
	  // performs the keyword search
	  public PageReference search() {
	    	runSearch();
	    	return null;
	  }
	  // prepare the query and issue the search command
	  private void runSearch() {
	  	   // TODO prepare query string for complex serarches & prevent injections
	       results = performSearch(searchString);               
	  } 
	  // run the search and return the records found. 
	  private List<Reference__c> performSearch(string searchString) {
	  	
	  	  system.debug('performSearch called**********');
	      String soql = 'select id, name from Reference__c';
	      if(searchString != '' && searchString != null)
	           soql = soql +  ' where name LIKE \'%' + searchString +'%\'';
	      soql = soql + ' limit 25';
	      System.debug(soql);
	      return database.query(soql);
	  }
	  private void getRefMappings(){
	  	system.debug('getRefMappings called******');
	  	Set<String> setrefRecTyp = new 	Set<String>();
	  	String soqlRm = 'Select id, name, Reference_Record_Type__c, Object_Name__c, API_Name__c From Reference_Mapping__c';
	    if(ObjName != null && ObjName != '' && fieldName != null && fieldName != ''){
	    	soqlRm = 'where Object_Name__c='+ObjName+'and API_Name__c='+fieldName;
	    }
	    List<Reference_Mapping__c> rm  = new List<Reference_Mapping__c>();
	    rm = database.query(soqlRm);
	    if(rm != null && rm.size() > 0){
	    	for(Reference_Mapping__c ref:rm){
	    		if(ref.Reference_Record_Type__c != null){
	    		setrefRecTyp.add(ref.Reference_Record_Type__c);
	    		}
	    	}
	    }
	  }
	  // used by the visualforce page to send the link to the right dom element
	  public string getFormTag() {
	    	return System.currentPageReference().getParameters().get('frm');
	  }
	  // used by the visualforce page to send the link to the right dom element for the text box
	  public string getTextBox() {
	        return System.currentPageReference().getParameters().get('txt');
	  }
	  

}