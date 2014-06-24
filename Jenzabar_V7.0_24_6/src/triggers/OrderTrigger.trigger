trigger OrderTrigger on Order (after insert, after update) {
    
        TriggerFactoryNew.CreateHandler('Order');
}