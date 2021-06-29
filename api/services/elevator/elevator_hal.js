const HAL = require(__base + 'api/service_utils/hal');

class ElevatorHal extends HAL{

	constructor() {
		super(false);
	}

	transformGet(response = {auth: {}, baseUrl: '', path: '', items: [], limit: 0, offset: 0}){		
		let elementTransform = (element)=>{
			element.elev_estate = this._createSubResource(element.elev_estate, response.baseUrl, 'estate', 'esta_id');
			element.elev_inspector = this._createSubResource(element.elev_inspector, response.baseUrl, 'user', 'pers_id');
			element.elev_substitute = this._createSubResource(element.elev_substitute, response.baseUrl, 'user', 'pers_id');
			element.elev_checklist = this._createSubResource(element.elev_checklist, response.baseUrl, 'checklist', 'chli_id');
			element.elev_checkpoints = this._createSubResource(element.elev_checkpoints, response.baseUrl, 'checkpoint', 'chpo_id');
			element.aclo_owners = this._createSubResource(element.aclo_owners, response.baseUrl, 'user', 'aclo_owner');
			try {
				element.elev_reports.forEach((report, index)=>{
					element.elev_reports[index] = this._createSubResource({repo_id: report.repo_id, esta_address: report.esta_address, repo_creation: report.repo_creation}, response.baseUrl, 'report', 'repo_id');
					element.elev_reports[index]._links.self.pdf = `${element.elev_reports[index]._links.self.href}/pdf`;
				})
			} catch(e) {
				// console.log(e);
			}

			delete element.elev_inspector_short;
			delete element.elev_substitute_short;
			delete element.pers_inspector_id;
			delete element.pers_substitute_id;
			delete element.esta_id;
			delete element.chli_id;
			delete element.elev_fulltext;

			if(response.auth.scope != 'admin' && response.auth.scope != 'manager'){
				delete element.aclo_owners;
			}
			// element.isTemplated = true;
			return element
		}
		return super.transformGet(response, 'elev_id', elementTransform);
	}
}

module.exports = ElevatorHal;