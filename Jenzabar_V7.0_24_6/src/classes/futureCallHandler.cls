public class futureCallHandler{
    
    @future(callout=true)
    public static void futureCallMethod(){
        for(Integer i=0;i<=9;i++){
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://login.salesforce.com');
            req.setMethod('GET');
            HttpResponse res = h.send(req);
            System.debug('Response==='+res);
        }
    }
}