const Queries = require(__base + 'api/service_utils/queries');
const timestamp = require(__base + 'api/service_utils/timestamp');
const mkdirp = require('mkdirp');
const reportPdf = require(__base + 'api/services/report/report_pdf');
const notificationEmail = require(__base + 'email/emergency_notification_email');
const fileUpload = require(__base + 'server_utils/file_upload');

class ReportQueries extends Queries{
	constructor(db, table, table_id, table_fulltext, table_alias) {
		super(db, table, table_id, table_fulltext, table_alias);
		this.size = 30;
		this.limit = 25;
	}

	get(auth = {}, select = '', limit = this.limit, offset = this.offset, search, table = `${this.table}_view`){
		if(select == ''){
			select= `${this.table}_view.*`;
		}
		return super.get(auth, select, limit, offset, search, table, this.table_id, this.table_alias);
	}

	getById(auth = {}, id = '', table_id= `${this.table}_view.${this.table_id}`){
		return this.get(auth, `${this.table}_view.*`).where(table_id, id);
	}

	getPdfs(auth = {}, id = '', table_id= `${this.table}.${this.table_id}`){

	}

	search(auth = {}, search = '', limit = this.limit, offset = this.offset, table_fulltext = this.table_fulltext, select = `${this.table}.*`, table = this.table){
		select = `${this.table}.repo_id,
		json_build_object('pers_id', repo_inspector ->> 'pers_id', 'pers_firstname', repo_inspector ->> 'pers_firstname', 'pers_lastname', repo_inspector ->> 'pers_lastname') as repo_inspector,
		json_build_object('elev_id', repo_elevator ->> 'elev_id', 'elev_serial_number', repo_elevator ->> 'elev_serial_number', 'elev_barcode', repo_elevator ->> 'elev_barcode', 'elev_type', repo_elevator ->> 'elev_type') as repo_elevator,
		json_build_object('esta_id', repo_estate ->> 'esta_id', 'esta_address', repo_estate -> 'esta_address') as repo_estate,
		repo_creation`;
		return super.search(auth, search, limit, offset, table_fulltext, select, table)
	}

	post(auth = {}, data = {}){
		const images = []
		console.log("Reports Post Request Body ==== ", data);
		data.repo_checkpoints.forEach((checkpoint)=>{
			checkpoint.chpo_images.forEach((image)=>{
				image.image_filename = image.image_filename.replace(/\s+/g, '_').replace(/Ä/g,'Ae').replace(/ä/g,'ae').replace(/Ö/g,'Oe').replace(/ö/g,'oe').replace(/Ü/g,'Ue').replace(/ü/g,'ue').replace(/ß/g,'ss');
				image.image_filename = encodeURIComponent(image.image_filename);
				images.push(Object.assign({chpo_id: checkpoint.chpo_id}, image));
				delete image.image_base64;
			});
		});
		const rawData = Object.assign({}, data);
		let repo_id = null;
		let elev_id = null;
		return super.post(auth, data, this.table, this.table_id, true, this.size)
		.then((id)=>{
			repo_id = id;
			rawData.repo_id = id;
			return this.createReportDirectory(repo_id, rawData)
			.then((result)=>{
				elev_id = result;
			})
		})
		.then(()=>{
			// upload images
			return fileUpload.saveFiles(images,`${elev_id}/${repo_id}`)
		})
		.then(()=>{
			data.repo_creation = timestamp();
			rawData.repo_creation = timestamp();
			return reportPdf.createPDF(`${elev_id}/${repo_id}`, `${repo_id}`, rawData);
		})
		.then(()=>{
			let emails = this.createDeficiencyEmail(rawData, repo_id);
			return Promise.all(emails);
		})
		.then((result)=>{
			return repo_id;
		})
		.catch((error)=>{
			console.log(error);
		})
	}

	createReportDirectory(repo_id, data){
		return new Promise((resolve, reject) => {
			const elev_id = data.repo_elevator.elev_id;
			if (elev_id && repo_id){
				mkdirp(`files/reports/${elev_id}/${repo_id}`, function (err) {
					if (err) reject(err)
					else resolve(elev_id)
				});
			}
			else{
				throw new Error(`Could not create directory: files/reports/${elev_id}/${repo_id}`);					
			}
		});
	}

	createDeficiencyEmail(data, repo_id){
		let emailPromises = [];
		let checkpoints = data.repo_checkpoints;
		let estate = data.repo_estate;
		let elevator = data.repo_elevator;
		let prio2 = [];
		let prio1 = [];
		let prio0 = [];
		let isAllCheckpointsOk = true;
		checkpoints.forEach((checkpoint)=>{
			if (checkpoint.chpo_is_ok == false){
				isAllCheckpointsOk = false;
				switch (checkpoint.chpo_priority) {
					case 'Verletzungsgefahr':
						prio2.push(checkpoint);
						break;
					case 'wichtig':
						prio1.push(checkpoint);
						break;
					case 'normal':
						prio0.push(checkpoint);
						break;
					default:
						prio0.push(checkpoint);
						break;
				}
			}
		});
		if(isAllCheckpointsOk){
			return [];
		}
		const emailContent = notificationEmail.buildEmail(repo_id, estate, elevator, prio2, prio1, prio0);
		estate.esta_stakeholders.forEach((stakeholder)=>{
			if(emailContent){
				stakeholder.pers_email_addresses.forEach((email)=>{
					emailPromises.push(notificationEmail.send(email.email_address, emailContent))
				})
			}
		})
		return emailPromises;
	}
}

module.exports = ReportQueries;