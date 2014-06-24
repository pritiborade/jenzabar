trigger CaseTrigger on Case (before insert, before update) {

	TriggerFactoryNew.CreateHandler('Case');
}