const Email = require(__base + 'email/email'); 

class EmergencyNotificationEmail extends Email {
	constructor() {
		super();
	}

	buildEmail(repo_id, estate, elevator, prio2 = [], prio1 = [] , prio0 = []){

		const address = `${estate.esta_address.address_street_name} ${estate.esta_address.address_street_number}, ${estate.esta_address.address_zipcode}  ${estate.esta_address.address_city}, ${estate.esta_address.address_country}`;
		const location = (elevator.elev_location != '') ? ` (${elevator.elev_location})` : '';

		const subject = `Aufzugwärter - Mängelmeldung – ${address}`;
		let emailText = 'Achtung!\r\n\r\n';
		emailText += `Bei der Prüfung des Aufzugs mit der Seriennummer ${elevator.elev_serial_number},\r\n`
		emailText += `${address}${location}\r\n`
		emailText += `traten bei folgenden Prüfpunkten Mängel auf:\r\n\r\n`

		if(prio2.length > 0){
			emailText += `Gefährliche Mängel:\r\n\r\n`
			prio2.forEach((checkpoint)=>{
				emailText += this.deficencyText(repo_id, checkpoint);
			})
		}
		if(prio1.length > 0){
			emailText += `Wichtige Mängel:\r\n\r\n`
			prio1.forEach((checkpoint)=>{
				emailText += this.deficencyText(repo_id, checkpoint);
			})
		}
		if(prio0.length > 0){
			emailText += `Normale Mängel:\r\n\r\n`
			prio0.forEach((checkpoint)=>{
				emailText += this.deficencyText(repo_id, checkpoint);
			})
		}
		emailText += `\r\nDas gesamte Prüfprotokoll können Sie hier herunterladen:\r\nhttps://www.aufzugwaerter.info/api/v1/reports/${repo_id}/pdf`
		emailText += `\r\n\r\nDiese Mängel müssen schnellstmöglich behoben und der Aufzug bis zur Behebung ggf. außer Betrieb genommen werden.`
		emailText += `\r\n\r\nIhre Aufzugwärter`
		emailText += `\r\n\r\nDiese E-Mail wurde automatisch generiert. Bitte antworten Sie nicht auf diese E-Mail.`

		return {subject: subject, text: emailText, html: null}
	}

	deficencyText(repo_id, checkpoint){
		let problem = '';
		if(checkpoint.hasOwnProperty('chpo_annotation')){
			problem = (checkpoint.chpo_annotation == '' || checkpoint.chpo_annotation == null) ? '' : `Mangel: ${checkpoint.chpo_annotation}\r\n`;
		}
		let text =  `Prüfpunkt: ${checkpoint.chpo_headline}\r\n`;
		text += `${problem}`;
		checkpoint.chpo_images.forEach((image, index)=>{
			if(index == 0){
				text += 'Bilder:\r\n'
			}
			text += `https://www.aufzugwaerter.info/api/v1/reports/${repo_id}/images/${image.image_filename}.jpg\r\n`
		})
		text += '\r\n';
		return text;
	}
}

module.exports = new EmergencyNotificationEmail();