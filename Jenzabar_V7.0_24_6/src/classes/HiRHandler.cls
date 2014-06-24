public with sharing class HiRHandler implements BaseInterface{
public String secreteKey;
    public HiRHandler(){

    
    }
    
    public static String make_sig(string canonicalBuffer) {  
     try {       
         String macUrl ;
         String signingKey = EncodingUtil.base64Encode(Blob.valueOf('AKIAIFEM2JY2MITI3CBA/KqWheBtqnV7P3Fh33jDfcIS35cAsaDvvZWrnxrLC'));
         Blob mac = Crypto.generateMac('HMacSHA1', blob.valueof(canonicalBuffer),blob.valueof('AKIAIFEM2JY2MITI3CBA/KqWheBtqnV7P3Fh33jDfcIS35cAsaDvvZWrnxrLC')); 
         macUrl = EncodingUtil.base64Encode(mac); 
         System.debug('macURL'+macUrl);
         //To cover the exception in the test
    /*if(Test.isRunningTest())
     integer i = 10/0; */
     return macUrl;
     }
     catch(Exception e) {
      return null;
      //Do Nothing.
     }
    }

	public static void execute(Id eventId){
    	system.debug('retrieving the info through amazon handler**********');
		//Map<String, String> amazonInfoMap = new Map<String, String>();
		system.debug('retrieving the info through amazon handler**********');
		 List<Event__c> eveLst = new List<Event__c>();
        eveLst = [SELECT id, 
                         Retriever_Info__c 
                         FROM Event__c 
                         WHERE id =: eventId 
                         LIMIT 1];
        
            
        if(!eveLst.isEmpty()){ 
        	Event__c eveObj = new Event__c(id=eventId);

            Http h = new Http();
            HttpRequest req = new HttpRequest();
            system.debug('retrieved link is:'+ScheduleEventHandler.retrievedLink);
            //req.setEndpoint('http://findyourmp.parliament.uk/api/search?q=bob&f=js');
            req.setEndpoint(ScheduleEventHandler.retrievedLink);
            req.setMethod('GET');
            req.setHeader('Host', 's3.amazonaws.com');
            HttpResponse res = h.send(req);
            System.debug('res.getBody()***********************'+res.getBody());
            
            ScheduleEventHandler.infoContentMap = new Map<Id,String>();
            ScheduleEventHandler.infoContentMap.put(eventId,res.getBody()); 
            
            
            /*if(eveObj != null){
                eveObj.Content_JSON__c = res.getBody();
                update eveObj;
            }*/
        }
    }

	/*public static Map<String, String> executeAmazon(Id eventId){  
		
		system.debug('retrieving the info through amazon handler**********');
		//Map<String, String> amazonInfoMap = new Map<String, String>();
		
		 List<Event__c> eveLst = new List<Event__c>();
        eveLst = [SELECT id,
                         Retriever_Info__c 
                         FROM Event__c 
                         WHERE id =: eventId 
                         LIMIT 1];
        
            
        if(!eveLst.isEmpty()){
        	Event__c eveObj = new Event__c(id=eventId);

            Http h = new Http();
            HttpRequest req = new HttpRequest();
            system.debug('retrieved link is:'+ScheduleEventHandler.retrievedLink);
            //req.setEndpoint('http://findyourmp.parliament.uk/api/search?q=bob&f=js');
            req.setEndpoint(ScheduleEventHandler.retrievedLink);
            req.setMethod('GET');
            req.setHeader('Host', 's3.amazonaws.com');
            HttpResponse res = h.send(req);
            System.debug('res.getBody()***********************'+res.getBody());
            
            ScheduleEventHandler.infoContentMap.put(eventId,res.getBody());
            
            
            /*if(eveObj != null){
                eveObj.Content_JSON__c = res.getBody();
                update eveObj;
            }*/
        /*} 
        return ScheduleEventHandler.infoContentMap;
	}*/


    public static void execute(){
        
        try{
        AWSKeys credentials = new AWSKeys('Jenzabar');
        s3.AmazonS3 s3Obj = new s3.AmazonS3(credentials.key,credentials.secret);
        String signature = s3Obj.signature('GetObject',System.now());
        System.debug('==='+signature);
        System.debug('tt'+system.now());
        Datetime now = Datetime.now();
        Datetime expire = system.now().addDays(1);
        String formattednow = now.formatGmt('yyyy-MM-dd')+'T'+now.formatGmt('HH:mm:ss')+'.'+now.formatGMT('SSS')+'Z';
        String strformattedexpire;
        String formattedexpire = strformattedexpire = expire.formatGmt('yyyy-MM-dd') + 'T' +   
        expire.formatGmt('HH:mm:ss') + '.' + expire.formatGMT('SSS') + 'Z';  
        String policy = '{ "expiration": "'+ formattedexpire +'","conditions": [ {"bucket": "'+  
                 'DhirendraBucket' +'" } ,{ "acl": "public-read" },'+
                    '{"content-type":"'+'image/jpeg'+'"},'+
                 '["starts-with", "$key", "' + 'Test' + '"] ]}'; 
        
         S3.GetObjectResult res = s3Obj.GetObject('DhirendraBucket', 
                                    'Test',
                                    true, 
                                    true, 
                                    true, 
                                    credentials.key, 
                                    Datetime.now(), 
                                    s3Obj.signature('GetObject',Datetime.now()),
                                    'Jenzabar');
            
        }catch(Exception ex){
        	system.debug('In exception of execute method&&&&&&&&&&&&');
        }
        
                                             
    }
    
    /*public static void callAmazon(Id eventId){
        
        List<Event__c> eveLst = new List<Event__c>();
        eveLst = [SELECT id,
                         Retriever_Info__c 
                         FROM Event__c 
                         WHERE id =: eventId 
                         LIMIT 1];
        
            
        if(!eveLst.isEmpty()){
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(eveLst[0].Retriever_Info__c);
            req.setMethod('GET');
            req.setHeader('Host', 's3.amazonaws.com');
            HttpResponse res = h.send(req);
            System.debug(res.getBody());
            Event__c eveObj = new Event__c(id=eventId);
            if(eveObj != null){
                eveObj.Content_JSON__c = res.getBody();
                update eveObj;
            }
        }   
    }*/
    public static void callAmazonGet(){
        
        AWSKeys credentials = new AWSKeys('Jenzabar');
        s3.AmazonS3 s3Obj = new s3.AmazonS3(credentials.key,credentials.secret);
        String str = 'https://s3.amazonaws.com/new++4.json';
        String signature = s3Obj.signature('GetObject',System.now());
        DateTime dt = System.now().addDays(1);
        String dateString = dt.formatGmt('EEE')+',  '+dt.formatGmt('dd')+' '+dt.formatGmt('MMM')+' '+dt.formatGmt('YYYY')+' '+dt.formatGmt('HH:MM:SS')+' GMT';  
        System.debug(dateString);
        String authentication = 'AWS '+credentials.key+':'+signature;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(str);
        req.setMethod('GET');
        req.setHeader('Host', 'DhirendraBucket.s3.amazonaws.com');
        req.setHeader('Date',dateString);
        req.setHeader('Authorization',authentication);
        HttpResponse res = h.send(req);
        System.debug('response==='+res.getBody());
    }       
    
    public static void callAmazonPost(){
        
        AWSKeys credentials = new AWSKeys('Jenzabar');
        s3.AmazonS3 s3Obj = new s3.AmazonS3(credentials.key,credentials.secret);
        String signature = s3Obj.signature('GetObject',System.now());
        String str = '<GetObject xmlns="http://doc.s3.amazonaws.com/2006-03-01">'+
                     '<Bucket>DhirendraBucket</Bucket>'+
                     '<Key>Test</Key>'+
                     '<GetMetadata>true</GetMetadata>'+
                     '<GetData>true</GetData>'+
                     '<InlineData>true</InlineData>'+
                     '<AWSAccessKeyId>'+credentials.key+'</AWSAccessKeyId>'+
                     '<Timestamp>'+System.now()+'</Timestamp>'+
                     '<Signature>'+signature+'</Signature>'+
                     '</GetObject>';
         
        String retrieverUrl = 'https://s3.amazonaws.com';
        
        Datetime now = Datetime.now();
        Datetime expire = system.now().addDays(1);
        String formattednow = now.formatGmt('yyyy-MM-dd')+'T'+now.formatGmt('HH:mm:ss')+'.'+now.formatGMT('SSS')+'Z';
        String strformattedexpire;
        String formattedexpire = strformattedexpire = expire.formatGmt('yyyy-MM-dd') + 'T' +   
        expire.formatGmt('HH:mm:ss') + '.' + expire.formatGMT('SSS') + 'Z';  
        String policy = '{ "expiration": "'+ formattedexpire +'","conditions": [ {"bucket": "'+  
                 'DhirendraBucket' +'" } ,{ "acl": "public-read" },'+
                    '{"content-type":"'+'image/jpeg'+'"},'+
                 '["starts-with", "$key", "' + 'Test' + '"] ]}'; 
         
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(retrieverUrl);
        req.setMethod('POST');
        req.setHeader('Host', 'DhirendraBucket.s3.amazonaws.com');
        req.setHeader('Content-Type',' application/xml ');
        req.setBody(str);
        HttpResponse res = h.send(req);
        System.debug('response==='+res.getBody());
        
    }
    
    public static String getSignature(DateTime now,String op){
       
        //format should be like 2006-01-01T12:00:00.000Z
        AWSKeys credentials = new AWSKeys('Jenzabar');
        s3.AmazonS3 s3Obj = new s3.AmazonS3(credentials.key,credentials.secret);
        String secreteKey = credentials.key;
        
        String formattednow = now.formatGmt('yyyy-MM-dd')+'T'+now.formatGmt('HH:mm:ss')+'.'+now.formatGMT('SSS')+'Z';
        System.Debug('Formatted date : '+formattednow);
       
        String canonical = 'AWS '+op+formattednow; //"AmazonS3" + OPERATION + Timestamp
       
        System.debug('CANONICAL = '+canonical);
       
        Blob bsig = Crypto.generateMac('HmacSHA1', Blob.valueOf(canonical), Blob.valueOf(secreteKey));
       
       
        String signature = EncodingUtil.base64Encode(bsig);
        return signature;
    }
}