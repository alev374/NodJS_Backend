const requestify = require('requestify');
const example_data = require('./test_data');

const logBody = (action, body) => {
	console.log(`${action}:\n${JSON.stringify(body)}\n`);
}

// const host = 'http://localhost:3000/api/v1';
const host = 'http://192.168.101.89:3000/api/v1';

const serverPath = `${host}`;
let jwt = null;
let path = `${serverPath}/auth`;
let body = null;
let headers = null;
requestify.request(path, {method: 'GET', auth: { username: 'creator_admin', password: 'Q3MhS6SYswEjK2uz6mAbfyC6AhvFN0mSISq' }})
// log in
.then((response)=>{
	jwt = response.getBody().pers_token;
	headers = {'Authorization': jwt, 'Content-Type': 'application/json'};
	path = `${serverPath}/users`;
	return requestify.request(path, {method: 'GET', headers: {'Authorization': jwt}});
})
// post users
.then((response)=>{
	console.log('post users');
	// logBody('get users', response.getBody());
	const proms = [];
	example_data.users.forEach( (element, index) => {
		let promise = new Promise((resolve, reject) => {
			path = `${serverPath}/users`;
			body = example_data.users[index];
			requestify.request(path, {method: 'POST', body: body, headers: headers})
			.then((response)=>{
				example_data.users[index].pers_id = response.getBody().pers_id;
				resolve(response)
			})
			.catch((err)=>{
				console.log(err);
				reject(err)
			})
		});
		proms.push(promise)
	});
	return Promise.all(proms);
})
// post checkpoints
.then((response)=>{
	console.log('post checkpoints');
	// logBody('get users', response);
	const proms = [];
	example_data.checkpoints.forEach( (element, index) => {
		let promise = new Promise((resolve, reject) => {
			path = `${serverPath}/checkpoints`;
			body = example_data.checkpoints[index];
			requestify.request(path, {method: 'POST', body: body, headers: headers})
			.then((response)=>{
				example_data.checkpoints[index].chpo_id = response.getBody().chpo_id;
				resolve(response)
			})
			.catch((err)=>{
				reject(err)
			})
		});
		proms.push(promise)
	});
	return Promise.all(proms);
})
// post checklists
.then((response)=>{
	console.log('post checklists');
	// logBody('get checkpoints', response);
	const proms = [];
	example_data.checklists.forEach( (element, index) => {

		example_data.checklists[index].chli_checkpoints.forEach((checkpointIndex, j)=>{
			example_data.checklists[index].chli_checkpoints[j] = {
				chpo_id: example_data.checkpoints[checkpointIndex].chpo_id
			};
		})

		let promise = new Promise((resolve, reject) => {
			path = `${serverPath}/checklists`;
			body = example_data.checklists[index];
			requestify.request(path, {method: 'POST', body: body, headers: headers})
			.then((response)=>{
				example_data.checklists[index].chli_id = response.getBody().chli_id;
				resolve(response)
			})
			.catch((err)=>{
				reject(err)
			})
		});
		proms.push(promise)
	});
	return Promise.all(proms);
})
// post estates
.then((response)=>{
	console.log('post estates');
	// logBody('get checklists', response);
	const proms = [];
	example_data.estates.forEach( (element, index) => {
		example_data.estates[index].esta_stakeholders = [
			{
				pers_id: example_data.users[example_data.estates[index].esta_stakeholders].pers_id
			}
		];

		let promise = new Promise((resolve, reject) => {
			path = `${serverPath}/estates`;
			body = example_data.estates[index];
			requestify.request(path, {method: 'POST', body: body, headers: headers})
			.then((response)=>{
				example_data.estates[index].esta_id = response.getBody().esta_id;
				resolve(response)
			})
			.catch((err)=>{
				reject(err)
			})
		});
		proms.push(promise)
	});
	return Promise.all(proms);
})
// post elevators
.then((response)=>{
	console.log('post elevators');
	// logBody('get estates', response);
	const proms = [];
	example_data.elevators.forEach( (element, index) => {

		example_data.elevators[index].pers_inspector_id = example_data.users[example_data.elevators[index].pers_inspector_id].pers_id;
		example_data.elevators[index].pers_substitute_id = example_data.users[example_data.elevators[index].pers_substitute_id].pers_id;
		example_data.elevators[index].esta_id = example_data.estates[example_data.elevators[index].esta_id].esta_id;
		example_data.elevators[index].chli_id = example_data.checklists[example_data.elevators[index].chli_id].chli_id;
		example_data.elevators[index].elev_checkpoints.forEach((checkpointIndex, j)=>{
			example_data.elevators[index].elev_checkpoints[j] = {
				chpo_id: example_data.checkpoints[checkpointIndex].chpo_id
			};
		})

		let promise = new Promise((resolve, reject) => {
			path = `${serverPath}/elevators`;
			body = example_data.elevators[index];
			requestify.request(path, {method: 'POST', body: body, headers: headers})
			.then((response)=>{
				example_data.elevators[index].elev_id = response.getBody().elev_id;
				resolve(response)
			})
			.catch((err)=>{
				reject(err)
			})
		});
		proms.push(promise)
	});
	return Promise.all(proms);
})
.then((response)=>{
	// logBody('get elevators', response);
	console.log('test data uploaded');
	process.exit();
})
.catch((err)=>{
	console.log(err);
	process.exit();
})
