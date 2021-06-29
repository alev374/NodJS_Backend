const hal = require('hal');

class HAL {
	constructor() {
		this.hal = hal;
	}

	_createSubResource(element, baseUrl, table, table_id){
		try{
			if(Array.isArray(element) && element.length == 1 && element[0] == null){
				return [];
			}
			else if(Array.isArray(element) && element.length >= 0){
				element.forEach((data, index)=>{
					if(data != null){
						element[index] = new this.hal.Resource(data, `${baseUrl}/${global.__apiVersion}${table}s/${data[table_id]}`);
					}					
				})
			}
			else if(element != undefined){
				element = new this.hal.Resource(element, `${baseUrl}/${global.__apiVersion}${table}s/${element[table_id]}`);
			}
		} catch(e) {
			console.log(e);
		}
		return element
	}

	_pagination(resource, baseUrl, path, length, limit, offset){
		resource._meta = {length:length};
		if(limit == 0){
			return resource;
		}
		if(length >= limit){
			resource.link('next', `${baseUrl}/${path}?limit=${limit}&offset=${offset+limit}`);
		}
		if(offset >= limit){			
			if((offset - limit) >= 0){
				resource.link('previous', `${baseUrl}/${path}?limit=${limit}&offset=${offset-limit}`);
			}
			else{
				resource.link('previous', `${baseUrl}/${path}?limit=${limit}&offset=0`);
			}
		}
		return resource;
	}

	_createCollection(params = {baseUrl: '', path: '', items: [], limit: 0, offset: 0}, collection){
		const {baseUrl, path, items, limit, offset} = params;
		let resource = new this.hal.Resource({}, `${baseUrl}/${path}`);
		resource = this._pagination(resource, baseUrl, path, items.length, limit, offset);
		resource.link("find", {href: `${baseUrl}/${path}/{id}`});
		resource.embed(path, collection);
		return resource;
	}

	_createSingleton(baseUrl, path, resource){
		resource.link('all', `${baseUrl}/${path}`);
		resource._meta = {length: 1};
		return resource;
	}

	transformGet(response = {auth: {}, baseUrl: '', path: '', items: [], limit: 0, offset: 0, type: ''}, id, elementTransform){
		const {auth, baseUrl, path, items, limit, offset, type} = response;
		
		let result = [];

		items.forEach((element, index, array)=>{
			element = elementTransform(element);
			// const isTemplated = (element.isTemplated && type == 'collection') ? true : false;
			// delete element.isTemplated;
			let resource = new this.hal.Resource(element, `${baseUrl}/${path}/${element[id]}`);
			// resource._links.self['templated'] = isTemplated;
			result.push(resource);
		})

		let resource = null;

		if(type == 'collection' && result.length > 0){
			resource = this._createCollection(response, result);
		}
		else if(type == 'singleton' && result.length > 0){
			resource = this._createSingleton(baseUrl, path, result[0]);
		}
		else{
			resource = [];
		}		
		
		return resource;
	}
}

module.exports = HAL;