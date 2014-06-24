trigger ContactTrigger on Contact (after Update) {
    if(ContactTriggerUtil.triggerFlag1){
        TriggerFactoryNew.CreateHandler('Contact');
        ContactTriggerUtil.triggerFlag1 = false;
    }
}