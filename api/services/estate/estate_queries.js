const Queries = require(__base + 'api/service_utils/queries');

class CheckpointQueries extends Queries{
	constructor(db, table, table_id, table_fulltext, table_alias) {
		super(db, table, table_id, table_fulltext, table_alias);
	}

	get(auth = {}, select = '', limit = this.limit, offset = this.offset, search = null){
		if(select == ''){
			select = `${this.table}_view.*`;
		}
		return super.get(auth, select, limit, offset, search);
	}

	getById(auth = {}, id = '', table_id= `${this.table}_view.${this.table_id}`){
		return this.get(auth, `${this.table}_view.*`).where(table_id, id);
	}

	search(auth = {}, search = '', limit = this.limit, offset = this.offset, table_fulltext = this.table_fulltext, select = `${this.table}_view.*`){
		select = `${this.table}_view.*`;
		return super.search(auth, search, limit, offset, table_fulltext, select);
	}

	post(auth = {}, data = {}){
		console.log("Estate Post Data ==== ", data);
		let pers_creator = ''; //pers_id when creator is owner_selfmanaged
		if (auth.pers_scope == 'owner_selfmanaged') {
			pers_creator = auth.pers_id;
			data = {
				...data,
				'esta_created_by': pers_creator
			}
		}
		let stakeholders = data.esta_stakeholders;
		delete data.esta_stakeholders;
		let id = null;
		return new Promise((resolve, reject) => {
			if (auth.pers_scope === 'owner_selfmanaged') { // When owner_selfmanaged user add estates
				this.db.select('person_selfmanaged_limit.*').from('person_selfmanaged_limit').whereRaw(`pers_id = '${auth.pers_id}'`)
				.then(result => {
					console.log("Limit check result === ", result);
					if (
						parseInt(result[0].pese_estate_limit ? result[0].pese_estate_limit : 0) == 0 ||
						parseInt(result[0].pese_estate_limit ? result[0].pese_estate_limit : 0) > parseInt(result[0].pese_estate_created ? result[0].pese_estate_created : 0)
						) {
							console.log("Estate can be added!!!!");
							resolve();
						}
					else {
						reject('Estate creation is limited!');
						// throw new Error('User creation is limited')
					}
				})
				.catch(error => {
					reject(error)
				})
			} else {
				resolve()
			}
		}).then(() => {
			return super.post(auth, data, this.table, this.table_id, true);
		})
		.then((esta_id)=>{
			id = esta_id;
			return this.delete(id, 'estate_stakeholder', 'esta_id')
			.then(() => {
				return this.delete(id, 'access_log', 'aclo_content_id');
			})
		})
		.then(() => {
			return new Promise((resolve, reject) => {
				if (pers_creator != '') {
					// Add 1 to the estate created number at person_selfmanaged_limit table if self_usermanaged created inspector user
					this.db.select('person_selfmanaged_limit.*').from('person_selfmanaged_limit').whereRaw(`pers_id = '${pers_creator}'`)
					.then(result => {
						let updateData = {
							'pese_estate_created': result[0].pese_estate_created ? parseInt(result[0].pese_estate_created) + 1 : 1
						};
						console.log("Estate add result preparing 1111 , ", result, updateData);
						
						this._update(updateData, 'person_selfmanaged_limit', 'pers_id', `pers_id = '${pers_creator}'`).then(() =>{
							this.db.raw('REFRESH MATERIALIZED VIEW person_view').then(() => {
								resolve(id);
							})
						}).catch(error => {
							reject(error);
						})
					})
				} else {
					resolve();
				}
			})
		})
		.then(()=>{
			try {				
				stakeholders.forEach((stakeholder)=>{
					stakeholder['esta_id'] = id
				})
				return this._upsert(stakeholders, 'estate_stakeholder')
			} catch(e) {
				return null;
			}
		})
		.then(()=>{
			return id
		})
		.catch(error => {
			console.log(error);
		})
	}

	put(auth = {}, data = {}){
		// let stakeholders = (data.esta_stakeholders.length > 0) ? data.esta_stakeholders : [];
		let stakeholders = data.esta_stakeholders;
		delete data.esta_stakeholders;
		let id = null;
		return super.put(auth, data, this.table, this.table_id)
		.then((esta_id)=>{
			id = esta_id;
			return this.delete(id, 'estate_stakeholder', 'esta_id')
			.then(()=>{
				return this.delete(id, 'access_log', 'aclo_content_id');				
			})
		})
		.then(()=>{
			try {
				stakeholders.forEach((stakeholder)=>{
					stakeholder['esta_id'] = id
				})
				return this._upsert(stakeholders, 'estate_stakeholder')
			} catch(e) {
				return null;
			}
		})
		.then(()=>{
			return id
		})
	}

	deleteConnection(auth={}, data={}) {
		console.log("deleteConnection input data === ", auth, data);
		let deleter = auth.pers_id;
		if (!data.id) {
			return;
		}
		return this.db.select('person_selfmanaged_limit.*').from('person_selfmanaged_limit').whereRaw(`pers_id = '${deleter}'`)
		.then(result => {
			this.db.raw('REFRESH MATERIALIZED VIEW person_view').then(() => {
			})
		})
	}
}

module.exports = CheckpointQueries;