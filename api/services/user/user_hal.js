const HAL = require(__base + 'api/service_utils/hal');

class UsersHal extends HAL{

	constructor() {
		super();
	}

	transformGet(response = {auth: {}, baseUrl: '', path: '', items: [], limit: 0, offset: 0}){
		let elementTransform = (element)=>{
			element.pers_inspector_elevators = this._createSubResource(element.pers_inspector_elevators, response.baseUrl, 'elevator', 'elev_id');
			element.pers_substitute_elevators = this._createSubResource(element.pers_substitute_elevators, response.baseUrl, 'elevator', 'elev_id');
			element.pers_estates = this._createSubResource(element.pers_estates, response.baseUrl, 'estate', 'esta_id');
			element.aclo_owners = this._createSubResource(element.aclo_owners, response.baseUrl, 'user', 'aclo_owner');
			try {
				element.inspector_reports.forEach((report, index)=>{
					element.inspector_reports[index] = this._createSubResource({repo_id: report.repo_id, esta_address: report.esta_address, repo_creation: report.repo_creation}, response.baseUrl, 'report', 'repo_id');
				});
				element.substitute_reports.forEach((report, index)=>{
					element.substitute_reports[index] = this._createSubResource({repo_id: report.repo_id, esta_address: report.esta_address, repo_creation: report.repo_creation}, response.baseUrl, 'report', 'repo_id');
				});
				element.stakeholder_reports.forEach((report, index)=>{
					element.stakeholder_reports[index] = this._createSubResource({repo_id: report.repo_id, esta_address: report.esta_address, repo_creation: report.repo_creation}, response.baseUrl, 'report', 'repo_id');
				});
			} catch(e) {
				// console.log(e);
			}
			delete element.pers_fulltext;
			if(response.auth.scope != 'admin' && response.auth.scope != 'manager'){
				delete element.aclo_owners;
			}
			return element;
		}

		let items = [];
		response.items.forEach(item => {
			if (item.pers_scope == 'admin' || item.pers_scope == 'manager'){
				if (response.auth.scope == 'admin' || response.auth.pers_id == item.pers_id)
					items.push(item);
			} 
			else{
				items.push(item);
			}
		})
		response.items = items;
		return super.transformGet(response, 'pers_id', elementTransform);
	}
}

module.exports = UsersHal;