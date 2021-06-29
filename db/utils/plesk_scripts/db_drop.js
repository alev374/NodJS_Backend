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
		database: 'aw_api',
		charset: 'utf-8'
	}
}

// connect to postgres default db
db = db(connectionConfig);

console.log('start aw_api drop');
db.raw('DROP DATABASE IF EXISTS aw_api;')
.then((response)=>{
	db.destroy();
	console.log('aw_api dropped');
})
.catch((err)=>{
	console.log(err);
})