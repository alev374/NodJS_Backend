const Email = require(__base + 'email/email'); 

class ReportEmail extends Email {
	constructor() {
		super();
	}
	
	buildEmail(reports = []){
		if(reports.length == 0){
			return null;
		}
		let subject = 'Aufzugwärter - Neue Prüfprotokolle Ihrer Aufzüge';
		let emailText = '';
		let emailHTML = '';
		let repo_ids = [];
		emailText = 'Guten Tag,\r\n\r\nfür Ihre Aufzüge liegen neue Prüfprotokolle zum Herunterladen bereit:\r\n\r\n';
		emailHTML = 'Guten Tag,<br/><br/>für Ihre Aufzüge liegen neue Prüfprotokolle zum Herunterladen bereit:<br/><br/>';
		let reportUri = '';
		let esta_address = '';
		reports.forEach((report)=>{
			repo_ids.push(report.repo_id);
			reportUri = `${global.global.__domain}/reports/${report.repo_id}/pdf`;
			esta_address = `${report.esta_address.address_street_name} ${report.esta_address.address_street_number}, ${report.esta_address.address_zipcode}  ${report.esta_address.address_city}, ${report.esta_address.address_country}`
			emailText += `${esta_address}:\r\n`;
			emailHTML += `${esta_address}:<br/>`;
			emailText += `${reportUri}\r\n\r\n`
			emailHTML += `<a href="${reportUri}">${reportUri}</a><br/><br/>`
		})
		emailText += `\r\n\r\nDiese E-Mail wurde automatisch generiert. Bitte antworten Sie nicht auf diese E-Mail.`
		return {subject: subject, text: emailText, html: emailHTML, repo_ids: repo_ids}
	}
}

module.exports = new ReportEmail();