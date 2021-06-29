const HAL = require(__base + 'api/service_utils/hal');

class ReportHal extends HAL{

	constructor() {
		super();
	}

	transformGet(response = {auth: {}, baseUrl: '', path: '', items: [], limit: 0, offset: 0}){
		let elementTransform = (element)=>{
			element.repo_elevator = this._createSubResource(element.repo_elevator, response.baseUrl, 'elevator', 'elev_id');
			element.repo_inspector = this._createSubResource(element.repo_inspector, response.baseUrl, 'user', 'pers_id');
			element.repo_estate = this._createSubResource(element.repo_estate, response.baseUrl, 'estate', 'esta_id');
			element.repo_checkpoints = this._createSubResource(element.repo_checkpoints, response.baseUrl, 'checkpoint', 'chpo_id');
			element.aclo_owners = this._createSubResource(element.aclo_owners, response.baseUrl, 'user', 'aclo_owner');

			delete element.repo_fulltext;
			if(response.auth.scope == 'owner'){
				delete element.repo_inspector;
			}
			if(response.auth.scope != 'admin' && response.auth.scope != 'manager'){
				delete element.aclo_owners;
			}
			return element
		}
		let resource = super.transformGet(response, 'repo_id', elementTransform);
		if(typeof resource !== 'undefined' && resource.length == 0){
			return resource;
		}
		if(Object.keys(resource._embedded).length === 0 && resource._embedded.constructor === Object){
			resource._links.self.pdf = `${resource._links.self.href}/pdf`
		}
		else{
			resource._embedded['api/v1/reports'].forEach((element)=>{
				element._links.self.pdf = `${element._links.self.href}/pdf`
			})
		}
		return resource;
	}
}

module.exports = ReportHal;