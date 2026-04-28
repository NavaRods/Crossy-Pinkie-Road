extends HTTPRequest

signal clima_determinado(estado) # "dia", "tarde", "noche"

func _ready():
	self.request_completed.connect(_on_request_completed)
	consultar_hora_real()

func consultar_hora_real():
	# Consultamos la hora de una zona horaria de la ciudad de México
	var url = "https://timeapi.io/api/Time/current/zone?timeZone=America/Mexico_City"
	var error = request(url)
	if error != OK:
		print("Error al iniciar la petición de tiempo")

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	
	if parse_result == OK:
		var datos = json.get_data()
		var hora = datos["hour"] # Extraemos la hora (0-23)
		var estado = ""
		if hora >= 6 and hora < 10: estado = "mañana"
		elif hora >= 10 and hora < 16: estado = "dia"
		elif hora >= 16 and hora < 18: estado = "tarde"
		elif hora >= 18 and hora < 20: estado = "atardecer"
		else: estado = "noche"
	
		GameManager.clima_actual = estado
			
		print("Hora real: ", hora, " -> Estado: ", estado)
		clima_determinado.emit(estado)
