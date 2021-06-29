let db = require( 'knex' );

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
db.raw('CREATE ROLE [username] WITH SUPERUSER LOGIN PASSWORD \'[pw]\'')
.then((response)=>{
	return db.raw('SELECT * FROM checklist')
})
.then((response)=>{
	console.log(response);
	db.destroy();
})
.catch((err)=>{
	console.log(err);
})