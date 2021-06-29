const Queries = require(__base + 'api/service_utils/queries');
const mkdirp = require('mkdirp');

class ElevatorQueries extends Queries{
	constructor(db, table, table_id, table_fulltext, table_alias) {
		super(db, table, table_id, table_fulltext, table_alias);
	}

	get(auth = {}, select = '', limit = this.limit, offset = this.offset, search = null){
		// if(select == ''){
		// 	select = `${this.table}_view.elev_id, elev_serial_number, elev_barcode, elev_type, elev_manufacturer, elev_build_year, elev_location, json_build_object('esta_id', elev_estate-> 'esta_id', 'esta_address', elev_estate-> 'esta_address') as elev_estate, elev_inspection_days`;
		// }
		select= `${this.table}_view.*`;
		return super.get(auth, select, limit, offset, search);
	}

	getById(auth = {}, id = '', table_id= `${this.table}_view.${this.table_id}`){
		return this.get(auth, `${this.table}_view.*`).where(table_id, id);
	}

	search(auth = {}, search = '', limit = this.limit, offset = this.offset, table_fulltext = this.table_fulltext, select = `${this.table}_view.*`){
		select = `${this.table}_view.*`;
		return super.search(auth, search, limit, offset, table_fulltext, select);
	}

	check(auth = {}, check){
		return super.check(auth, check, `elev_barcode = '${check}'`)
	}
	
	post(auth = {}, data = {}){
		console.log("Elevator Post Data ==== ", data);
		let pers_creator = ''; //pers_id when creator is owner_selfmanaged
		if (auth.pers_scope == 'owner_selfmanaged') {
			pers_creator = auth.pers_id;
			data = {
				...data,
				'elev_created_by': pers_creator
			}
		}
		let checkpoints = data.elev_checkpoints;
		let elev_id = null;
		return new Promise((resolve, reject) => {
			if (auth.pers_scope === 'owner_selfmanaged') { // When owner_selfmanaged user add elevators
				this.db.select('person_selfmanaged_limit.*').from('person_selfmanaged_limit').whereRaw(`pers_id = '${auth.pers_id}'`)
				.then(result => {
					console.log("Limit check result === ", result);
					if (
						parseInt(result[0].pese_elevator_limit ? result[0].pese_elevator_limit : 0) == 0 ||
						parseInt(result[0].pese_elevator_limit ? result[0].pese_elevator_limit : 0) > parseInt(result[0].pese_elevator_created ? result[0].pese_elevator_created : 0)
						) {
							console.log("Elevator can be added!!!!");
							resolve();
						}
					else {
						reject('Elevator creation is limited!');
						// throw new Error('User creation is limited')
					}
				})
				.catch(error => {
					reject(error)
				})
			} else {
				resolve()
			}
		})
		.then(() => {
			return super.post(auth, data, this.table, this.table_id, true)
		})
		// .then((id)=>{
		// 	elev_id = id;
		// 	try {
		// 		checkpoints.forEach((checkpoint, index)=>{
		// 			checkpoint['elev_id'] = elev_id;
		// 		})
		// 		return this._upsert(checkpoints, 'elevator_checkpoint_relation')
		// 	} catch(e) {
		// 		return null;
		// 	}
		// })
		.then((id) => {
			elev_id = id;
			return new Promise((resolve, reject) => {
				if (pers_creator != '') {
					// Add 1 to the estate created number at person_selfmanaged_limit table if self_usermanaged created inspector user
					this.db.select('person_selfmanaged_limit.*').from('person_selfmanaged_limit').whereRaw(`pers_id = '${pers_creator}'`)
					.then(result => {
						let updateData = {
							'pese_elevator_created': result[0].pese_elevator_created ? parseInt(result[0].pese_elevator_created) + 1 : 1
						};
						console.log("Elevator add result preparing 1111 , ", result, updateData);
						
						this._update(updateData, 'person_selfmanaged_limit', 'pers_id', `pers_id = '${pers_creator}'`).then(() =>{
							resolve();
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
			return new Promise((resolve, reject) => {				
				if (elev_id){
					mkdirp(`files/reports/${elev_id}`, function (err) {
						if (err) reject(err)
						else resolve(elev_id)
					});	
				}
				else{
					throw new Error(`Could not create directory: files/reports/${elev_id}`);		
				}
			});
		})
		.then(()=>{
			return elev_id;
		})
	}

	put(auth = {}, data = {}){
		// let checkpoints = data.elev_checkpoints;
		let id = null;
		console.log("Elevator Put Data === ", data);
		return super.put(auth, data, this.table, this.table_id)
		.then((id)=>{
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

module.exports = ElevatorQueries;