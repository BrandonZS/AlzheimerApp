INSERT INTO TIPO_USUARIO(DESCRIPCION)
	VALUES 
	('PACIENTE'),
	('CUIDADOR')
GO

INSERT INTO PRIORIDAD(DESCRIPCION)
	VALUES
	('ALTA'),
	('MEDIA'),
	('BAJA')
GO

INSERT INTO ESTADO(DESCRIPCION)
	VALUES
	('ENVIADO'),
	('RECIBIDO')

-- Insertar los errores en la tabla
INSERT INTO ERROR_CATALOG (NUM_ERROR, CODE_ERROR, DESCRIPTION_ERROR) VALUES
(50001, 'CORREO_EN_USO', 'El correo electrónico proporcionado ya está registrado en el sistema. Por favor, utilice otro correo.'),
(50002, 'USUARIO_NO_EXISTE', 'El usuario solicitado no existe en el sistema o no es válido.'),
(50003, 'PACIENTE_NO_EXISTE', 'El paciente solicitado no existe en el sistema o no es válido.'),
(50004, 'CUIDADOR_NO_EXISTE', 'El cuidador solicitado no existe en el sistema o no es válido.'),
(50005, 'PACIENTE_NO_ASIGNADO', 'El paciente no está asignado al cuidador especificado.'),
(50006, 'PACIENTE_NO_ASOCIADO_EVENTO', 'El paciente no está asociado al evento indicado.'),
(50007, 'PING_EN_USO', 'Ya existe un ping activo para este usuario, no se puede generar otro.'),
(50008, 'PACIENTE_NO_ASIGNADO', 'El paciente no está asignado al cuidador especificado.'),
(50009, 'CODIGO_PACIENTE_NO_EXISTE', 'El código del paciente es incorrecto o no existe en el sistema.'),
(50010, 'RELACION_NO_EXISTE', 'No existe una relación válida entre el paciente y el cuidador especificado.'),
(50011, 'RELACION_DUPLICADA', 'Ya existe una relación activa entre el paciente y el cuidador especificado.'),
(50012, 'JUEGO_NO_EXISTE', 'El juego solicitado no existe en el sistema o no pertenece al usuario.'),
(50013, 'JUEGO_NO_ELIMINABLE', 'No se puede eliminar el juego porque tiene pacientes asignados.'),
(50014, 'REGISTRO_DUPLICADO', 'Ya existe un registro con la misma información en el sistema.'),
(50015, 'EVENTO_NO_EXISTE', 'El evento solicitado no existe en el sistema o no pertenece al usuario.'),
(50016, 'PIN_NO_EXISTE', 'No hay un PIN activo para este usuario.'),
(50017, 'PIN_FORMATO_INVALIDO', 'El PIN debe contener exactamente 6 dígitos numéricos.'),
(50018, 'PIN_INCORRECTO', 'El PIN proporcionado es incorrecto.'),
(50019, 'CONTRASENA_INCORRECTA', 'La contraseña actual ingresada es incorrecta.'),
(50020, 'CONTRASENA_NO_SEGURA', 'La nueva contraseña no cumple con los requisitos de seguridad establecidos.'),
(50021, 'PREGUNTA_NO_EXISTE', 'La pregunta solicitada no existe en el sistema.'),
(50022, 'RESPUESTA_DUPLICADA', 'Ya existe una opción marcada como correcta para esta pregunta.'),
(50023, 'REGISTRO_NO_ENCONTRADO', 'No se encontró el registro solicitado en la base de datos.'),
(50024, 'DATOS_NO_VALIDOS', 'Los datos proporcionados no son válidos o están incompletos.'),
(50025, 'SESION_NO_EXISTE', 'No se encontró una sesión activa para el usuario y origen especificado.'),
(50026, 'SESION_NO_VALIDA', 'El token de sesión no es válido o ha expirado.'),
(50027, 'CREDENCIALES_INCORRECTAS', 'Las credenciales ingresadas son incorrectas.'),
(50028, 'SESION_NO_CERRADA', 'No se pudo cerrar la sesión correctamente.'),
(50029, 'ERROR_SQL', 'Se ha producido un error inesperado en la base de datos.'),
(50030, 'SESION_YA_EXISTE', 'El usuario ya tiene una sesión activa en el sistema.');
