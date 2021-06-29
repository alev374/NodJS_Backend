const Route = require(__base + 'routes/master/route');
const Auth = require(__base + 'server_utils/auth');
const Joi = require('joi');
const boom = require('boom');

module.exports = (db)=>{
	let auth = new Route('auth');
	auth.addRoute({
		method: 'GET',
		path: `/${auth.path}`,
		handler: (request, reply)=>{
			reply(request.auth.credentials)
		},
		config:{
			auth: {
				strategies: ['simple', 'jwt']
			}
		}
	});

	// password reset
	auth.addRoute({
		method: 'POST',
		path: `/${auth.path}/reset`,
		handler: (request, reply)=>{
			Auth.resetPassword(db, request.payload.pers_username)
			.then((result)=>{
				reply(result)		
			})
			.catch((err)=>{
				reply(err);
			})			
		},
		config:{
			validate: {
				payload: {
					pers_username: Joi.string().min(4).required(),
				}				
			}
		}
	});

	// password change
	auth.addRoute({
		method: 'POST',
		path: `/${auth.path}/change`,
		handler: (request, reply)=>{
			Auth.changePassword(db, request.payload.pers_username, request.payload.pers_password, request.payload.pers_new_password)
			.then((result)=>{
				reply(result)		
			})
			.catch((err)=>{
				reply(err);
			})	
		},
		config:{
			validate: {
				payload: {
					pers_username: Joi.string().min(4).required(),
					pers_password: Joi.string().min(8).required(),
					pers_new_password: Joi.string().min(8).required(),
				}				
			}
		}
	});

	
	return auth.getRoutes();
}