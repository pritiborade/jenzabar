public abstract class BaseTrigger implements Itrigger{
    
    public void insertRecord(list<sObject> sobjectLsttoUpdate){
        if(!sObjectLsttoUpdate.isEmpty()){
            try{
                System.debug('===insert==='+sobjectLsttoUpdate);
                insert sobjectLsttoUpdate;
            }catch(Exception e){
                System.debug('The insert exception : '+e.getMessage());
            }
           
        }
    }
    
    public void updateRecord(list<sObject> sobjectLsttoUpdate){
        if(!sObjectLsttoUpdate.isEmpty()){
            try{
            	System.debug('===update==='+sobjectLsttoUpdate);
            	//System.debug('===update==='+sobjectLsttoUpdate.id);
                update sobjectLsttoUpdate;
            }catch(Exception e){
                System.debug('The update exception : '+e.getMessage());
            }
           
        }
    }
    
}