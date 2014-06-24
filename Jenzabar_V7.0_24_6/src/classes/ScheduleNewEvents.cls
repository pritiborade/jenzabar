global with sharing class ScheduleNewEvents implements Schedulable{
    global void execute(SchedulableContext ctx) {
        ScheduleEventHandler.fetchNewEvent();
    }   
}