const fs = require('fs');
let db = require( 'knex' );
const schema = './db/utils/plesk_scripts/update_schema.sql';



const sql = fs.readFileSync(schema).toString();

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

// create aw_api db
db.raw(sql)
.then((response)=>{
	console.log(response);
	console.log('aw_api schema updated');
	db.destroy();
})
.catch((err)=>{
	console.log(err);
})