const HAL = require(__base + 'api/service_utils/hal');

class EstateHal extends HAL{

	constructor() {
		super();
	}

	transformGet(response = {auth: {}, baseUrl: '', path: '', items: [], limit: 0, offset: 0}){
		let elementTransform = (element)=>{
			element.esta_elevators = this._createSubResource(element.esta_elevators, response.baseUrl, 'elevator', 'elev_id');
			element.aclo_owners = this._createSubResource(element.aclo_owners, response.baseUrl, 'user', 'aclo_owner');

			try {
				element.esta_reports.forEach((report, index)=>{
					element.esta_reports[index] = this._createSubResource({repo_id: report.repo_id, esta_address: report.esta_address, repo_creation: report.repo_creation, repo_elevator: report.repo_elevator}, response.baseUrl, 'report', 'repo_id');
					element.esta_reports[index]._links.self.pdf = `${element.esta_reports[index]._links.self.href}/pdf`;
				})
			} catch(e) {
				// console.log(e);
			}

			delete element.esta_fulltext;
			if(response.auth.scope != 'admin' && response.auth.scope != 'manager'){
				delete element.aclo_owners;
				delete element.esta_stakeholders;
			}
			return element
		}
		return super.transformGet(response, 'esta_id', elementTransform);
	}
}

module.exports = EstateHal;