global with sharing class ScheduleReadyEvents implements Schedulable{
  
  global void execute(SchedulableContext ctx) {
  	
  	String day = string.valueOf(system.now().day());
    String month = string.valueOf(system.now().month());
    String hour = string.valueOf(system.now().hour());
    String minute = string.valueOf(system.now().minute() + Math.mod(1,60));
    String second = string.valueOf(system.now().second());
    String year = string.valueOf(system.now().year());
     
    String strJobName = 'Event_Ready_' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;
    String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
    System.schedule(strJobName, strSchedule, new ScheduleReadyEvents());
  	
    ScheduleEventHandler.createReadyQueue();
  }   
}