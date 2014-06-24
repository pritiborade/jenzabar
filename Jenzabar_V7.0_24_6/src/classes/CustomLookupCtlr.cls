public with sharing class CustomLookupCtlr {
    public boolean isContent{get;set;}
    public string refId{get; set;}
    public List<Schema.FieldSetMember> fieldSetMemberList { get; set; }
    public sobject sObj{get; set;}
    public String objectName;
    public String fieldSetName = 'Reference_Field_Set';
    public List<fieldWrap> lstFields{get; set;}
    public integer fieldsCount{get; set;}
    public void setobjectName(String oName ){
    	objectName = oName;
    	sObj = this.getsObj();
    }	
    public string getobjectName(){ 
	    return objectName;
    }    
    public CustomLookupCtlr() {

    }

    private sobject getsObj() {
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : this.readFieldSet(objectName,fieldSetName)) {
            query += f.getFieldPath() + ', ';
        }
        query += 'Id, Name FROM '+objectName+' LIMIT 1';
        return Database.query(query);
    }
    
	public List<Schema.FieldSetMember> readFieldSet(String objectName,String fieldSetName)
	{
		
	    Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
	    Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectName);
		if(fieldSetName != null){
		    Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
		    Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
		    fieldSetMemberList =  fieldSetObj.getFields();
		    if(fieldSetMemberList != null && fieldSetMemberList.size() > 0){
		    	lstFields = new List<fieldWrap>();
		    	for(Schema.FieldSetMember mem:fieldSetMemberList){
		    		 lstFields.add(new fieldWrap(mem.Label,mem.fieldPath));
		    	}
		    }
		    system.debug('>>>>'+lstFields);
		    fieldsCount = lstFields.size();
		    return fieldSetObj.getFields(); 
		}else{
			return null;
		}
	}      
    
    public void doSave(){
    	system.debug('<<<<>>>lstFields'+lstFields);
    }
  	public PageReference getRefrenceid(){
    	system.debug('<<<<>>>rid'+refId);
    	return null;
    }    
    public void Cancel(){
    	
    }  
    public void Edit(){
    	
    }  
    public class fieldWrap{
    	public String fieldLabel{get;set;}
    	public String fieldValue{get;set;}
    	public String fieldApi{get;set;}
    	public String refId{get;set;}
    	public fieldWrap(String fieldLabel,String fieldApi){
	    	this.fieldLabel = fieldLabel;
	    	this.fieldApi = fieldApi;
	    	this.fieldValue = '';
	    	this.refId = '';
    	}
    }
}