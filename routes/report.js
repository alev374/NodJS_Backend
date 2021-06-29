const Route = require(__base + 'routes/master/route');
const ReportQueries = require(__base + 'api/services/report/report_queries');
const ReportHal = require(__base + 'api/services/report/report_hal');
const ReportValidationSchema = require(__base + 'api/services/report/report_validation_schema');
const fileUpload = require(__base + 'server_utils/file_upload');
const moment = require('moment');
const fs = require('fs');
const path = require('path');
const reportPdf = require(__base + 'api/services/report/report_pdf');
const boom = require('boom');

module.exports = (db)=>{
	let reports = new Route('reports', new ReportQueries(db, 'report', 'repo_id', 'repo_fulltext', 'repo', true), new ReportHal(), new ReportValidationSchema());
	let postRoute = reports.routes.find((route)=>{return route.method == 'POST'})
	postRoute.config.auth.scope.push('inspector');

	// get pdf by relative path
	reports.addRoute({
		method: 'GET',
		path: `/${reports.path}/{id}/pdf`,
		handler: (request, reply)=>{
			db.select(db.raw(`repo_elevator ->> 'elev_id' elev_id, repo_elevator ->> 'elev_serial_number' elev_serial_number, repo_creation`)).from('report').where('repo_id', request.params.id)
			.then((result)=>{
				if(result.length == 1){
					result = result[0];
					const creation_date = moment(result.repo_creation).format('YYYY_MM_DD');
					reply.redirect(`/${reports.path}/${request.params.id}/${result.elev_id}/${creation_date}_aufzug_${result.elev_serial_number}_protokoll.pdf`);
				}
				else{
					throw new Error('report does not exist');
				}		
			})
			.catch((err)=>{
				console.log(err);
				reply(boom.notFound(err));
			})
		}
	});

	// get pdf by relative path
	reports.addRoute({
		method: 'GET',
		path: `/reports/{id}/pdf`,
		handler: (request, reply) => {
			reply.redirect(`/${reports.path}/${request.params.id}/pdf`);
		}
	});

	reports.addRoute({
		method: 'GET',
		path: `/${reports.path}/{id}/{elev_id}/{filename*}`,
		handler: (request, reply) => {
			reply.redirect(`/${reports.path}/${request.params.id}/${request.params.elev_id}/${encodeURIComponent(request.params.filename.replace('/', '_'))}`);
		}
	}, false);


	// get pdf by absoulte path
	reports.addRoute({
		method: 'GET',
		path: `/${reports.path}/{id}/{elev_id}/{filename}`,
		handler: (request, reply)=>{
			const pdfFilePath = path.resolve(global.__base, `files/reports/${request.params.elev_id}/${request.params.id}/${request.params.id}.pdf`);
			fs.access(pdfFilePath, (err)=>{
				if(err){
					db.select('repo_id', 'repo_checkpoints', 'repo_inspector', 'repo_elevator', 'repo_estate', 'repo_creation').from('report').where('repo_id', request.params.id)
					.then((result)=>{
						if(Array.isArray(result) && result.length === 1){
							return reportPdf.createPDF(`${request.params.elev_id}/${request.params.id}`, `${request.params.id}`, result[0]);
						}
						else{
							reply(boom.badImplementation());
						}
					})
					.then(()=>{
						reply.file(`reports/${request.params.elev_id}/${request.params.id}/${request.params.id}.pdf`);
					})
					.catch((err)=>{
						console.log(err);
						reply(boom.badImplementation(err));
					})
				}
				else{
					reply.file(`reports/${request.params.elev_id}/${request.params.id}/${request.params.id}.pdf`);
				}
			});
		}
	}, false);

	// get pdf by absolute path
	reports.addRoute({
		method: 'GET',
		path: `/reports/{elev_id}/pdfs/{id}`,
		handler: (request, reply) => {
			reply.redirect(`/${reports.path}/${request.params.id.replace('.pdf','')}/pdf`);
		}
	});

	// get report image by absolute path
	reports.addRoute({
		method: 'GET',
		path: `/${reports.path}/{id}/images/{filename}`,
		handler: (request, reply)=>{
			db.select(db.raw(`repo_elevator ->> 'elev_id' elev_id`)).from('report').where('repo_id', request.params.id)
			.then((result)=>{
				if(result.length == 1){
					result = result[0];
					reply.file(`reports/${result.elev_id}/${request.params.id}/${request.params.filename}`);
				}
				else{
					throw new Error('report image not found');
				}		
			})
			.catch((err)=>{
				console.log(err);
			})
			
		}
	});
	
	return reports.getRoutes();
}