/**
 * Class TriggerFactory
 *
 * Used to instantiate and execute Trigger Handlers associated with sObjects.
 */
public with sharing class TriggerFactoryNew
{
    /**
     * Public static method to create and execute a trigger handler
     *
     * Arguments:   Type t - Type of handler to instatiate
     *
     * Throws a TriggerException if no handler has been found.
     */
    public static void CreateHandler(String sObjectName){
        TriggerSetting__c accCSSetting = TriggerSetting__c.getInstance(sObjectName);
        List<String> lstClassNames = String.valueOf(accCSSetting.Handler_Names__c).split(',');
        
        for(String Str : lstClassNames){
            TriggerFactoryNew.createAndExecuteHandler(Type.forName(str));
        }
    } 
    public static void createAndExecuteHandler(Type t)
    {
        // Get a handler appropriate to the object being processed
        system.debug('The type is:' +t);
        ITrigger handler = getHandler(t);
         
        // Make sure we have a handler registered, new handlers must be registered in the getHandler method.
        if (handler != null)
        {
           // Execute the handler to fulfil the trigger
           execute(handler);
        }
    }
 
    /**
     * private static method to control the execution of the handler
     *
     * Arguments:   ITrigger handler - A Trigger Handler to execute
     */
    private static void execute(ITrigger handler)
    {
        // Before Trigger
        if (Trigger.isBefore)
        {
            // Call the bulk before to handle any caching of data and enable bulkification
            System.debug('Handler===='+handler);
            handler.bulkBefore();
 
            // Iterate through the records to be deleted passing them to the handler.
            if (Trigger.isDelete)
            {
            	handler.beforeDelete(Trigger.old);
                /*for (SObject so : Trigger.old)
                {
                    handler.beforeDelete(so);
                }*/
            }
            // Iterate through the records to be inserted passing them to the handler.
            else if (Trigger.isInsert)
            {
            	system.debug('in trigger.Insert........'+Trigger.isInsert);
            	 handler.beforeInsert(Trigger.new);
                /*for (sObject so : Trigger.new)
                {
                    handler.beforeInsert(so);
                }*/
            }
            // Iterate through the records to be updated passing them to the handler.
            else if (Trigger.isUpdate)
            {
            	system.debug('in trigger.Update...........'+Trigger.isUpdate);
            	handler.beforeUpdate(Trigger.oldMap,Trigger.newMap);
                /*for (SObject so : Trigger.old)
                {
                    handler.beforeUpdate(Trigger.oldMap.get(so.Id),Trigger.newMap.get(so.Id));
                }*/
            }
        }
        else
        {
            // Call the bulk after to handle any caching of data and enable bulkification
            handler.bulkAfter();
 
            // Iterate through the records deleted passing them to the handler.
            if (Trigger.isDelete)
            {
            	handler.afterDelete(Trigger.old);
                /*for (SObject so : Trigger.old)
                {
                    handler.afterDelete(so);
                }*/
            }
            // Iterate through the records inserted passing them to the handler.
            else if (Trigger.isInsert)
            {
            	handler.afterInsert(Trigger.new);
                /*for (SObject so : Trigger.new)
                {
                    handler.afterInsert(so);
                }*/
            }
            // Iterate through the records updated passing them to the handler.
            else if (Trigger.isUpdate)
            {
            	handler.afterUpdate(Trigger.oldMap,Trigger.newMap);
                /*for (SObject so : Trigger.old)
                {
                    handler.afterUpdate(Trigger.oldMap.get(so.Id),Trigger.newMap.get(so.Id));
                }*/
            }
        }
 
        // Perform any post processing
        handler.andFinally();
    }
 
    /**
     * private static method to get the named handler.
     *
     * Arguments:   Type t - Class of handler to instatiate
     *
     * Returns:     ITrigger - A trigger handler if one exists or null.
     */
    private static ITrigger getHandler(Type t)
    {
        // Instantiate the type
        Object o = t.newInstance();
        System.debug('====type== '+o);
        // if its not an instance of ITrigger return null
        if (!(o instanceOf ITrigger))
        {
            return null;
        }
        System.debug('===dd=='+(ITrigger)o);
        return (ITrigger)o;
    }
 
   
}