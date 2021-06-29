const HAL = require(__base + 'api/service_utils/hal');

class CheckpointHal extends HAL{

	constructor() {
		super();
	}

	transformGet(response = {auth: {}, baseUrl: '', path: '', items: [], limit: 0, offset: 0}){
		let elementTransform = (element)=>{
			element.chpo_checklists = this._createSubResource(element.chpo_checklists, response.baseUrl, 'checklist', 'chli_id');
			element.aclo_owners = this._createSubResource(element.aclo_owners, response.baseUrl, 'user', 'aclo_owner');
			
			delete element.chpo_fulltext;
			if(response.auth.scope != 'admin' && response.auth.scope != 'manager'){
				delete element.aclo_owners;
			}

			return element
		}
		return super.transformGet(response, 'chpo_id', elementTransform);
	}
}

module.exports = CheckpointHal;