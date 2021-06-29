const boom = require('boom');

class Routes  {
	constructor(path = '', queries = null, hal = null, validation = null) {
		this.baseUrl = `${global.global.__domain}`;
		this.path = `${global.__apiVersion}${path}`;
		this.queries = queries;
		this.hal = hal;
		this.validation = validation;		
		this.routes = [];
		if(queries && hal && validation){
			this.addStandardApiRoutes();
		}
	}

	addRoute(route, withTrailingSlash = true){
		this.routes.push(route);
		if(withTrailingSlash) {
			let routeClone = Object.assign({}, route);
			routeClone.path += '/';
			this.routes.push(routeClone);
		}		
	}

	getRoutes(){
		return this.routes;
	}

	addStandardApiRoutes(){
		this.addRoute({
			method: 'GET',
			path: `/${this.path}`,
			handler: (request, reply)=>{
				const queryParams = request.query;
				let query = null;
				let callback = (result)=>{
					queryParams.limit = queryParams.limit | this.queries.limit;
					queryParams.offset = queryParams.offset | this.queries.offset;
					reply(this.hal.transformGet({auth: request.auth.credentials, baseUrl: this.baseUrl, path: this.path, items: result, limit: queryParams.limit, offset: queryParams.offset, type: 'collection'}))
				};

				if(queryParams.search){
					query = this.queries.search(request.auth.credentials, queryParams.search, queryParams.limit, queryParams.offset);
				}
				else if (queryParams.check){
					query = this.queries.check(request.auth.credentials, queryParams.check)
					callback = (result)=>{
						reply(result)
					}
				}
				else{
					query = this.queries.get(request.auth.credentials, undefined, queryParams.limit, queryParams.offset)
				}

				query.then((result)=>{
					callback(result);
				}).catch(err=>{
					console.log(err);
					reply(boom.badImplementation(err));
				})
			},
			config:{
				validate: this.validation.get(),
				auth: {
					strategy: 'jwt'
				}
			}
		});

		this.addRoute({
			method: 'GET',
			path: `/${this.path}/{id}`,
			handler: (request, reply)=>{
				this.queries.getById(request.auth.credentials, request.params.id).then((result)=>{
					reply(this.hal.transformGet({auth: request.auth.credentials, baseUrl: this.baseUrl, path: this.path, items: result, type: 'singleton'}))
				}).catch(err=>{
					console.log(err);
					reply(boom.badImplementation(err));
				})
			},
			config: {
				auth: {
					strategy: 'jwt'
				},
			}
		});

		this.addRoute({
			method: 'POST',
			path: `/${this.path}`,
			handler: (request, reply)=>{
				this.queries.post(request.auth.credentials, request.payload).then((result)=>{
					return this.queries.getById(request.auth.credentials, result)
				})
				.then((result)=>{
					reply(this.hal.transformGet({auth: request.auth.credentials, baseUrl: this.baseUrl, path: this.path, items: result, type: 'singleton'})).code(201)
				})
				.catch(err=>{
					console.log(err);
					if(err.name == 'ValidationError'){
						reply(boom.badRequest(JSON.stringify(err.details, null, 0)))
					}
					else
						reply(boom.badImplementation(err));
				})
			},
			config:{
				validate: this.validation.post(),
				auth: {
					scope: ['admin', 'manager', 'owner_selfmanaged'],
					strategy: 'jwt'
				},
			}
		});

		this.addRoute({
			method: 'PUT',
			path: `/${this.path}`,
			handler: (request, reply)=>{
				this.queries.put(request.auth.credentials, request.payload).then((result)=>{
					return this.queries.getById(request.auth.credentials, result)
				})
				.then((result)=>{
					reply(this.hal.transformGet({auth: request.auth.credentials, baseUrl: this.baseUrl, path: this.path, items: result, type: 'singleton'}))
				})
				.catch(err=>{
					console.log(err);
					if(err.name == 'ValidationError'){
						reply(boom.badRequest(JSON.stringify(err.details, null, 0)))
					}
					else
						reply(boom.badImplementation(err));
				})
			},
			config:{
				validate: this.validation.put(),
				auth: {
					scope: ['admin', 'manager', 'owner_selfmanaged'],
					strategy: 'jwt'
				},
			}
		});

		this.addRoute({
			method: 'PUT',
			path: `/${this.path}/{id}`,
			handler: (request, reply)=>{
				request.payload['_id'] = request.params.id;
				this.queries.put(request.auth.credentials, request.payload).then((result)=>{
					return this.queries.getById(request.auth.credentials, result)
				})
				.then((result)=>{
					reply(this.hal.transformGet({auth: request.auth.credentials, baseUrl: this.baseUrl, path: this.path, items: result, type: 'singleton'}))
				})
				.catch(err=>{
					console.log(err);
					if(err.name == 'ValidationError'){
						reply(boom.badRequest(JSON.stringify(err.details, null, 0)))
					}
					else
						reply(boom.badImplementation(err));
				})
			},
			config:{
				validate: this.validation.putById(),
				auth: {
					scope: ['admin', 'manager', 'owner_selfmanaged'],
					strategy: 'jwt'
				},
			}
		});

		this.addRoute({
			method: 'PATCH',
			path: `/${this.path}`,
			handler: (request, reply)=>{
				this.queries.put(request.auth.credentials, request.payload).then((result)=>{
					return this.queries.getById(request.auth.credentials, result)
				})
				.then((result)=>{
					reply(this.hal.transformGet({auth: request.auth.credentials, baseUrl: this.baseUrl, path: this.path, items: result, type: 'singleton'}))
				})
				.catch(err=>{
					console.log(err);
					if(err.name == 'ValidationError'){
						reply(boom.badRequest(JSON.stringify(err.details, null, 0)))
					}
					else
						reply(boom.badImplementation(err));
				})
			},
			config:{
				validate: this.validation.patch(),
				auth: {
					scope: ['admin', 'manager', 'owner_selfmanaged'],
					strategy: 'jwt'
				},
			}
		});

		this.addRoute({
			method: 'PATCH',
			path: `/${this.path}/{id}`,
			handler: (request, reply)=>{
				request.payload['_id'] = request.params.id;
				this.queries.put(request.auth.credentials, request.payload).then((result)=>{
					return this.queries.getById(request.auth.credentials, result)
				})
				.then((result)=>{
					reply(this.hal.transformGet({auth: request.auth.credentials, baseUrl: this.baseUrl, path: this.path, items: result, type: 'singleton'}))
				})
				.catch(err=>{
					console.log(err);
					if(err.name == 'ValidationError'){
						reply(boom.badRequest(JSON.stringify(err.details, null, 0)))
					}
					else
						reply(boom.badImplementation(err));
				})
			},
			config:{
				validate: this.validation.patchById(),
				auth: {
					scope: ['admin', 'manager', 'owner_selfmanaged'],
					strategy: 'jwt'
				},
			}
		});

		this.addRoute({
			method: 'DELETE',
			path: `/${this.path}/{id}`,
			handler: (request, reply)=>{
				this.queries.delete(request.params.id).then((result)=>{
					// request.payload['_id'] = request.params.id;
					if (this.queries.deleteConnection) { //When owner_selfmanaged user is deleted or insepector/elevator/estate created by owner_selfmanaged is deleted
						this.queries.deleteConnection(request.auth.credentials, request.params);
					}
					reply(result)
				}).catch(err=>{
					reply(boom.badImplementation(err));
				})
			},
			config:{
				validate: this.validation.delete(),
				auth: {
					scope: ['admin', 'manager', 'owner_selfmanaged'],
					strategy: 'jwt'
				},
			}
		});
	}
}

module.exports = Routes;