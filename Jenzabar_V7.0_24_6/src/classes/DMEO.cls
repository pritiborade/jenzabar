global with sharing class DMEO{}
	/*
    public List<String> listFieldToShow {get;set;}
    public map<String , String> mapFieldToShow{get;set;}
    public map<String , String> mapFieldToShow1{get;set;}
    public list<sObject> listTableResult{get; set;}
    //public list<>listTableResult  
    public list<String> objectList {get; set;}
    public list<SelectOption> newList {get; set;}
    public string myLabel{get; set;}
    public string objectName{get; set;}  
    public Set<string> objectSet{get;set;}
    public Set <string> fieldLabels{get;set;}  
    public map<String, Schema.SObjectType> mapObjectGD;
    public Map <String, Schema.SObjectField> fieldMap; 
//  public map<string,Schema.SOAPType> innerClassFieldMap{get;set;}
    public list<RecordInnerClass> lstRecordInnerClass{get; set;}
    
    
    
    private map<Integer, list<String>> mapObjectsWithParent = new map<Integer, list<String>>();
    private map<string,list<string>> mapParentOfChild = new map<string,list<string>>();
    private map<Integer, Boolean> mapIsLoopExecuted = new map<Integer, Boolean>();
    private map<string, map<string, string>> mapReqFieldsWithoutRef = new map<string, map<string, string>>();
    private map<string, map<string, string>> mapReqFieldRef =new map<string, map<string, string>>();
	//private map<string,string> reqData = new map<string,string>();
	//private map<string,string> objFieldRef = new map<string,string>();
	private Integer size = 1;    
	private Integer index = 1;
	
	private map<string, map<string, string>> mapObjectWithReqFields = new map<string, map<string, string>>();
	//private list<string> listOfParentObjects= new list<string>();
    private integer objCount = 0;
    
    
    public sObject sObj{get;set;}
    integer countvar = 0;
    public String str{get;set;}
    
    
    
    public TestCheckPageController(string pObjName){
    	/*
    	mapObjectsWithParent = new map<Integer, list<String>>();
    	mapIsLoopExecuted = new map<Integer, Boolean>();
    	size = 0;
    	index = 0;*/
        //this.init(pObjName);
   // }
  
 /*   
    public Map<String,String> GetParentRecords(string ObjectName,list<Schema.sObjectType> parentObjectList){
    		Map<String,String> parentChildStructure = new Map<string,String>();
    		for(Schema.sObjectType objParent : parentObjectList){
            		String.valueOf(objParent); 
            		parentChildStructure.put(objectName , String.valueOf(objParent));
            		system.debug('******parentChildStructure*****' +parentChildStructure);
            	}
            	return parentChildStructure;
    }*/
    
    
    /* public String GetParentRecords(string ObjectName,list<Schema.sObjectType> parentObjectList){
    		//Map<String,String> parentChildStructure = new Map<string,String>();
    		string ParentObject;
    		for(Schema.sObjectType objParent : parentObjectList){
            		ParentObject = String.valueOf(objParent);
            		//parentChildStructure.put(objectName , String.valueOf(objParent));
            		system.debug('******String.valueOf(objParent); *****' +String.valueOf(objParent));
            	}
            	return ParentObject;
    }
    
    
    
    public void init(string pObjName){   
    	//string pObjName = 'Obj1__c';
        //getLocation('0019000000HTprP');      
        
        str = 'testing';
        
        myLabel = 'TestLabel'; 
        
        lstRecordInnerClass = new list<RecordInnerClass>();
       
        //Object Describe Call
        GetAllObjectDetails();
        
        system.debug('*****Before mapObjectsWithParent****' + mapObjectsWithParent);
        
        CreateRecord(pObjName);
       // CreateRecord(pObjectName);
        
        
        system.debug('*****After  mapObjectsWithParent****' + mapObjectsWithParent); 
        system.debug('*****After  mapParentOfChild****' + mapParentOfChild); 
        
      //  list<Obj7__c> recordsToCreate = GetRecords('Obj7__c', 8);
       // system.debug('*****recordsToCreate****' + recordsToCreate);
        //VRG 
       /* Schema.SOAPType FieldtypeorderQuantity = Schema.SObjectType.Ajaysingh__Order__c.fields.Ajaysingh__Order_Quantity__c.getSoapType(); 
        system.debug('********FieldtypeorderQuantity*******'  + FieldtypeorderQuantity);
        Boolean orderQuantityRequired =  Schema.SObjectType.Ajaysingh__Order__c.fields.Ajaysingh__TextTest__c.isNillable();
        system.debug('********orderQuantityRequired*******'  + orderQuantityRequired);
        Schema.DescribeFieldResult textTest = Ajaysingh__Order__c.Ajaysingh__TextTest__c.getDescribe();
        system.debug('********textTest*******'  + textTest);
        Boolean textTestRequired =  Schema.SObjectType.Ajaysingh__Order__c.fields.Ajaysingh__TextTest__c.isNillable();
        system.debug('********textTestrequired*******'  + textTestRequired);
        Schema.SOAPType FieldtypeCurrencyField = Schema.SObjectType.Ajaysingh__Salary_Details__c.fields.Ajaysingh__CurrencyField__c.getSoapType(); 
        system.debug('********FieldtypeCurrencyField*******'  + FieldtypeCurrencyField); */
    /*}
    
    //return Relationship map
    public map<Integer, list<String>> GetRelationshipMap(){
    	return this.mapObjectsWithParent;	
    }
    
    //Return Required Fields Map
    public map<string, map<string, string>> GetRequiredFieldsMap(){
    	return this.mapObjectWithReqFields;	
    }
    
    public map<string, list<string>> GetParentOfChild(){
    	return this.mapParentOfChild;
    }
    public map<string, map<string,string>> GetRequiredFieldsOfRef(){
    	return this.mapReqFieldRef;
    }
    public map<string, map<string,string>> GetRequiredFieldsWithoutRef(){
    	return this.mapReqFieldsWithoutRef;
    }
      
    public void CreateRecord(string objectName){
    	
    	map<string,string> reqData = new map<string,string>();
    	map<string,string> objFieldRef = new map<string,string>();
    	//listOfParentObjects.clear();
    	list<string> listOfParentObjects= new list<string>();
    	
    	map<string, string> mapFieldDatatype = new map<string, string>();
    	system.debug('*****objectName***' + objectName);
    	system.debug('*****Start mapObjectsWithParent****' + mapObjectsWithParent);
    	list<String> requiredFields = new list<String>();
    	//list<Schema.Childrelationship> childRelationship = new list<Schema.Childrelationship>();
        listFieldToShow = new List<String>(); 
        mapFieldToShow = new Map<String , String>();
        mapFieldToShow1 = new Map<String , String>();  
        listTableResult = new list<sObject>();
        lstRecordInnerClass.clear();
        system.debug('******objectName********' + objectName);
        Schema.SObjectType obj = mapObjectGD.get(objectName);
        Schema.Describesobjectresult result = obj.getDescribe(); 
       
        Map<String, Schema.SObjectField> fieldMap = result.fields.getMap();
        system.debug('*******fieldMap*******' + fieldMap);
        set<string> setOfFields = fieldMap.keySet();
        system.debug('*****setOfFields******' + setOfFields);
        List<Boolean> requiredfieldList = new List<Boolean>();
        sObj = mapObjectGD.get(objectName).newSObject() ;
        //innerClassFieldMap = new map<string,Schema.SOAPType>();
         if(mapObjectsWithParent.size()==0){
            
            	mapObjectsWithParent.put(0,new list<String>{objectName});
            	system.debug('*****FirstElement*****' + mapObjectsWithParent);
            }
        for(string field : setOfFields){
            
            //SObjectField ppp=fieldMap.get(field);
            Schema.Describefieldresult fieldResult = fieldMap.get(field).getDescribe();
            system.debug('*****fieldResult*****' + fieldResult);
           
            //Code Added By VRG to get Map Structure of Master Detail Relationship
            if(!fieldResult.isNillable() && String.valueOf( fieldResult.getType()).equals('REFERENCE') ){
            	string parentObjectName;
            	list<Schema.sObjectType> parentObjectList = fieldResult.getReferenceTo();
            		system.debug('******parentObjectList*****' + parentObjectList);
            		parentObjectName = GetParentRecords(objectName,parentObjectList);
            		
            		//if(parentObjectName !=null)
            			//mapObjectsWithParent.put(index, new list<String>{parentObjectName});
            		system.debug('****parentObjectName***' + parentObjectName);
            		system.debug('****mapObjectsWithParent***' + mapObjectsWithParent);
            		system.debug('****parentObjectList[0]***' + String.valueOf(parentObjectList[0]));
            		if(!mapObjectsWithParent.containsKey(index)&& parentObjectList <> null && 
            		    String.valueOf(parentObjectList[0]) <> 'User'
            		   && String.valueOf(parentObjectList[0]) <> 'Group'){//
            		   	if(parentObjectName <> objectName)
            				mapObjectsWithParent.put(index, new list<String>{String.valueOf(parentObjectList[0])});
            			
            			
            			system.debug('**objectName*' + objectName);
            			system.debug('*parentObjectName*' + parentObjectName);
            			mapParentOfChild.put(objectName, new list<string>{String.valueOf(parentObjectList[0])});
            			//logic to get required field Reference
            			//objFieldRef = new map<string,string>();
            			objFieldRef.put(fieldResult.getName(), String.valueOf(parentObjectList[0]));
            			//mapReqFieldRef.put(objectName, objFieldRef);
            		}
            		else if(parentObjectList <> null && String.valueOf(parentObjectList[0]) <> 'User' 
            		        && String.valueOf(parentObjectList[0]) <> 'Group'){
            			if(parentObjectName <> objectName){
	            			list<String> lstParentObjects = mapObjectsWithParent.get(index);
	            			system.debug('*lstParentObjects*' + lstParentObjects);
	            			lstParentObjects.add(String.valueOf(parentObjectList[0]));
	            			mapObjectsWithParent.put(index, lstParentObjects);
            			}
            			system.debug('*mapParentOfChild*' + mapParentOfChild);
            			if(mapParentOfChild.containskey(objectName)){
            				listOfParentObjects = mapParentOfChild.get(objectName);
            				listOfParentObjects.add(parentObjectName);
            				mapParentOfChild.put(objectName,listOfParentObjects);
            			}
            			else{
            				mapParentOfChild.put(objectName,new list<string>{String.valueOf(parentObjectList[0])});
            			}
            			
            			//if(mapReqFieldRef.containskey(objectName)){
            				//objFieldRef = mapReqFieldRef.get(objectName);
            				objFieldRef.put(fieldResult.getName(), String.valueOf(parentObjectList[0]));
            				//mapReqFieldRef.put(objectName,objFieldRef);
            				//system.debug('***getName if ***' + fieldResult.getName());
            			/*}
            			else{
            				map<string,string> objref = new map<string,string>();
            				system.debug('***getName else ***' + fieldResult.getName());
            				mapReqFieldRef.put(fieldResult.getName(), String.valueOf(parentObjectList[0]));
            				mapReqFieldRef.put(objectName,objref);
            			
            			}*/
            			//system.debug('*++objectName*' + objectName);
            			//listOfParentObjects = mapParentOfChild.get(objectName);
            			/*system.debug('*listOfParentObjects*' + listOfParentObjects);
            			system.debug('***parentObjectName*' + parentObjectName);
            			
            			//listOfParentObjects.add(parentObjectName);
            			//mapParentOfChild.put(objectName,listOfParentObjects);
            		}
            		/*
            		if(mapParentOfChild.containskey(objectName)){
            			listOfParentObjects = mapParentOfChild.get(objectName);
            			listOfParentObjects.add(parentObjectName);
            			mapParentOfChild.put(objectName,listOfParentObjects);
            		}
            		else{
            			mapParentOfChild.put(objectName, new list<string>{parentObjectName});
            		}
            		*/
            		
            	//}//End if
            	
            	//To get Required Fields of an Object
            	/*else if(!fieldResult.isNillable() && (!String.valueOf(fieldResult.getType()).equals('REFERENCE')) && 
            			 string.valueof(fieldResult.getReferenceTo()) <>'(User)' && 
            			 string.valueof(fieldResult.getReferenceTo()) <> '(Group)' && 
            			 fieldResult.getName() <>'SystemModstamp' && fieldResult.getName()<>'CreatedDate' && 
            			 fieldResult.getName()<>'IsDeleted' && fieldResult.getName()<>'LastModifiedDate' && 
            			 string.valueof(fieldResult.getSOAPType()) <> 'Id'){
            		
            		 if(mapReqFieldsWithoutRef.containskey(objectName)){
            		 	reqData = mapReqFieldsWithoutRef.get(objectName);
            		 	reqdata.put(fieldResult.getName(), string.valueof(fieldResult.getSOAPType()));
            		 	mapReqFieldsWithoutRef.put(objectName, reqData);
            		 }
            		 else{
            				reqData.put(fieldResult.getName(), string.valueof(fieldResult.getSOAPType()));
            				mapReqFieldsWithoutRef.put(objectName, reqData);
                    }
            			
            	}
            	
            	
            }//End for fieldSet
            
            system.debug('****Pahle mapReqFieldsWithoutRef**' + mapReqFieldsWithoutRef);
            mapObjectWithReqFields.put(objectName, mapFieldDatatype);
            system.debug('*** pahle mapReqFieldRef**' + mapReqFieldRef);
            if(objectName <> 'User' && objectName <> 'Group')
            //mapParentOfChild.put(objectName,listOfParentObjects);
            system.debug('***mapParentOfChild*' + mapParentOfChild);
            system.debug('****mapObjectWithReqFields size****' + mapObjectWithReqFields.size());
            system.debug('****mapObjectWithReqFields****' + mapObjectWithReqFields);
            
       		system.debug('*****mapObjectsWithParent****' + index + mapObjectsWithParent);
       		system.debug('*****Parents****' + mapObjectsWithParent.get(index));
       		
       		if(!objFieldRef.isEmpty())
       			mapReqFieldRef.put(objectName, objFieldRef);
       		
       		if(mapIsLoopExecuted.isEmpty() || mapIsLoopExecuted.get(index-1)){
       			
       			if(mapObjectsWithParent.get(index) <> null && mapObjectsWithParent.get(index).size() > 0){
       				Integer oldIndex = index;
       				mapIsLoopExecuted.put(oldIndex, false);
       				index++;
       				size = 0;
       				
       				for(String objName1 : mapObjectsWithParent.get(oldIndex)){
       					size++;
       					system.debug('****objName****' + objName1);
       					
       					if(size == mapObjectsWithParent.get(oldIndex).size()){
       						mapIsLoopExecuted.put(index-1, true);
       					}//End if
       					
       					this.CreateRecord(objName1);       					
       				}//End for
       			}//End if
       			
       		}//End if
       		
       		system.debug('*********mapParentOfChild****' + mapParentOfChild);
            system.debug('*****mapReqFieldRef**' + mapReqFieldRef);
        }//End CreateRecord method.
        
    
        public list<Sobject> GetRecords(string objectName, Integer pIndex){
     	list<SObject> lstObjectToCreate = new list<SObject>();
     	//Describe SObjects
     	GetAllObjectDetails();
     	
     	//get Fields of Selected Object
    	map<string, string> mapFieldDatatype = new map<string, string>();
    	system.debug('*****objectName***' + objectName);
    	system.debug('*****Start mapObjectsWithParent****' + mapObjectsWithParent);
    	list<String> requiredFields = new list<String>();
    	
        system.debug('******objectName********' + objectName);
        Schema.SObjectType obj = mapObjectGD.get(objectName);
        Schema.Describesobjectresult result = obj.getDescribe(); 
       
        Map<String, Schema.SObjectField> fieldMap = result.fields.getMap();
        system.debug('*******fieldMap*******' + fieldMap);
        set<string> setOfFields = fieldMap.keySet();
        system.debug('*****setOfFields******' + setOfFields);
        //sObj = mapObjectGD.get(objectName).newSObject() ;
        
        //Create instanceof an passed object
        //list<objectName> objdata = new list<objectName>();
        Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe(); 
        string fieldName;
        for(Integer index = 0; index <= pIndex; index++){
        	
        	Schema.sObjectType sObjType = globalDescription.get(objectName);
        	sObject sObjectToBind = sObjType.newSObject();
        	//SObject newRecord = new SObject(); 
	        for(string field : setOfFields){
	            
	            system.debug('***field api*****' + field);
	            //SObjectField ppp=fieldMap.get(field);
	            Schema.Describefieldresult fieldResult = fieldMap.get(field).getDescribe();
	            system.debug('*****fieldResult*****' + fieldResult);
	           
	            //Code Added By VRG to get Map Structure of Master Detail Relationship
	            if(!fieldResult.isNillable() && String.valueOf( fieldResult.getType()).equals('REFERENCE') ){
	            	string parentObjectName;
	            	list<Schema.sObjectType> parentObjectList = fieldResult.getReferenceTo();
	            		system.debug('******parentObjectList*****' + parentObjectList);
	           	
	            }//End IF
	            else if((string.valueof(fieldResult.getSOAPType())==('DATE'))){
	            		
	            		//fieldName = fieldResult.getname();
	            		if(fieldResult.getname() <> 'CreatedDate')
	            			sObjectToBind.put(fieldResult.getname(), system.today());
	            		//objdata.fieldName = Today();
	            }
	            else if((string.valueof(fieldResult.getSOAPType())==('DATETIME'))){
	            		if(fieldResult.getname() <> 'CreatedDate' && fieldResult.getname() <> 'SystemModstamp' &&
	            		   fieldResult.getname() <> 'LastModifiedDate')
	            			sObjectToBind.put(fieldResult.getname(), system.now());
	            		//objdata.fieldName = Today();
	            }
	            else if((string.valueof(fieldResult.getSOAPType())==('BOOLEAN'))){
	            	
	            		fieldName = fieldResult.getname();
	            		if(fieldResult.getname() <> 'IsDeleted')
	            			sObjectToBind.put(fieldResult.getname(), true);
	            		//objdata.fieldName = Today();
	            }
	            /*
	            else if((string.valueof(fieldResult.getSOAPType())==('ID'))){
	            	
	            		fieldName = fieldResult.getname();
	            		sObjectToBind.put(fieldResult.getname(), true);
	            		//objdata.fieldName = Today();
	            }*/
	            /*else if((string.valueof(fieldResult.getSOAPType())==('STRING'))){
	            	
	            		fieldName = fieldResult.getname();
	            		sObjectToBind.put(fieldResult.getname(), 'Ajay');
	            		//objdata.fieldName = Today();
	            }
	           		
           }// End for fieldSet
       
	    	lstObjectToCreate.add(sObjectToBind);        			
        }//End for
    	system.debug('****lstObjectToCreate**' + lstObjectToCreate);
        return lstObjectToCreate;
     }//End GetRecords method.
    
    
    public class RecordInnerClass{  
        public string nameofField{get; set;}
        public string value{get;set;}
        
        public  RecordInnerClass(string pNameofField,string pValue){       
            nameofField = pNameofField;
            value = pValue;
        }
    }
    
    //Method to get Information of Selected Object
    public void GetSelectedObjectInfo(){
    	//CreateRecord(objectName);
   	      /*system.debug('***Selected Object Name***' + objectName);
   	      fieldMap = mapObjectGD.get(objectName).getDescribe().fields.getMap();
   	      system.debug('***fieldMap***' + fieldMap);
   	      
   	      for(Schema.SObjectField sfield : fieldMap.Values())
		  {
		      schema.describefieldresult dfield = sfield.getDescribe();
			  system.debug('#######' + dfield );
			 // Pair field = new Pair();
  			  //field.key = dfield.getname();
  			//  system.debug('#######4444' + field.key);
			 // field.val = dfield.getType () + ' : ' + dfield.getLabel ();
			  //lstfieldname.add(field);
		  }*/
    //}
    /*
    //Describe call to get Metadata of Salesforce Objects
    public Pagereference GetAllObjectDetails(){
    	mapObjectGD = Schema.getGlobalDescribe();
        system.debug('***Objects Map***' + mapObjectGD);
    
        List<Schema.SObjectType> listOfObjects = mapObjectGD.values();
        
        Set <String> objectSet = new Set<String>();         
        objectSet = mapObjectGD.keySet();
        system.debug('***objectSet***' + objectSet);
        List<SelectOption> newItemList = new List<SelectOption>();
        for(String name : objectSet){
            Schema.SObjectType obj = mapObjectGD.get(name);
        //  Schema.SObjectType obj3 = new Schema.SObjectType();
            newItemList.add(new SelectOption( name ,obj.getDescribe().getLabel())); 
            //newItemList.add(new SelectOption(Account.sObjectType.getDescribe().getLabel(), name )); 
        } 
        system.debug('******objectName*********' + objectName);
       //sObject sObj = Schema.getGlobalDescribe().get(objectName).newSObject() ;
        newList = newItemList;
        system.debug('***objectSet***' + objectSet);
        List<Schema.SObjectType> objectList = mapObjectGD.values();
        system.debug('***Object List***' + objectList);
       // Schema.DescribeFieldResult orderQuantity = Ajaysingh__Order__c.Ajaysingh__Order_Quantity__c.getDescribe();
       // system.debug('********orderQuantity*******'  + orderQuantity);
        
        //Schema.DescribeFieldResult F = Schema.SObjectType.Ajaysingh__Order__c.fields();
        return null;
    }
                         */