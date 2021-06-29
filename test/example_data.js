module.exports = {
	users: {
		admin: {
			"pers_firstname": "Max",
			"pers_lastname": "Mustermann",
			"pers_is_active":  true,
			"pers_username": "mmax",
			"pers_password": "123456789",
			"pers_addresses": [
			{
				"address_street_name": "Teststr",
				"address_street_number": "1",
				"address_zipcode": "12345",
				"address_city": "Teststadt",
				"address_country": "Testland",
				"address_type": "home"
			}
			],
			"pers_email_addresses": [
			{
				"email_address": "maximilian-ruppert@gmx.de",
				"email_type": "work",
				"email_is_receiving": true,
				"email_notification_time": ""
			}
			],
			"pers_phone_numbers": [
			{
				"phone_number": "123456799",
				"phone_type": "mobile"
			}
			],
			"pers_scope": "manager"
		},
		inspector: {
			"pers_firstname": "Sepp",
			"pers_lastname": "Waerter",
			"pers_is_active":  true,
			"pers_username": "wsepp",
			"pers_password": "123456789",
			"pers_addresses": [
			{
				"address_street_name": "Teststr",
				"address_street_number": "12",
				"address_zipcode": "12345",
				"address_city": "Teststadt",
				"address_country": "Testland",
				"address_type": "home"
			}
			],
			"pers_email_addresses": [
			{
				"email_address": "maximilian-ruppert@gmx.de",
				"email_type": "work",
				"email_is_receiving": true,
				"email_notification_time": "15"
			}
			],
			"pers_phone_numbers": [
			{
				"phone_number": "123456799",
				"phone_type": "mobile"
			}
			],
			"pers_scope": "inspector"
		},
		owner: {
			"pers_firstname": "Manfred",
			"pers_lastname": "Besitzer",
			"pers_is_active":  true,
			"pers_username": "bmani",
			"pers_password": "123456789",
			"pers_addresses": [
			{
				"address_street_name": "Herrenstr",
				"address_street_number": "24",
				"address_zipcode": "12345",
				"address_city": "Teststadt",
				"address_country": "Testland",
				"address_type": "work"
			}
			],
			"pers_email_addresses": [
			{
				"email_address": "maximilian-ruppert@gmx.de",
				"email_type": "work",
				"email_is_receiving": true,
				"email_notification_time": "14"
			}
			],
			"pers_phone_numbers": [
			{
				"phone_number": "123456799",
				"phone_type": "mobile"
			}
			],
			"pers_scope": "owner"
		}
	},
	checklists: {
		test_liste: {
			"chli_name": "Test Liste",
			"chli_checkpoints": [
				// {
				// 	"chpo_id": ""
				// }
			]
		}
	},
	checkpoints:{
		checkpoint_1: {
			"chpo_headline": "Test Checkpoint",
			"chpo_description": "Das ist ein Test Checkpoint",
			"chpo_long_description": "Das ist die lange Beschreibung des Test Checkpoint",
			"chpo_emergency_description": null,
			"chpo_priority": 0,
			"chpo_checklists": [
				// {
				// 	"chli_id": ""
				// }
			]
			// "chpo_anotation": "",
			// "chpo_images": [
			// 	""
			// ]
		}
	},
	elevators: {
		bar565622: {
			"elev_serial_number": "123456",
			"elev_barcode": "bar565622",
			"elev_manufacturer": "Thyssen",
			"elev_build_year": "2002",
			"elev_location": "Treppenhaus",
			"elev_type": "Personen",
			"elev_is_active": true,
			"elev_emergency_information": {
				"emergency_company": "Rettung",
				"emergency_company_phone_number": "1562314",
				"emergency_exit_instructions": "bla bla",
				"emergency_phone_number": "112"
			},
			"elev_inspection_days": [
			"25",
			"do"
			],
			"pers_inspector_id": "",
			"pers_substitute_id": null,
			"esta_id": "",
			"chli_id": "",
			"elev_checkpoints": [
				// {
				// 	"chpo_id": ""
				// }
			]
		}
	},
	estates: {
		spasstr: {
			"esta_approach": "",
			"esta_facility_manager": {
				"facility_manager_name": "Harry Handi",
				"facility_manager_phone_number": "1256421"
			},
			"esta_address": {
				"address_street_name": "Spasstr",
				"address_street_number": "55 a)",
				"address_zipcode": "45632",
				"address_city": "Superstadt",
				"address_country": "Testland",
				"address_type": "home"
			},
			"esta_stakeholders": [
				// {
				// 	"pers_id": ""
				// }
			]
		}
	},
	reports: {
		report_1 :{
			"repo_checkpoints": [
				// {
				// 	"chpo_id": "asfdasda",
				// 	"chpo_headline": "Test Checkpoint",
				// 	"chpo_description": "Das ist ein Test Checkpoint",
				// 	"chpo_priority": "unwichtig",
				// 	"chpo_anotation": "",
				// 	"chpo_images": [
				// 		{
				// 			"image_filename": ""
				// 		}
				// 	]
				// }
			],
			"repo_inspector": {
				// "pers_id": "asdwttgtga",
				// "pers_firstname": "Sepp",
				// "pers_lastname": "Waerter",
				// "pers_addresses": [
				// {
				// 	"address_street_name": "Teststr",
				// 	"address_street_number": "12",
				// 	"address_zipcode": "12345",
				// 	"address_city": "Teststadt",
				// 	"address_country": "Testland",
				// 	"address_type": "home"
				// }
				// ],
				// "pers_email_addresses": [
				// {
				// 	"email_address": "maximilian-ruppert@gmx.de",
				// 	"email_type": "work",
				// 	"email_is_receiving": true,
				// 	"email_notification_time": ""
				// }
				// ],
				// "pers_phone_numbers": [
				// {
				// 	"phone_number": "123456799",
				// 	"phone_type": "mobile"
				// }
				// ],
				// "pers_is_substitute": false
			},
			"repo_elevator": {
				// "elev_id": "123456789",
				// "elev_serial_number": "123456",
				// "elev_barcode": "bar565622",
				// "elev_manufacturer": "Thyssen",
				// "elev_build_year": "2002",
				// "elev_location": "Treppenhaus",
				// "elev_type": "Personen",
				// "elev_is_active": true,
				// "elev_emergency_information": {
				// 	"emergency_company": "Rettung",
				// 	"emergency_company_phone_number": "1562314",
				// 	"emergency_exit_instructions": "bla bla",
				// 	"emergency_phone_number": "112"
				// },
				// "elev_inspection_days": [
				// "25"
				// ],
				// "pers_inspector_id": "q7n92lf60yLE3IuhHPZQ9SrkbtwbJOkHyAz"
			},
			"repo_estate": {
				// "esta_id": "bnvasdbh",
				// "esta_approach": "",
				// "esta_facility_manager": {
				// 	"facility_manager_name": "Harry Handi",
				// 	"facility_manager_phone_number": "1256421"
				// },
				// "esta_address": {
				// 	"address_street_name": "Spasstr",
				// 	"address_street_number": "55 a)",
				// 	"address_zipcode": "45632",
				// 	"address_city": "Superstadt",
				// 	"address_country": "Testland",
				// 	"address_type": "home"
				// },
				// "esta_stakeholders": [
				// 	{
				// 		"pers_id": "2551asdas",				
				// 		"pers_firstname": "Manfred",
				// 		"pers_lastname": "Besitzer",
				// 		"pers_is_active":  true,
				// 		"pers_username": "wsepp",
				// 		"pers_password": "123456789",
				// 		"pers_addresses": [
				// 		{
				// 			"address_street_name": "Herrenstr",
				// 			"address_street_number": "24",
				// 			"address_zipcode": "12345",
				// 			"address_city": "Teststadt",
				// 			"address_country": "Testland",
				// 			"address_type": "work"
				// 		}
				// 		],
				// 		"pers_email_addresses": [
				// 		{
				// 			"email_address": "maximilian-ruppert@gmx.de",
				// 			"email_type": "work",
				// 			"email_is_receiving": true,
				// 			"email_notification_time": ""
				// 		}
				// 		],
				// 		"pers_phone_numbers": [
				// 		{
				// 			"phone_number": "123456799",
				// 			"phone_type": "mobile"
				// 		}
				// 		],
				// 		"pers_scope": "owner"
				// 	}
				// ]
			}
		}
	}
}