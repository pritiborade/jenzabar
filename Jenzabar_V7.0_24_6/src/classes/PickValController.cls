public with sharing class PickValController{

    public PickValController(){
        
    }
     
    // Read a field   
    public static void readCustomField(String fieldName) {
        MetadataServiceNew.MetadataPort service = createService();
       
        MetadataServiceNew.CustomField field =
            (MetadataServiceNew.CustomField) service.readMetadata('CustomField', new String[] { fieldName }).getRecords()[0]; 
        
        for (MetadataServiceNew.PicklistValue val : field.picklist.picklistValues) {
            system.debug('Piclist val------'+val.fullName);
        }   
    }
    
    public static void pageLayout(String fieldName){
    	
        MetadataServiceNew.MetadataPort service = createService();
        system.debug('service-----'+service);
        MetadataServiceNew.Layout layout = ( MetadataServiceNew.Layout) service.readMetadata('Layout', new String[] { fieldName }).getRecords()[0];
        System.debug('====='+layout);
        
    }
    
    //Create a Picklist field
    public static void createPickVal(String fieldName,String pickListVal){
        MetadataServiceNew.MetadataPort service = createService();
        system.debug('service-----'+service);
        MetadataServiceNew.CustomField field =
            (MetadataServiceNew.CustomField) service.readMetadata('CustomField', new String[] { fieldName }).getRecords()[0]; 
      
        MetadataServiceNew.PicklistValue Completed = new MetadataServiceNew.PicklistValue();
        Completed.fullName = pickListVal;
        Completed.default_x = false;
      
        field.picklist.picklistValues.add(Completed);
        
        MetadataServiceNew.UpdateMetadata updateMetadata = new MetadataServiceNew.UpdateMetadata();
        updateMetadata.metadata= field;                         
        
        //MetadataServiceNew.AsyncResult[] results = service.updateMetadata(new List<MetadataServiceNew.UpdateMetadata> { updateMetadata });
        try{
        	MetadataServiceNew.saveResult[] results2 = service.updateMetadata(new List<MetadataServiceNew.Metadata>{field});
        	system.debug('results2------'+results2);
        }
        catch(Exception ex){
        	 system.debug('Picklist insert exception-------'+ex.getMessage());
        }
    }
    
    // Update a Picklist field
    public static void updatePickValue(String fieldName,String oldValue,String newValue) {
       MetadataServiceNew.MetadataPort service = createService();
       
       List<MetadataServiceNew.Metadata> updateData = new List<MetadataServiceNew.Metadata>();
       MetadataServiceNew.CustomField field =
            (MetadataServiceNew.CustomField) service.readMetadata('CustomField', new String[] { fieldName }).getRecords()[0]; 
        
       for (MetadataServiceNew.PicklistValue val : field.picklist.picklistValues) {
            System.debug('===val==='+val.fullName);
            if(val.fullName == oldValue){
                val.fullName = newValue;
                System.debug('===='+val.fullName);
                break;
            }
        }   
        
        //MetadataServiceNew.UpdateMetadata updateMetadata = new MetadataServiceNew.UpdateMetadata();
        //updateMetadata.metadata= field;                         
        
        //MetadataServiceNew.AsyncResult[] results = service.updateMetadata(new List<MetadataServiceNew.UpdateMetadata> { updateMetadata });
        MetadataServiceNew.saveResult[] results2 = service.updateMetadata(new List<MetadataServiceNew.Metadata>{field});
        system.debug('results2.update-------'+results2);
    }
    
    // Delete a Picklist value
    public static void deletePickVal(String fieldName,String pickValtoDelete) {
        MetadataServiceNew.MetadataPort service = createService();
        List<MetadataServiceNew.Metadata> delData = new List<MetadataServiceNew.Metadata>();
        MetadataServiceNew.CustomField field =
            (MetadataServiceNew.CustomField) service.readMetadata('CustomField', new String[] { fieldName }).getRecords()[0]; 
        
        for (MetadataServiceNew.PicklistValue val : field.picklist.picklistValues) {
            
            if(val.fullName == pickValtoDelete){
                MetadataServiceNew.Metadata mtObj = new MetadataServiceNew.Metadata();
                MetadataServiceNew.PicklistValue newP = val; 
                //new metadataservice.PicklistValue();
                newP.fullName =  fieldName + '.' + val.fullName;
                newP.default_x = false ;
                mtObj = newP;
                delData.add(mtObj);
                System.debug('====delData=='+delData);
                break;
            }   
        }
        
        //MetadataServiceNew.AsyncResult[] results = service.updateMetadata(new List<MetadataServiceNew.UpdateMetadata> { updateMetadata });
        MetadataServiceNew.AsyncResult[] results2 = service.deleteMetadata(delData);
        
    }
    public static void copyCreatePickVal(List<String> pickListInfo){
    	
    	 MetadataServiceNew.MetadataPort service = createService();
    	 List<MetadataServiceNew.UpdateMetadata> allPickList = new List<MetadataServiceNew.UpdateMetadata>();
    	 for(string picklistInst : pickListInfo){
    	 	   String[] picklistDetail = picklistInst.split(',');
    	 	   String fieldName = picklistDetail[0];
    	 	   String pickListVal = picklistDetail[1];
    	 	   MetadataServiceNew.CustomField field = (MetadataServiceNew.CustomField) service.readMetadata('CustomField', new String[] { fieldName }).getRecords()[0]; 
    	 	   
    	 	   MetadataServiceNew.PicklistValue Completed = new MetadataServiceNew.PicklistValue();
	           Completed.fullName = pickListVal;
	           Completed.default_x = false;	      
	           field.picklist.picklistValues.add(Completed);
	           MetadataServiceNew.UpdateMetadata updateMetadata = new MetadataServiceNew.UpdateMetadata();
        	   updateMetadata.metadata= field; 
        	   updateMetadata.currentName = fieldName;
        	   allPickList.add(updateMetadata);
    	 }
    	 try{
        	 //MetadataServiceNew.saveResult[] results2 = service.updateMetadata(allPickList);
        	 MetadataServiceNew.AsyncResult[] result2 = service.updateMetadata(allPickList);
        	 system.debug('results2------'+result2);
        }
        catch(Exception ex){
        	 system.debug('Picklist insert exception-------'+ex.getMessage());
        }
    }
    // Create Service   
    public static MetadataServiceNew.MetadataPort createService()
    {
        MetadataServiceNew.MetadataPort service = new MetadataServiceNew.MetadataPort();
        service.SessionHeader = new MetadataServiceNew.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }
    
}