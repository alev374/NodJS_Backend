'use strict';
const nodeEnv = process.env.NODE_ENV || 'development';
const serverConfig = require('./server_config');

// global path to directory top
global.__base = __dirname + '/';
global.__domain = serverConfig[nodeEnv].domain;
global.__host = serverConfig[nodeEnv].host;
global.__port = serverConfig[nodeEnv].port;
global.__apiVersion = serverConfig[nodeEnv].apiVersion;

const knexConfig = require('./knex_config');

const Hapi = require('hapi');
const glob = require('glob');
const path = require('path');
const boom = require('boom');
const corsHeaders = require('hapi-cors-headers');
const db = require( 'knex' )(knexConfig[nodeEnv]);
const auth = require(__base + 'server_utils/auth');
const ReportCronjob = require(__base + 'cronjobs/report_cronjob');
const InspectionReminderCronjob = require(__base + 'cronjobs/inspection_reminder_cronjob');

const server = new Hapi.Server();
server.connection({
	port: global.__port,
	host: global.__host,
	routes: {
		files: {
			relativeTo: path.join(__dirname, 'files')
		}
	},

});

server.register([require('hapi-auth-jwt2'), require('hapi-auth-basic'), require('inert')], (err) => {

	server.auth.strategy('simple', 'basic', {
		validateFunc: (request, username, password, callback)=>{
			return auth.validateLogin(db, username, password, callback)
		}
	});

	server.auth.strategy('jwt', 'jwt', {
		key: auth.secret,
		verifyOptions: { algorithms: ['HS256'] },
		validateFunc: (decoded, request, callback)=>{
			return auth.validateToken(db, decoded, request, callback)
		}
	});


	// add homepage routes
	server.route({
		method: 'GET',
		path: '/static/{file*}',
		handler: {
			directory: {
				path: 'homepage/static'
			}
		}
	});

	server.route({
		method: 'GET',
		path: '/downloads/{file*}',
		handler: {
			directory: {
				path: 'homepage/downloads'
			}
		}
	})

	server.route({
		method: 'GET',
		path: '/datenschutz',
		handler: function (request, reply) {
			// reply('test')
			reply.file('homepage/datenschutz/index.html');
		}
	});

	server.route({
		method: 'GET',
		path: '/impressum',
		handler: function (request, reply) {
			// reply('test')
			reply.file('homepage/impressum/index.html');
		}
	});
	
	server.route({
		method: 'GET',
		path: '/',
		handler: function (request, reply) {
			// reply('test')
			reply.file('homepage/index.html');
		}
	});

	// add cms
	server.route({
		method: 'GET',
		path: '/kundenbereich',
		handler: function (request, reply) {
			// reply('test')
			reply.file('cms/index.html');
		}
	});
	server.route({
		method: 'GET',
		path: '/assets/{file*}',
		handler: {
			directory: {
				path: 'cms/assets'
			}
		}
	});
	server.route({
		method: 'GET',
		path: '/fonts/{file*}',
		handler: {
			directory: {
				path: 'cms/fonts'
			}
		}
	});
	server.route({
		method: 'GET',
		path: '/images/{file*}',
		handler: {
			directory: {
				path: 'cms/images'
			}
		}
	});

	// 404 error handling
	server.route({  
		method: [ 'GET', 'POST' ],
		path: '/{any*}',
		handler: (request, reply) => {
			if (request.raw.req.url.match(/api\/v/)) {
				return reply(boom.notFound('This resource isn’t available.'))
			}
			return reply.file('404/index.html');
		}
	})

	// add api routes
	glob.sync('routes/*.js', {
		root: __dirname
	}).forEach(file => {
		const route = require(path.join(__dirname, file));
		server.route(route(db));
	});
});

server.ext('onPreResponse', corsHeaders);

server.start(err =>{
	if(err){
		return;
	}
	console.log( `Server started at ${ server.info.uri }` );
});

// every hour of every work day
const reportCron = new ReportCronjob(db, 'every 1 hour on the first min');
// once every day
const inspectionReminderCron = new InspectionReminderCronjob(db, 'at 8:00 am');

// cronjob tests
// const reportCron = new ReportCronjob(db, 'every 1 seconds');
// const inspectionReminderCron = new InspectionReminderCronjob(db, 'every 10 seconds');