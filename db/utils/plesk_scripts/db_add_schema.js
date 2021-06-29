const fs = require('fs');
let db = require( 'knex' );

const dbInitSql = fs.readFileSync('./db/init_v3/create.sql').toString();

let connectionConfig = {
	client: 'pg',
	// connection: {
	// 	host: 'localhost',
	// 	port: '49154',
	// 	user: 'postgres',
	// 	password: 'Gj29si&1',
	// 	database: 'aw_api',
	// 	charset: 'utf-8'
	// }

	connection: {
		host: 'localhost',
		port: '5432',
		user: 'postgres',
		password: '12345',
		database: 'aw_api',
		charset: 'utf-8'
	}
}

// connect to postgres default db
db = db(connectionConfig);

console.log('start schema init');
// create aw_api db
db.raw(dbInitSql)
.then((response)=>{
	console.log('aw_api schema added');
	db.destroy();
})
.catch((err)=>{
	console.log(err);
})