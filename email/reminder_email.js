const Email = require(__base + 'email/email'); 

class ReminderEmail extends Email {
	constructor() {
		super();
	}

	buildElevatorInfo(elevator){
		return `${elevator.elev_estate.esta_address.address_street_name} ${elevator.elev_estate.esta_address.address_street_number}, ${elevator.elev_estate.esta_address.address_zipcode}  ${elevator.elev_estate.esta_address.address_city}, ${elevator.elev_estate.esta_address.address_country} | Seriennummer: ${elevator.elev_serial_number} | Typ: ${elevator.elev_type}${elevator.daysSinceLastInspection ? ' | Fällig seit: ' + elevator.daysSinceLastInspection + ' Tagen' : ''} \r\n`;
	}

	buildHTMLElevatorInfo(elevator) {
		return `${elevator.elev_estate.esta_address.address_street_name} ${elevator.elev_estate.esta_address.address_street_number}, ${elevator.elev_estate.esta_address.address_zipcode}  ${elevator.elev_estate.esta_address.address_city}, ${elevator.elev_estate.esta_address.address_country} | Seriennummer: ${elevator.elev_serial_number} | Typ: ${elevator.elev_type}${elevator.daysSinceLastInspection ? ' | Fällig seit: ' + elevator.daysSinceLastInspection + ' Tagen' : ''} <br>`;
	}

	buildEmail(user, pastDates, pastDays){
		let isContentAppended = false;
		let subject = 'Aufzugwärter - Erinnerung an fällige Aufzüge';
		let emailText = `Sehr geehrter Aufzugwärter/in \r\n\r\n`;
		let emailHTML = `Sehr geehrter Aufzugwärter/in <br><br>`;
		if(user.inspector_today_elevators){
			const today = this.moment().format('LLLL').slice(0, -6);
			emailText += `Folgende Aufzüge sind heute ${today} fällig:\r\n\r\n`;
			emailHTML += `Folgende Aufzüge sind heute ${today} fällig:<br><br>`;
			user.inspector_today_elevators.forEach((elevator)=>{
				emailText += this.buildElevatorInfo(elevator);
				emailHTML += this.buildHTMLElevatorInfo(elevator);
			});
			emailText += '\r\n\r\n';
			emailHTML += '<br><br>';
			isContentAppended = true;
		}
		if(user.inspector_past_day_elevators){
			emailText += `Folgende Aufzüge sind bereits seit Gestern fällig:\r\n\r\n`;
			emailHTML += `Folgende Aufzüge sind bereits seit Gestern fällig:<br><br>`;
			user.inspector_past_day_elevators.forEach((elevator)=>{
				emailText += this.buildElevatorInfo(elevator);
				emailHTML += this.buildHTMLElevatorInfo(elevator);
			});
			emailText += '\r\n\r\n';
			emailHTML += '<br><br>';
			isContentAppended = true;
		}
		if(user.inspector_past_date_elevators){
			emailText += `Folgende Aufzüge sind bereits seit mehr als ${pastDates} Tagen fällig:\r\n\r\n`;
			emailHTML += `Folgende Aufzüge sind bereits seit mehr als ${pastDates} Tagen fällig:<br><br>`;
			user.inspector_past_date_elevators.forEach((elevator)=>{
				emailText += this.buildElevatorInfo(elevator);	
				emailHTML += this.buildHTMLElevatorInfo(elevator);	
			});
			emailText += '\r\n\r\n';
			emailHTML += '<br><br>';
			isContentAppended = true;
		}
		if(user.substitute_today_elevators){
			emailText += `Folgende Aufzüge sind heute ${this.moment().format('LLLL').slice(0,-6)} in Vertretung fällig:\r\n\r\n`;
			emailHTML += `Folgende Aufzüge sind heute ${this.moment().format('LLLL').slice(0, -6)} in Vertretung fällig:<br><br>`;
			user.substitute_today_elevators.forEach((elevator)=>{
				emailText += this.buildElevatorInfo(elevator);
				emailHTML += this.buildHTMLElevatorInfo(elevator);
			});
			emailText += '\r\n\r\n';
			emailHTML += '<br><br>';
			isContentAppended = true;
		}
		if(user.substitute_past_day_elevators){
			emailText += `Folgende Aufzüge sind bereits seit Gestern in Vertretung fällig:\r\n\r\n`;
			emailHTML += `Folgende Aufzüge sind bereits seit Gestern in Vertretung fällig:<br><br>`;
			user.substitute_past_day_elevators.forEach((elevator)=>{
				emailText += this.buildElevatorInfo(elevator);
				emailHTML += this.buildHTMLElevatorInfo(elevator);
			});
			emailText += '\r\n\r\n';
			emailHTML += '<br><br>';
			isContentAppended = true;
		}
		if(user.substitute_past_date_elevators){
			emailText += `Folgende Aufzüge sind bereits seit ${pastDates} Tagen in Vertretung fällig:\r\n\r\n`;
			emailHTML += `Folgende Aufzüge sind bereits seit ${pastDates} Tagen in Vertretung fällig:<br><br>`;
			user.substitute_past_date_elevators.forEach((elevator)=>{
				emailText += this.buildElevatorInfo(elevator);
				emailHTML += this.buildHTMLElevatorInfo(elevator);
			});
			emailText += '\r\n\r\n';
			emailHTML += '<br><br>';
			isContentAppended = true;
		}
		if(user.stakeholder_past_day_elevators){
			emailText += `Folgende Aufzüge sind bereits seit Gestern fällig und wurden noch nicht geprüft:\r\n\r\n`;
			emailHTML += `Folgende Aufzüge sind bereits seit Gestern fällig und wurden noch nicht geprüft:<br><br>`;
			user.stakeholder_past_day_elevators.forEach((elevator)=>{
				emailText += this.buildElevatorInfo(elevator);
				emailHTML += this.buildHTMLElevatorInfo(elevator);
			});
			emailText += '\r\n\r\n';
			emailHTML += '<br><br>';
			isContentAppended = true;
		}
		if(user.stakeholder_past_date_elevators){
			emailText += `Folgende Aufzüge sind bereits seit ${pastDates} Tagen fällig und wurden noch nicht geprüft:\r\n\r\n`;
			emailHTML += `Folgende Aufzüge sind bereits seit ${pastDates} Tagen fällig und wurden noch nicht geprüft:<br><br>`;
			user.stakeholder_past_date_elevators.forEach((elevator)=>{
				emailText += this.buildElevatorInfo(elevator);
				emailHTML += this.buildHTMLElevatorInfo(elevator);
			});
			emailText += '\r\n\r\n';
			emailHTML += '<br><br>';
			isContentAppended = true;
		}
		if(user.pers_scope == 'inspector'){
			emailText += `Viel Erfolg bei der Prüfung!`;
			emailHTML += `Viel Erfolg bei der Prüfung!`;
		}
		emailText += `${(user.pers_scope == 'inspector') ?  '\r\n\r\n': ''}Diese E-Mail wurde automatisch generiert. Bitte antworten Sie nicht auf diese E-Mail.`;
		emailHTML += `${(user.pers_scope == 'inspector') ? '<br><br>' : ''}Diese E-Mail wurde automatisch generiert. Bitte antworten Sie nicht auf diese E-Mail.`;

		if(isContentAppended){
			return { subject: subject, text: emailText, html: emailHTML};
		}
		else{
			return null;
		}
	}
}

module.exports = new ReminderEmail();