let db = require( 'knex' );


let connectionConfig = {
	client: 'pg',
	// connection: {
	// 	host: 'localhost',
	// 	port: '49154',
	// 	user: 'postgres',
	// 	password: 'Gj29si&1',
	// 	database: 'postgres',
	// 	charset: 'utf-8'
	// }
	connection: {
		host: 'localhost',
		port: '5432',
		user: 'postgres',
		password: '12345',
		database: 'postgres',
		charset: 'utf-8'
	}
}

// connect to postgres default db
db = db(connectionConfig);

// create aw_api db
console.log('create aw_api db');
db.raw('CREATE DATABASE aw_api;')
.then((response)=>{
	db.destroy();	
	console.log('aw_api created');
	console.log('aw_api init done');
})
.catch((err)=>{
	console.log(err);
})