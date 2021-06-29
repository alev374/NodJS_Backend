const HAL = require(__base + 'api/service_utils/hal');

class ChecklistHal extends HAL{

	constructor() {
		super();
	}

	transformGet(response = {auth: {}, baseUrl: '', path: '', items: [], limit: 0, offset: 0}){
		let elementTransform = (element)=>{
			element.chli_checkpoints = this._createSubResource(element.chli_checkpoints, response.baseUrl, 'checkpoint', 'chpo_id');
			element.aclo_owners = this._createSubResource(element.aclo_owners, response.baseUrl, 'user', 'aclo_owner');
			
			delete element.chli_fulltext;
			if(response.auth.scope != 'admin' && response.auth.scope != 'manager'){
				delete element.aclo_owners;
			}

			return element
		}
		return super.transformGet(response, 'chli_id', elementTransform);
	}
}

module.exports = ChecklistHal;