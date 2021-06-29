const Email = require('./email');

let email = new Email();
email.send(to = 'tools@loveforpixels.com', content = {'subject': 'Test', 'text': 'Plesk is your friend', 'html': null})
.then((response)=>{
	console.log(response);
})
.catch((err)=>{
	console.log(err);
})
