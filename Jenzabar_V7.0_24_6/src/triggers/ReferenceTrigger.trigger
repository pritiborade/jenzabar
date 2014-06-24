trigger ReferenceTrigger on Reference__c (after delete, after insert, after update) {
    TriggerFactoryNew.CreateHandler('Reference');
}