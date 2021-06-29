const Cronjob = require(__base + 'cronjobs/cronjob');
const reportEmail = require(__base + 'email/report_email');
const Queries = require(__base + 'api/service_utils/queries')

class ReportCronjob extends Cronjob {
	constructor(db, interval) {
		super(db, interval);
		this.queries = new Queries(db)
	}

	getSelect(currentHour){
		return `
			person.pers_id, person.pers_email_addresses, jsonb_agg(stakeholder.report) as reports from person 
			left join
			(
				select pers_scope, pers_id, jsonb_array_elements(pers_email_addresses) ->> 'email_notification_time' as email_notification_time,
				jsonb_array_elements(stakeholder_reports) as report
				from person_view
				where pers_scope = 'owner'
			) stakeholder
			on stakeholder.pers_id = person.pers_id
			where stakeholder.email_notification_time = '${currentHour}'
			and
			stakeholder.report is not null
			and
			(
			        select not exists(
			                select 1 from report_delivery_log
			                where
			                repo_id = stakeholder.report ->> 'repo_id'
			                and
			                pers_id = stakeholder.pers_id
			        )
			)
			group by person.pers_id, person.pers_email_addresses
		`
	}

	cronjob(){
		const currentHour = this.moment().hour();
		let stakeholders = [];
		this.db.select(this.db.raw(this.getSelect(currentHour)))
		.then((result)=>{
			let emailPromises = [];
			let promise = null;
			stakeholders = result;
			stakeholders.forEach((stakeholder)=>{
				const emailContent = reportEmail.buildEmail(stakeholder.reports);
				if(emailContent){
					stakeholder.pers_email_addresses.forEach((emailAddress)=>{
						emailPromises.push(reportEmail.send(emailAddress.email_address, emailContent));
					})
				}
			});
			return Promise.all(emailPromises);
		})
		.then((result)=>{
			if(result.length > 0){
				let data = []
				stakeholders.forEach((stakeholder)=>{
					stakeholder.reports.forEach((report)=>{
						data.push({pers_id: stakeholder.pers_id, repo_id: report.repo_id});
					})
				})
				return this.queries._upsert(data, 'report_delivery_log');				
			}
			console.log('no unsent reports found');
			return null;
		})
		.then((result)=>{
		})
		.catch((err)=>{
			console.log(err);
		})
	}


}

module.exports = ReportCronjob;