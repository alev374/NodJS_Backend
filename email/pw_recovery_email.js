const Email = require(__base + 'email/email'); 

class PwRecoveryEmail extends Email {
	constructor() {
		super();
	}

	buildEmail(username, password){
		let subject = 'Aufzugwärter - Ihr neues Passwort';
		let emailText = `Guten Tag, \r\n\r\n`;
		emailText += `für Ihr Benutzerkonto mit dem Benutzernamen ${username} liegt ein neues Passwort vor:\r\n\r\n`;
		emailText += `${password}`; 
		emailText += `\r\n\r\nBitte verwahren Sie es sicher auf.`;
		// emailText += `\r\n\r\nFalls Sie das Passwort ändern möchten, öffenen Sie bitte folgenden Link:`;
		// emailText += `\r\n\r\nhttps://www.aufzugwaerter.info/kundenbereich/passwort-aenderung`;
		emailText += `\r\n\r\nDiese E-Mail wurde automatisch generiert. Bitte antworten Sie nicht auf diese E-Mail.`
		return {subject: subject, text: emailText, html: null};
	}
}

module.exports = new PwRecoveryEmail();