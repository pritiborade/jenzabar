public with sharing class AWSBuckets {

	 private String AWSCredentialName = 'Jenzabar'; //Modify this string variable to be the name of the AWS Credential record that contains the proper AWS keys and secret
	 public  String selectedObjectName { get; set; }  // From page
	 public S3.AmazonS3 as3 { get; private set; } //This object represents an instance of the Amazon S3 toolkit and makes all the Web Service calls to AWS. 
	 
	 
	 public  List<String> objectNames { get {
        if ( objectNames == null ) 
            getObjects();
        return objectNames;
        } set; }  // All available objects
	 
	 public AWSBuckets(){
	        try{
	            system.debug('constructor called***********');
	            AWSKeys credentials = new AWSKeys(AWSCredentialName);
	            as3 = new S3.AmazonS3(credentials.key,credentials.secret);
	            as3 = new S3.AmazonS3();
	            as3.secret = credentials.secret;
	            as3.key = credentials.key;
	            
	        }catch(AWSKeys.AWSKeysException AWSEx){
	             
	             ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, AWSEx.getMessage());
	             ApexPages.addMessage(errorMsg);
	                
	        }
	
	    }
	    
	     public void getObjects() {
        try{
        	system.debug('getObjects() called***********');
            objectNames = new List<String>();
            Datetime now = Datetime.now();
            system.debug('as3.key is***********'+as3.key+' the signature is*********'+as3.signature('ListAllMyBuckets',now));
            S3.ListAllMyBucketsEntry[] buckets = 
                as3.ListAllMyBuckets(as3.key,now,as3.signature('ListAllMyBuckets',now)).Buckets.Bucket;
             
            for(S3.ListAllMyBucketsEntry bucket: buckets){
                objectNames.add((' ' + bucket.Name).trim());
            }
            
            system.debug('The buckets are:'+objectNames);
        }catch (Exception ex){
        	system.debug('In exception**************');
        	system.debug('The exception is:**'+ex);
        }
      
    }

}