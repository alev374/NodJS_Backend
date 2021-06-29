import os

def get_data(path):
	data = ''
	for file in os.listdir(path):
		if file.endswith(".sql"):
			file_path = os.path.join(path, file)
			with open(file_path) as file:  
				data = data + file.read() + "\n"
	return data


def write_data(path, data):
	mode = 'w+' if os.path.exists(path) else 'w'
	with open(path, mode) as file:
		file.write(data)
sql = ''
sql = sql + get_data("./db/settings/")
sql = sql + "\n" + get_data("./db/tables/")
sql = sql + "\n" + get_data("./db/content/")
sql = sql + "\n" + get_data("./db/views/")
sql = sql + "\n" + get_data("./db/triggers/")


write_data("./db/init_v3/create.sql", sql)