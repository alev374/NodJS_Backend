'use strict';

// A-Z 65 - 90
// a-z 97 - 122

class IdGenerator {
	constructor(db) {
		this.db = db;
		this.size = 30;
	}

	generateId(table, itemId, size = this.size){
		return new Promise((resolve, reject) => {
			let isAvailable = false;
			let id = this.buildId(size);
			let result = this.db
			.select(itemId)
			.from(table)
			.where(itemId,id)
			.then((result)=>{
				if(result == false){
					resolve(id);
				}
				else{
					this.generateId(table, itemId)
				}
			})
			.catch(error =>{
				reject(error);
			});
		});		
	}

	buildId(size = this.size){
		let id = '';
		for (var i = 0; i < size; i++) {
			const scope = parseInt(Math.random()*5);
			if(scope > 0 && scope <= 2){
				id += String.fromCharCode(parseInt(Math.random()*26) + 65);
			}
			else if(scope > 2){
				id += String.fromCharCode(parseInt(Math.random()*26) + 97);
			}
			else{
				id += parseInt(Math.random()*10);
			}
		}
		return id;
	}
}

// console.log(new IdGenerator().buildId(35));

module.exports = IdGenerator;