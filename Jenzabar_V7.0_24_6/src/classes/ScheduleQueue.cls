global class ScheduleQueue implements Schedulable {

	global void execute(SchedulableContext ctx) {
		this.start();
		ScheduleQueueHandler.scheduleQueue();
		
	}  
	
	public void start()
    {
    	String day = string.valueOf(system.now().day());
        String month = string.valueOf(system.now().month());
        String hour = string.valueOf(system.now().hour());
        Integer minute = Math.mod(system.now().minute() + 1,60);
        
        String second = string.valueOf(system.now().second());
        String year = string.valueOf(system.now().year());
         
        String strJobName = 'Queue-' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;
        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        System.schedule(strJobName, strSchedule, new ScheduleQueue());
    }  
    
    
}