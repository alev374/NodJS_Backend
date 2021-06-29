const later = require('later');
const moment = require('moment');
moment.locale('de')
later.date.localTime();

class Cronjob {
	constructor(db, interval) {
		this.db = db;
		this.moment = moment;
		this.schedule = null;
		this.cronjobInterval = null;
		this.setSchedule(interval);
		this.startCronjob();
	}

	cronjob(){

	}

	setSchedule(interval){
		this.schedule = later.parse.text(interval);
	}

	startCronjob(){
		this.cronjobInterval = later.setInterval(()=>{
			this.cronjob()
			// this.cronjobInterval.clear()
		}, this.schedule);
	}
	
}

module.exports = Cronjob;