const IdGenerator = require(__base + 'api/service_utils/id_generator');
const timestamp = require(__base + 'api/service_utils/timestamp');

class Queries  {
	constructor(db, table, table_id, table_fulltext, table_alias) {
		this.db = db;
		this.limit = 100;
		this.offset = 0;
		this.idGenerator = new IdGenerator(db);
		this.timestamp = timestamp;
		this.table = table;
		this.table_id = table_id;
		this.table_fulltext = table_fulltext;
		this.table_alias = table_alias;
	}

	_encodeSearch(search){
		search = search.replace(/[^\wäüöÖÄÜ]+$/, '');
		let searchTerms = search.split(' ');
		search = '';
		searchTerms.forEach((term)=>{
			search += `${term}:*&`
		})
		search = search.slice(0, -1);
		return search;
	}

	_convertObjectToMap(obj){
		const map = new Map();
		Object.keys(obj).forEach(key => {
			map.set(key, obj[key]);
		});
		return map;
	}

	_stripMetaData (data){
		let _links = null;
		let _embedded = null;
		if(data._links){
			_links = this._convertObjectToMap(data._links);
			delete data['_links'];			
		}
		if(data._embedded){
			_embedded = this._convertObjectToMap(data._embedded);
			delete data['_embedded'];			
		}
		return {data: data, _links: _links, _embedded: _embedded}
	}

	_parseJsonData(data){
		for (let key in data){			
			if(data[key] != null && typeof data[key] === 'object' || typeof data[key] === 'array'){
				data[key] = JSON.stringify(data[key]);
			}
		}
		return data;
	}

	_upsert(data, table){
		let insert = this.db.insert(data).toString();
		insert = insert.replace(/insert into\s*/g, '');
		const match = /(\(([^\)]*?)\)) values/g.exec(insert);
		const columns = match[1];
		let set = match[2]
		set = set.split(',')
		let update = ''
		set.forEach((value, idx)=>{
			let end = (idx < set.length - 1) ? ',' : ';'
			value = value.replace(' ', '');
			update += `${value} = ${table}.${value}${end}` 
		})
		insert = insert.replace('values', 'select distinct * from (values')
		insert += ') sub';
		const upsert =  `${insert}
				ON CONFLICT ${columns} DO UPDATE 
				SET ${update}	
		`;
		return this.db.transaction((trx)=>{
			return this.db.insert(this.db.raw(upsert))
			.into(table)
			.transacting(trx)
			.then((response)=>{
				trx.commit;
				return response;
			})
			.catch(trx.rollback)
		});
	}

	_insert(data, table, table_id){
		return this.db.transaction((trx)=>{
			return this.db(table)
			.transacting(trx)
			.insert(data)
			.returning(table_id)
			.then((response)=>{
				trx.commit;
				return response;
			})
			.catch(trx.rollback)
		});
	}

	_update(data, table, table_id, whereRaw){
		return this.db.transaction((trx) => {
			return this.db(table)
				.whereRaw(whereRaw)
				.transacting(trx)
				.update(data)
				.returning(table_id)
				.then((response) => {
					trx.commit;
					return response[0];
				})
				.catch(trx.rollback)
		})
	}

	_delete(table, table_id, whereRaw){
		return this.db.transaction((trx) => {
			return this.db(table)
				.whereRaw(whereRaw)
				.transacting(trx)
				.del()
				.returning(table_id)
				.then((response) => {
					trx.commit;
					if (Array.isArray(response) && response.length == 0) {
						return `Error: Could not remove row from ${table}`;
					}
					return response;
				})
				.catch(trx.rollback)
		});
	}

	_generateId(data, table,table_id, size){
		return this.idGenerator.generateId(table,table_id, size).then((id)=>{
			data[table_id] = id;
			return data;
		})
	}

	_checkAccessLog(main_table_id){
		return this.db.raw(`(
			select aclo_content_id, jsonb_agg(json_build_object('aclo_owner', aclo_owner)) as aclo_owners from access_log
			group by aclo_content_id
		) as aclo
		`);
	}

	_getSearchResult(search, table, table_fulltext, select){
		return this.db.select(this.db.raw(select)).from(table)
		.whereRaw(`${table}.${table_fulltext} @@ to_tsquery('${this._encodeSearch(search)}')`);
	}

	addToAccessLog(data = []){
		let promises = [];
		data.forEach((entry)=>{
			promises.push(this._upsert(entry, 'access_log', 'aclo_id'))
		})
		return Promise.all(promises);
	}

	get(auth = {}, select= `${this.table}_view.*`, limit = this.limit, offset = this.offset, search = null, table = `${this.table}_view`, table_id = this.table_id, table_alias= this.table_alias){
		let where = (auth.scope == 'admin' || auth.scope == 'manager') ? '' : `aclo_owners @> '[{"aclo_owner": "${auth.pers_id}"}]'\n`;
		if (auth.scope == 'owner_selfmanaged' && (table == 'checklist' || table == 'checklist_view' || table == 'checkpoint' || table == 'checkpoint_view')) {
			where = '';
		}
		if(search != null){
			return this._getSearchResult(search.search, table, search.table_fulltext, `${select}, aclo_owners`)
			.leftJoin(this._checkAccessLog(table_id), 'aclo.aclo_content_id', `${table}.${table_id}`)
			.limit(limit).offset(offset).as(table_alias)
			.whereRaw(this.db.raw(where));
		}
		else{
			return this.db.select(this.db.raw(`${select}, aclo_owners`)).from(table)
			.leftJoin(this._checkAccessLog(table_id), 'aclo.aclo_content_id', `${table}.${table_id}`)
			.limit(limit).offset(offset).as(table_alias)
			.whereRaw(where);
		}
	}

	getById(auth = {}, id = '', table_id= `${this.table}_view.${this.table_id}`){
		return this.get(auth).where(table_id, id);
	}
	
	search(auth = {}, search = '', limit = this.limit, offset = this.offset, table_fulltext = this.table_fulltext, select = `${this.table}_view.*`, table = `${this.table}_view`){
		return this.get(auth, select, limit, offset, {search: search, table_fulltext: table_fulltext}, table);
	}

	check(auth = {}, check, where = '', table = this.table, table_id = this.table_id){
		if(where != ''){
			return this.db.select(table_id).from(table)
			.whereRaw(where)
		}
		else{
			return [];
		}
	}

	post(auth = {}, data = {}, table = this.table, table_id = this.table_id, isGenerateId = true, size){
		const creationTimestamp = this.timestamp();
		data[`${this.table_alias}_creation`] = creationTimestamp;
		data[`${this.table_alias}_last_updated`] = creationTimestamp;
		data = this._parseJsonData(data);
		let query = null;
		if(isGenerateId){
			query = this._generateId(data, table, table_id, size)
			.then((data)=>{
				return this._insert(data, table, table_id);
			})
		}
		else{
			query = this._insert(data, table, table_id);
		}
		return query.then((result)=>{
			const content_id = result[0];
			let accessData = []
			if(auth.scope == 'manager' || auth.scope == 'owner_selfmanaged'){
				accessData.push({
					'aclo_content_id': content_id,
					'aclo_content_table': 'person',
					'aclo_owner': auth.pers_id
				});
				return this.addToAccessLog(accessData)
				.then(()=>{
					return content_id;
				})
			}
			else{
				return content_id;
			}
		})
	}

	put(auth = {}, data = {}, table = this.table, table_id = this.table_id, table_alias=this.table_alias){
		if('_id' in data){
			data[table_id] = data['_id'];
			delete data['_id'];
		}
		data[`${table_alias}_last_updated`] = this.timestamp();
		data = this._parseJsonData(data);
		return this.db.transaction((trx)=>{
			return this.db(table)
			.where(table_id, data[table_id])
			.transacting(trx)
			.update(data)
			.returning(table_id)
			.then((response)=>{
				trx.commit;
				return response[0];
			})
			.catch(trx.rollback)
		});
	}

	delete(id = '', table = this.table, table_id = this.table_id){
		console.log("Delete API === ", id, table);
		return this.db.transaction((trx)=>{
			return this.db(table)
			.where(table_id, id)
			.transacting(trx)
			.del()
			.returning(table_id)
			.then((response)=>{
				console.log("Delete Response === ", response);
				trx.commit;
				if(Array.isArray(response) && response.length == 0){
					return `Error: Could not remove ${id} from ${table}`;
				}
				return response;
			})
			.catch(trx.rollback)
		});
	}
	
	checkDuplicate(where, table, table_id) {
		if(where != ''){
			return this.db.select(table_id).from(table)
			.whereRaw(where)
		}
		else{
			return [];
		}
	}
}

module.exports = Queries;