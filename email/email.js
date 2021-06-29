const nodemailer = require('nodemailer');
const moment = require('moment');
moment.locale('de')

const emailConfig = require('../email_config');
const nodeEnv = process.env.NODE_ENV;

class Email {
	constructor() {
		this.moment = moment;
		this.transporter = nodemailer.createTransport(emailConfig['production']);
		this.defaultFrom = 'no-reply@aufzugwaerter.info';
	}

	buildEmail(data){
		return {subject: null, emailText: null, emailHTML: null}
	}

	send(to = null, content = {'subject': null, 'text': null, 'html': null}, from = this.defaultFrom){
		const options = {from: from, to: to, subject: content.subject, text: content.text, html: content.html}
		return new Promise((resolve, reject) => {
			this.transporter.sendMail(options, (error, info) => {
				if (error) {
					return reject(error);
				}
				resolve(`Message ${info.messageId} sent: ${info.response} to: ${to}`);
			});
		});
	}	
}

module.exports = Email;