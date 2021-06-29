const Cronjob = require(__base + 'cronjobs/cronjob');
const reminderEmail = require(__base + 'email/reminder_email');

class InspectionReminderCronjob extends Cronjob {
	constructor(db, interval) {
		super(db, interval)
		this.weekdays = new Map([
			[0, 'So'],
			[1, 'Mo'],
			[2, 'Di'],
			[3, 'Mi'],
			[4, 'Do'],
			[5, 'Fr'],
			[6, 'Sa']
		]);
		this.pastDates = 8;
		this.pastDays = 1;
	}

	addToUsers(users, elevators, personTypes, elevatorStorage) {
		elevators.forEach(elevator => {
			personTypes.forEach(personType => {
				const storage = `${personType.substring(5)}_${elevatorStorage}`;
				if (elevator[personType]) {
					if (!users.hasOwnProperty(elevator[personType].pers_id)) {
						users[elevator[personType].pers_id] = elevator[personType];
					}
					if (!users[elevator[personType].pers_id].hasOwnProperty(storage)) {
						users[elevator[personType].pers_id][storage] = new Map;
					}
					users[elevator[personType].pers_id][storage].set(elevator.elev_id, elevator);
				}
			});
		});
		return users;
	}

	getTodayDateElevators(elevators) {
		const todayDate = this.moment().date();
		return elevators.filter(elevator => {
			const filteredElevatorList = elevator.elev_inspection_days.filter(d => (d == todayDate));
			return filteredElevatorList.length > 0
		});
	}

	getTodayDayElevators(elevators) {
		const todayDay = this.moment().format('dd');
		return elevators.filter(elevator => {
			const filteredElevatorList = elevator.elev_inspection_days.filter(d => (d == todayDay));
			return filteredElevatorList.length > 0;
		});
	}

	getPastDateElevators(elevators) {
		const today = this.moment();
		const diffInspection = this.moment().subtract(8, "days").date();
		return elevators.filter(elevator => {
			let filteredElevatorList = elevator.elev_inspection_days
				.filter(d => d.match(/\d+/gi))
				.filter(d => {
					return d == diffInspection
				})
				.filter(() => {
					const diffLastInspection = parseInt(this.moment.duration(today.diff(elevator.elev_last_inspection)).asDays());
					if (diffLastInspection > 11) {
						elevator.daysSinceLastInspection = diffLastInspection;
					}
					return diffLastInspection > 11;
				});
			return filteredElevatorList.length > 0
		});
	}

	getPastDayElevators(elevators) {
		const today = this.moment();
		const diffInspection = this.moment().subtract(1, "days").format('dd');
		return elevators.filter(elevator => {
			let filteredElevatorList = elevator.elev_inspection_days
				.filter(d => d.match(/\D+/gi))
				.filter(d => {
					return d == diffInspection
				})
				.filter(() => {
					const diffLastInspection = parseInt(this.moment.duration(today.diff(elevator.elev_last_inspection)).asDays());
					if (diffLastInspection >= 1) {
						elevator.daysSinceLastInspection = diffLastInspection;
					}
					return diffLastInspection >= 1;
				});
			return filteredElevatorList.length > 0
		});
	}

	async cronjob() {
		const elevators = await this.db.select('*').from('elevator_view');
		const todaysDateElevators = this.getTodayDateElevators(elevators);
		const todaysDayElevators = this.getTodayDayElevators(elevators);
		const pastDateElevators = this.getPastDateElevators(elevators);
		const pastDayElevators = this.getPastDayElevators(elevators);

		// console.log(elevators.length);
		// console.log('todaysDateElevators',todaysDateElevators.length);
		// console.log('todaysDayElevators',todaysDayElevators.length);
		// console.log('pastDateElevators',pastDateElevators.length);
		// console.log('pastDayElevators',pastDayElevators.length);

		let users = {};

		users = this.addToUsers(users, todaysDateElevators, ['elev_inspector', 'elev_substitute'], 'today_elevators');
		users = this.addToUsers(users, todaysDayElevators, ['elev_inspector', 'elev_substitute'], 'today_elevators');
		users = this.addToUsers(users, pastDateElevators, ['elev_inspector', 'elev_substitute', 'esta_stakeholder'], 'past_date_elevators');
		users = this.addToUsers(users, pastDayElevators, ['elev_inspector', 'elev_substitute', 'esta_stakeholder'], 'past_day_elevators');
		// console.log(users);
		try {
			const emailPromises = []
			for (const key in users) {
				if (users.hasOwnProperty(key)) {
					const user = users[key];
					const emailContent = reminderEmail.buildEmail(user, this.pastDates, this.pastDays);
					if (emailContent) {
						user.pers_email_addresses.forEach((emailAddress) => {
							emailPromises.push(reminderEmail.send(emailAddress.email_address, emailContent));
						})
					}
				}
			}
			const result = await Promise.all(emailPromises);
		} catch (error) {
			console.log(error);
		}
	}


}

module.exports = InspectionReminderCronjob;