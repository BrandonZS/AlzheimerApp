-- CÓDIGO GENERADOR DE LOS PROCEDIMIENTOS ALMACENADOS

/*
    * EN ESTE DOCUMENTO SE UTILIZA PARA GENERAR LOS PROCEDIMIENTOS ALMACENADOS DENTRO DE LA BASE DE DATOS.
    * ESTE SE ENCUENTRA ORDENADO SEGÚN LOS MÓDULOS USUARIO, PING, RELACIONES, EVENTO, MENSAJE, JUEGO.
    * DENTRO DE ESTE DOCUMENTO SE ENCONTRARÁ LA LISTA DE ERRORES CONTROLADOS EN LA BASE DE DATOS.
    * PARA EJECUTAR ESTE CODIGO, COPIA TODOS LOS PROCEDIMIENTOS Y EJECUTALOS EN EL ADMINISTRADOR DE SQL SERVER.
*/


-- MODULO 1: USUARIO


-- SP001: INSERTAR USUARIO (PACIENTE O CUIDADOR)
CREATE OR ALTER PROCEDURE SP_INSERTAR_USUARIO
    @NOMBRE VARCHAR(100),
    @CORREO_ELECTRONICO NVARCHAR(255),
    @CONTRASENA NVARCHAR(255),
    @FECHA_NACIMIENTO DATE,
    @FOTO_PERFIL VARBINARY(MAX) = NULL,
    @DIRECCION VARCHAR(255) = NULL,
    @ID_TIPO_USUARIO INT,
	@ID_RETURN INT OUTPUT,
	@ERROR_ID INT OUTPUT,
	@ERROR_DESCRIPTION NVARCHAR(MAX) OUTPUT
AS
BEGIN
    DECLARE @CODIGO VARCHAR(6) = NULL;
    DECLARE @EXISTE INT;
    DECLARE @ID_USUARIO INT;
    
    BEGIN TRY
        BEGIN TRANSACTION;

		IF EXISTS ( SELECT * FROM [dbo].[USUARIO] WHERE [CORREO_ELECTRONICO] = @CORREO_ELECTRONICO)
        BEGIN
		SET @ID_RETURN = -1;
		SET @ERROR_ID  = 1;
		SET @ERROR_DESCRIPTION ='Correo existente';
			
	     END
	     ELSE 
		 BEGIN
		 -- Si el usuario es paciente (suponiendo que ID_TIPO_USUARIO = 1 es paciente)
			IF @ID_TIPO_USUARIO = 1
			BEGIN
				WHILE 1 = 1
				BEGIN
				  SET @EXISTE = 0;
					-- Generar un código alfanumérico de 6 caracteres
					SET @CODIGO = LEFT(NEWID(), 6);
                
					-- Verificar que el código no exista
					SELECT @EXISTE = COUNT(*) FROM USUARIO WHERE CODIGO = @CODIGO;
                
					-- Si no existe, salir del bucle
					IF @EXISTE = 0 BREAK;
				END
			END

        
			-- Insertar el nuevo usuario
			INSERT INTO USUARIO (NOMBRE, CORREO_ELECTRONICO, CONTRASENA, FECHA_NACIMIENTO, FOTO_PERFIL, CODIGO, DIRECCION, ID_TIPO_USUARIO)
			VALUES (@NOMBRE, @CORREO_ELECTRONICO, @CONTRASENA, @FECHA_NACIMIENTO, @FOTO_PERFIL, @CODIGO, @DIRECCION, @ID_TIPO_USUARIO);
		 END 

        SET @ID_RETURN = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @ID_RETURN = -1;
		SET @ERROR_ID  = ERROR_NUMBER();
		SET @ERROR_DESCRIPTION =ERROR_MESSAGE();
    END CATCH
END;
GO

-- SP002: ACTUALIZAR FOTO DE PERFIL
CREATE OR ALTER PROCEDURE SP_ACTUALIZAR_FOTO_PERFIL
    @ID_USUARIO INT,
    @FOTO_PERFIL VARBINARY(MAX),
    @ERROR_ID INT OUTPUT,
    @ERROR_DESCRIPTION NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Verificar si el usuario existe
        IF NOT EXISTS (SELECT 1 FROM [dbo].[USUARIO] WHERE [ID_USUARIO] = @ID_USUARIO)
        BEGIN
            SET @ERROR_ID = 2;
            SET @ERROR_DESCRIPTION = 'Usuario no encontrado';
        END
        ELSE
        BEGIN
            -- Actualizar la foto de perfil
            UPDATE USUARIO
            SET FOTO_PERFIL = @FOTO_PERFIL
            WHERE ID_USUARIO = @ID_USUARIO;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @ERROR_ID = ERROR_NUMBER();
        SET @ERROR_DESCRIPTION = ERROR_MESSAGE();
    END CATCH
END;
GO

-- SP003: ACTUALIZAR USUARIO 
CREATE OR ALTER PROCEDURE SP_ACTUALIZAR_USUARIO
    @ID_USUARIO INT,
    @NOMBRE VARCHAR(100),
    @FECHA_NACIMIENTO DATE,
    @DIRECCION VARCHAR(255),
    @PIN VARCHAR(6) = NULL,
    @ID_RETURN INT OUTPUT,
    @ERROR_ID INT OUTPUT,
    @ERROR_DESCRIPTION NVARCHAR(MAX) OUTPUT
AS
BEGIN
    DECLARE @ID_TIPO_USUARIO INT;
    DECLARE @PIN_CORRECTO INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Verificar si el usuario existe y obtener su tipo
        SELECT @ID_TIPO_USUARIO = ID_TIPO_USUARIO FROM USUARIO WHERE ID_USUARIO = @ID_USUARIO;

        IF @ID_TIPO_USUARIO IS NULL
        BEGIN
            SET @ERROR_ID = 2;
            SET @ERROR_DESCRIPTION = 'El usuario no existe';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Si es paciente (tipo 1), verificar si tiene un PIN activo
        IF EXISTS(SELECT 1 FROM [dbo].[PING] WHERE [ID_USUARIO] = @ID_USUARIO AND [ESTADO] = 1) AND @ID_TIPO_USUARIO = 1 
        BEGIN
                SELECT @PIN_CORRECTO = COUNT(*) FROM PING WHERE ID_USUARIO = @ID_USUARIO AND CODIGO = @PIN AND ESTADO = 1;
                IF @PIN_CORRECTO = 0
                BEGIN
                    SET @ERROR_ID = 4;
                    SET @ERROR_DESCRIPTION = 'PIN incorrecto.';
                    ROLLBACK TRANSACTION;
                    RETURN;
                END
        END

        -- Actualizar los datos del usuario
        UPDATE USUARIO
        SET NOMBRE = @NOMBRE,
            FECHA_NACIMIENTO = @FECHA_NACIMIENTO,
            DIRECCION = @DIRECCION
        WHERE ID_USUARIO = @ID_USUARIO;

        COMMIT TRANSACTION;
        SET @ERROR_ID = NULL;
        SET @ERROR_DESCRIPTION = NULL;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @ERROR_ID = ERROR_NUMBER();
        SET @ERROR_DESCRIPTION = ERROR_MESSAGE();
    END CATCH
END;
GO

-- SP004: ACTUALIZAR CONTRASEÑA
CREATE OR ALTER PROCEDURE SP_ACTUALIZAR_CONTRASENA
    @ID_USUARIO INT,
    @CONTRASENA_ACTUAL VARCHAR(255),
    @NUEVA_CONTRASENA VARCHAR(255),
    @PIN VARCHAR(6) = NULL,
    @ERROR_ID INT OUTPUT,
    @ERROR_DESCRIPTION NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @PIN_CORRECTO INT;
		DECLARE @ID_TIPO_USUARIO INT;

		        -- Si el usuario es un paciente (tipo 1), validar el PIN si tiene uno activo
		IF NOT EXISTS (SELECT 1 FROM [dbo].[USUARIO] WHERE @ID_USUARIO = [ID_USUARIO])
		BEGIN 
                SET @ERROR_ID = 4;
                SET @ERROR_DESCRIPTION = 'USUARIO NO EXISTE';
                ROLLBACK TRANSACTION;
                RETURN; 
		END
		ELSE
		BEGIN
			 IF EXISTS(SELECT 1 FROM [dbo].[PING] WHERE [ID_USUARIO] = @ID_USUARIO AND [ESTADO] = 1) 
			 BEGIN
                SELECT @PIN_CORRECTO = COUNT(*) FROM PING WHERE ID_USUARIO = @ID_USUARIO AND CODIGO = @PIN AND ESTADO = 1;
                IF @PIN_CORRECTO = 0
                BEGIN
                    SET @ERROR_ID = 4;
                    SET @ERROR_DESCRIPTION = 'PIN incorrecto.';
                    ROLLBACK TRANSACTION;
                    RETURN;
                END
			 END
		END

        -- Validar que la contraseña actual sea correcta
		IF NOT EXISTS (SELECT 1 FROM [dbo].[USUARIO] WHERE [CONTRASENA] = @CONTRASENA_ACTUAL AND [ID_USUARIO]= @ID_USUARIO)
        BEGIN
            SET @ERROR_ID = 2;
            SET @ERROR_DESCRIPTION = 'La contraseña actual es incorrecta';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar que la nueva contraseña no sea igual a la actual
        IF EXISTS (SELECT 1 FROM [dbo].[USUARIO] WHERE [CONTRASENA] = @NUEVA_CONTRASENA AND [ID_USUARIO]= @ID_USUARIO)
        BEGIN
            SET @ERROR_ID = 3;
            SET @ERROR_DESCRIPTION = 'La nueva contraseña no puede ser igual a la actual';
            ROLLBACK TRANSACTION;
            RETURN;
        END



        -- Actualizar la contraseña
        UPDATE USUARIO
        SET CONTRASENA = @NUEVA_CONTRASENA
        WHERE ID_USUARIO = @ID_USUARIO;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @ERROR_ID = ERROR_NUMBER();
        SET @ERROR_DESCRIPTION = ERROR_MESSAGE();
    END CATCH
END;
GO

-- SP005: ELIMINAR FOTO DE PERFIL (VERIFICA PING EN CASO DE SER REQUERIDO)
CREATE OR ALTER PROCEDURE SP_ELIMINAR_FOTO_PERFIL
    @ID_USUARIO INT,
    @CODIGO_PING VARCHAR(6) = NULL, -- Opcional, solo requerido si hay un ping activo
    @ERROR_ID INT OUTPUT,
    @ERROR_DESCRIPTION NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @ES_PACIENTE BIT;
        DECLARE @PING_ACTIVO BIT = 0;

        -- Verificar si el usuario existe y obtener su tipo
        IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE ID_USUARIO = @ID_USUARIO)
        BEGIN
            SET @ERROR_ID = 1;
            SET @ERROR_DESCRIPTION = 'El usuario no existe.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

		IF EXISTS (SELECT 1 FROM [dbo].[PING] WHERE [ID_USUARIO] = @ID_USUARIO AND [ESTADO] = 1)
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM [dbo].[PING] WHERE [ID_USUARIO] = @ID_USUARIO AND [CODIGO] = @CODIGO_PING)
			BEGIN
				SET @ERROR_ID = 2;
                SET @ERROR_DESCRIPTION = 'PIN incorrecto.';
                ROLLBACK TRANSACTION;
                RETURN;
			END
		END

        -- Eliminar la foto de perfil
        UPDATE USUARIO
        SET FOTO_PERFIL = NULL
        WHERE ID_USUARIO = @ID_USUARIO;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @ERROR_ID = ERROR_NUMBER();
        SET @ERROR_DESCRIPTION = ERROR_MESSAGE();
    END CATCH
END;
GO


-- MODULO 2: PING


-- SP006: INSERTAR PING (USUARIO PACIENTE)
CREATE OR ALTER PROCEDURE SP_INSERTAR_PING
    @ID_USUARIO INT,
    @CODIGO VARCHAR(6),
    @ID_RETURN INT OUTPUT,
    @ERROR_ID INT OUTPUT,
    @ERROR_DESCRIPTION NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Verificar que el usuario exista y sea de tipo paciente (ID_TIPO_USUARIO = 1)
        IF NOT EXISTS (SELECT 1 FROM [dbo].[USUARIO] WHERE [ID_USUARIO] = @ID_USUARIO AND ID_TIPO_USUARIO = 1)
        BEGIN
            SET @ID_RETURN = -1;
            SET @ERROR_ID = 3;
            SET @ERROR_DESCRIPTION = 'El usuario no existe o no es un paciente';
            ROLLBACK TRANSACTION;
            RETURN;
        END
                -- Verificar si el usuario ya tiene un PING activo
        IF EXISTS (SELECT 1 FROM PING WHERE ID_USUARIO = @ID_USUARIO AND ESTADO = 1)
        BEGIN
            SET @ID_RETURN = -1;
            SET @ERROR_ID = 5;
            SET @ERROR_DESCRIPTION = 'El usuario ya tiene un PIN activo';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
                -- Verificar si el usuario ya tiene un PING activo
        IF EXISTS (SELECT 1 FROM PING WHERE ID_USUARIO = @ID_USUARIO AND ESTADO = 1)
        BEGIN
            SET @ID_RETURN = -1;
            SET @ERROR_ID = 5;
            SET @ERROR_DESCRIPTION = 'El usuario ya tiene un PIN activo';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        

        -- Verificar que el código no sea nulo
        IF @CODIGO IS NULL OR LEN(@CODIGO) <> 6 OR @CODIGO LIKE '%[^0-9]%'
        BEGIN
            SET @ID_RETURN = -1;
            SET @ERROR_ID = 4;
            SET @ERROR_DESCRIPTION = 'El PIN debe contener exactamente 6 dígitos numéricos';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Insertar el nuevo ping
        INSERT INTO PING (CODIGO, FECHA, ESTADO, ID_USUARIO)
        VALUES (@CODIGO, GETDATE(), 1, @ID_USUARIO);
        
        SET @ID_RETURN = SCOPE_IDENTITY();
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @ID_RETURN = -1;
        SET @ERROR_ID = ERROR_NUMBER();
        SET @ERROR_DESCRIPTION = ERROR_MESSAGE();
    END CATCH
END;
GO

-- SP007: ACTUALIZAR PING (USUARIO PACIENTE)
CREATE OR ALTER PROCEDURE SP_ACTUALIZAR_PING
    @ID_USUARIO INT,
    @PIN_ACTUAL VARCHAR(6),
    @NUEVO_CODIGO VARCHAR(6),
    @ID_RETURN INT OUTPUT,
    @ERROR_ID INT OUTPUT,
    @ERROR_DESCRIPTION NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        IF NOT EXISTS(SELECT 1 FROM [dbo].[PING]  WHERE ID_USUARIO = @ID_USUARIO  AND CODIGO = @PIN_ACTUAL AND ESTADO = 1)
        BEGIN
            SET @ID_RETURN = -1;
            SET @ERROR_ID = 2;
            SET @ERROR_DESCRIPTION = 'El PIN actual es incorrecto o no existe';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar que el nuevo código tenga 6 dígitos numéricos
        IF @NUEVO_CODIGO IS NULL OR LEN(@NUEVO_CODIGO) <> 6 OR @NUEVO_CODIGO LIKE '%[^0-9]%'
        BEGIN
            SET @ID_RETURN = -1;
            SET @ERROR_ID = 3;
            SET @ERROR_DESCRIPTION = 'El nuevo PIN debe contener exactamente 6 dígitos numéricos';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Actualizar el PIN activo
        UPDATE PING 
        SET ESTADO = 0
        WHERE ID_USUARIO = @ID_USUARIO AND CODIGO = @PIN_ACTUAL AND ESTADO = 1;

		INSERT INTO PING(CODIGO,FECHA,ESTADO,ID_USUARIO)
			VALUES(@NUEVO_CODIGO,GETDATE(),1,@ID_USUARIO)

		SET @ID_RETURN = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @ID_RETURN = -1;
        SET @ERROR_ID = ERROR_NUMBER();
        SET @ERROR_DESCRIPTION = ERROR_MESSAGE();
    END CATCH
END;
GO

-- SP008: ELIMINAR PING (CAMBIAR ESTADO A FALSE/0)
CREATE OR ALTER PROCEDURE SP_ELIMINAR_PING
    @ID_USUARIO INT,
    @CODIGO_PING VARCHAR(6),
    @ERROR_ID INT OUTPUT,
    @ERROR_DESCRIPTION NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Verificar si el usuario existe
        IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE ID_USUARIO = @ID_USUARIO)
        BEGIN
            SET @ERROR_ID = 1;
            SET @ERROR_DESCRIPTION = 'El usuario no existe.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Verificar si el usuario tiene un PING activo
        IF NOT EXISTS (SELECT 1 FROM PING WHERE ID_USUARIO = @ID_USUARIO AND ESTADO = 1)
        BEGIN
            SET @ERROR_ID = 2;
            SET @ERROR_DESCRIPTION = 'No hay un PING activo para este usuario.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar que el PIN proporcionado sea correcto
        IF NOT EXISTS (SELECT 1 FROM PING WHERE ID_USUARIO = @ID_USUARIO AND CODIGO = @CODIGO_PING AND ESTADO = 1)
        BEGIN
            SET @ERROR_ID = 3;
            SET @ERROR_DESCRIPTION = 'El PIN proporcionado es incorrecto.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Cambiar el estado del PING a 0 (desactivado)
        UPDATE PING
        SET ESTADO = 0
        WHERE ID_USUARIO = @ID_USUARIO AND CODIGO = @CODIGO_PING AND ESTADO = 1;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @ERROR_ID = ERROR_NUMBER();
        SET @ERROR_DESCRIPTION = ERROR_MESSAGE();
    END CATCH
END;
GO

-- MODULO 3: RELACIONES


-- SP009: INSERTAR RELACION (CUIDADOR PACIENTE)
CREATE OR ALTER PROCEDURE SP_INSERTAR_RELACION
    @ID_USUARIO_CUIDADOR INT,
    @CODIGO_PACIENTE VARCHAR(6),
    @ID_RETURN INT OUTPUT,
    @ERROR_ID INT OUTPUT,
    @ERROR_DESCRIPTION NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @ID_USUARIO_PACIENTE INT;

        -- Buscar el ID del paciente usando el código alfanumérico
        SELECT @ID_USUARIO_PACIENTE = ID_USUARIO FROM USUARIO WHERE CODIGO = @CODIGO_PACIENTE AND ID_TIPO_USUARIO = 1;

        -- Validar que el paciente exista
        IF @ID_USUARIO_PACIENTE IS NULL
        BEGIN
            SET @ID_RETURN = -1;
            SET @ERROR_ID = 1;
            SET @ERROR_DESCRIPTION = 'El código del paciente es incorrecto o no existe.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar que el cuidador exista
        IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE ID_USUARIO = @ID_USUARIO_CUIDADOR AND ID_TIPO_USUARIO = 2)
        BEGIN
            SET @ID_RETURN = -1;
            SET @ERROR_ID = 2;
            SET @ERROR_DESCRIPTION = 'El ID del cuidador no es válido.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Verificar si la relación ya existe
        IF EXISTS (SELECT 1 FROM CUIDADOR_PACIENTE WHERE ID_USUARIO_PACIENTE = @ID_USUARIO_PACIENTE AND ID_USUARIO_CUIDADOR = @ID_USUARIO_CUIDADOR AND FEC_FIN = NULL )
        BEGIN
            SET @ID_RETURN = -1;
            SET @ERROR_ID = 3;
            SET @ERROR_DESCRIPTION = 'La relación entre paciente y cuidador ya existe.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Insertar la relación en la tabla CUIDADOR_PACIENTE
        INSERT INTO CUIDADOR_PACIENTE (ID_USUARIO_CUIDADOR, ID_USUARIO_PACIENTE, FEC_INICIO)
        VALUES (@ID_USUARIO_CUIDADOR, @ID_USUARIO_PACIENTE, GETDATE());

        SET @ID_RETURN = SCOPE_IDENTITY();
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @ID_RETURN = -1;
        SET @ERROR_ID = ERROR_NUMBER();
        SET @ERROR_DESCRIPTION = ERROR_MESSAGE();
    END CATCH
END;
GO

-- SP:010: OBTENER RELACION (CUIDADOR PACIENTE)
CREATE OR ALTER PROCEDURE SP_OBTENER_RELACION
    @ID_CUIDADOR INT,
    @ERROR_ID INT OUTPUT,
    @ERROR_DESCRIPTION NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        -- Validar que el usuario es un cuidador
        IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE ID_USUARIO = @ID_CUIDADOR AND ID_TIPO_USUARIO = 2)
        BEGIN
            SET @ERROR_ID = 1;
            SET @ERROR_DESCRIPTION = 'El usuario no es un cuidador o no existe';
            RETURN;
        END

        -- Verificar si el cuidador tiene pacientes asignados
        IF NOT EXISTS (SELECT 1 FROM CUIDADOR_PACIENTE WHERE ID_USUARIO_CUIDADOR = @ID_CUIDADOR AND FEC_FIN = NULL)
        BEGIN
            SET @ERROR_ID = 2;
            SET @ERROR_DESCRIPTION = 'El cuidador no tiene pacientes asignados';
            RETURN;
        END

        -- Obtener los pacientes asignados al cuidador
        SELECT 
            U.ID_USUARIO AS ID_PACIENTE,
            U.NOMBRE,
            U.FECHA_NACIMIENTO
        FROM CUIDADOR_PACIENTE CP
        INNER JOIN USUARIO U ON CP.ID_USUARIO_PACIENTE = U.ID_USUARIO
        WHERE CP.ID_USUARIO_CUIDADOR = @ID_CUIDADOR;


    END TRY
    BEGIN CATCH
        SET @ERROR_ID = ERROR_NUMBER();
        SET @ERROR_DESCRIPTION = ERROR_MESSAGE();
    END CATCH
END;
GO

-- SP011: ELIMINAR RELACION (CUIDADOR PACIENTE)
CREATE OR ALTER PROCEDURE SP_TERMINAR_RELACION
    @ID_USUARIO_CUIDADOR INT,
    @ID_USUARIO_PACIENTE INT,
    @CODIGO_PING VARCHAR(6) = NULL, -- Opcional, solo requerido si el paciente termina la relación
    @ERROR_ID INT OUTPUT,
    @ERROR_DESCRIPTION NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Verificar si el paciente existe y si es realmente un paciente
        IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE ID_USUARIO = @ID_USUARIO_PACIENTE AND ID_TIPO_USUARIO = 1)
        BEGIN
            SET @ERROR_ID = 1;
            SET @ERROR_DESCRIPTION = 'El usuario paciente no existe o no es un paciente.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Verificar si el cuidador existe
        IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE ID_USUARIO = @ID_USUARIO_CUIDADOR)
        BEGIN
            SET @ERROR_ID = 2;
            SET @ERROR_DESCRIPTION = 'El usuario cuidador no existe.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Verificar si la relación existe y no está terminada
        IF NOT EXISTS (SELECT 1 FROM CUIDADOR_PACIENTE WHERE ID_USUARIO_CUIDADOR = @ID_USUARIO_CUIDADOR AND ID_USUARIO_PACIENTE = @ID_USUARIO_PACIENTE AND FEC_FIN IS NULL)
        BEGIN
            SET @ERROR_ID = 3;
            SET @ERROR_DESCRIPTION = 'La relación entre el paciente y el cuidador no existe o ya fue terminada.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Si el paciente está terminando la relación, validar su PING
        IF @CODIGO_PING != NULL AND EXISTS (SELECT 1 FROM PING WHERE ID_USUARIO = @ID_USUARIO_PACIENTE AND ESTADO = 1)
        BEGIN
            -- Validar que el PIN proporcionado sea correcto
            IF NOT EXISTS (SELECT 1 FROM PING WHERE ID_USUARIO = @ID_USUARIO_PACIENTE AND CODIGO = @CODIGO_PING AND ESTADO = 1)
            BEGIN
                SET @ERROR_ID = 4;
                SET @ERROR_DESCRIPTION = 'PIN incorrecto.';
                ROLLBACK TRANSACTION;
                RETURN;
            END
        END

        -- Actualizar la relación estableciendo la fecha de finalización
        UPDATE CUIDADOR_PACIENTE
        SET FEC_FIN = GETDATE()
        WHERE ID_USUARIO_CUIDADOR = @ID_USUARIO_CUIDADOR 
        AND ID_USUARIO_PACIENTE = @ID_USUARIO_PACIENTE 
        AND FEC_FIN IS NULL;

        SET @ERROR_ID = NULL;
        SET @ERROR_DESCRIPTION = NULL;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @ERROR_ID = ERROR_NUMBER();
        SET @ERROR_DESCRIPTION = ERROR_MESSAGE();
    END CATCH
END;
GO


-- MODULO 4: EVENTO


-- SP012: INSERTAR EVENTO
CREATE OR ALTER PROCEDURE SP_INSERTAR_EVENTO
    @ID_CUIDADOR INT,
    @TITULO VARCHAR(255),
    @DESCRIPCION VARCHAR(255) = NULL,
    @FECHA_HORA DATETIME,
    @ID_PRIORIDAD INT,
    @ID_RETURN INT OUTPUT,
    @ERROR_ID INT OUTPUT,
    @ERROR_DESCRIPTION NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el cuidador existe
        IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE ID_USUARIO = @ID_CUIDADOR AND ID_TIPO_USUARIO = 2)
        BEGIN
            SET @ID_RETURN = -1;
            SET @ERROR_ID = 1;
            SET @ERROR_DESCRIPTION = 'El usuario no es un cuidador o no existe';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar que la prioridad sea válida
        IF NOT EXISTS (SELECT 1 FROM PRIORIDAD WHERE ID_PRIORIDAD = @ID_PRIORIDAD)
        BEGIN
            SET @ID_RETURN = -1;
            SET @ERROR_ID = 2;
            SET @ERROR_DESCRIPTION = 'La prioridad seleccionada no es válida';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Insertar evento
        INSERT INTO EVENTO (TITULO, DESCRIPCION, FECHA_HORA, ID_PRIORIDAD, ID_USUARIO)
        VALUES (@TITULO, @DESCRIPCION, @FECHA_HORA, @ID_PRIORIDAD, @ID_CUIDADOR);

        SET @ID_RETURN = SCOPE_IDENTITY(); -- Obtener el ID generado

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @ID_RETURN = -1;
        SET @ERROR_ID = ERROR_NUMBER();
        SET @ERROR_DESCRIPTION = ERROR_MESSAGE();
    END CATCH
END;
GO

-- SP013: ACTUALIZAR EVENTO
CREATE OR ALTER PROCEDURE SP_ACTUALIZAR_EVENTO
    @ID_EVENTO INT,
    @ID_CUIDADOR INT,
    @TITULO VARCHAR(255),
    @DESCRIPCION VARCHAR(255) = NULL,
    @FECHA_HORA DATETIME,
    @ID_PRIORIDAD INT,
    @ERROR_ID INT OUTPUT,
    @ERROR_DESCRIPTION NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el evento existe y pertenece al cuidador
        IF NOT EXISTS (SELECT 1 FROM EVENTO WHERE ID_EVENTO = @ID_EVENTO AND ID_USUARIO = @ID_CUIDADOR)
        BEGIN
            SET @ERROR_ID = 1;
            SET @ERROR_DESCRIPTION = 'El evento no existe o no pertenece al cuidador';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar que la prioridad sea válida
        IF NOT EXISTS (SELECT 1 FROM PRIORIDAD WHERE ID_PRIORIDAD = @ID_PRIORIDAD)
        BEGIN
            SET @ERROR_ID = 2;
            SET @ERROR_DESCRIPTION = 'La prioridad seleccionada no es válida';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Actualizar el evento
        UPDATE EVENTO
        SET TITULO = @TITULO, 
            DESCRIPCION = @DESCRIPCION, 
            FECHA_HORA = @FECHA_HORA, 
            ID_PRIORIDAD = @ID_PRIORIDAD
        WHERE ID_EVENTO = @ID_EVENTO;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @ERROR_ID = ERROR_NUMBER();
        SET @ERROR_DESCRIPTION = ERROR_MESSAGE();
    END CATCH
END;
GO

-- SP014: ELIMINAR EVENTO
CREATE OR ALTER PROCEDURE SP_ELIMINAR_EVENTO
    @ID_EVENTO INT,
    @ID_CUIDADOR INT,
    @ERROR_ID INT OUTPUT,
    @ERROR_DESCRIPTION NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el evento existe y pertenece al cuidador
        IF NOT EXISTS (SELECT 1 FROM EVENTO WHERE ID_EVENTO = @ID_EVENTO AND ID_USUARIO = @ID_CUIDADOR)
        BEGIN
            SET @ERROR_ID = 1;
            SET @ERROR_DESCRIPTION = 'El evento no existe o no pertenece al cuidador';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Eliminar todas las relaciones en la tabla EVENTO_USUARIO
        DELETE FROM EVENTO_USUARIO 
        WHERE ID_EVENTO = @ID_EVENTO;

        -- Eliminar el evento de la tabla EVENTO
        DELETE FROM EVENTO 
        WHERE ID_EVENTO = @ID_EVENTO;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @ERROR_ID = ERROR_NUMBER();
        SET @ERROR_DESCRIPTION = ERROR_MESSAGE();
    END CATCH
END;

-- SP015: INSERTAR PACIENTE A EVENTO
CREATE OR ALTER PROCEDURE SP_INSERTAR_PACIENTE_EVENTO
    @ID_EVENTO INT,
	@ID_CUIDADOR INT,
    @ID_PACIENTE INT,
    @ID_RETURN INT OUTPUT,
    @ERROR_ID INT OUTPUT,
    @ERROR_DESCRIPTION NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el evento existe y pertenece al cuidador
        IF NOT EXISTS (SELECT 1 FROM EVENTO WHERE ID_EVENTO = @ID_EVENTO AND ID_USUARIO = @ID_CUIDADOR)
        BEGIN
            SET @ID_RETURN = -1;
            SET @ERROR_ID = 1;
            SET @ERROR_DESCRIPTION = 'El evento no existe';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar que el paciente existe
        IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE ID_USUARIO = @ID_PACIENTE AND ID_TIPO_USUARIO = 1)
        BEGIN
            SET @ID_RETURN = -1;
            SET @ERROR_ID = 2;
            SET @ERROR_DESCRIPTION = 'El paciente no existe';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Insertar relación evento-usuario
        INSERT INTO EVENTO_USUARIO (ID_EVENTO, ID_USUARIO, ID_ESTADO)
        VALUES (@ID_EVENTO, @ID_PACIENTE, 1);

        SET @ID_RETURN = SCOPE_IDENTITY(); -- Obtener el ID generado

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @ID_RETURN = -1;
        SET @ERROR_ID = ERROR_NUMBER();
        SET @ERROR_DESCRIPTION = ERROR_MESSAGE();
    END CATCH
END;
GO

-- SP016: ELIMINAR PACIENTE DE EVENTO
CREATE OR ALTER PROCEDURE SP_ELIMINAR_PACIENTE_EVENTO
    @ID_EVENTO INT,
    @ID_CUIDADOR INT,
    @ID_PACIENTE INT,
    @ERROR_ID INT OUTPUT,
    @ERROR_DESCRIPTION NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el evento existe y pertenece al cuidador
        IF NOT EXISTS (SELECT 1 FROM EVENTO WHERE ID_EVENTO = @ID_EVENTO AND ID_USUARIO = @ID_CUIDADOR)
        BEGIN
            SET @ERROR_ID = 1;
            SET @ERROR_DESCRIPTION = 'El evento no existe o no pertenece al cuidador';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar que el paciente está asignado al evento
        IF NOT EXISTS (SELECT 1 FROM EVENTO_USUARIO WHERE ID_EVENTO = @ID_EVENTO AND ID_USUARIO = @ID_PACIENTE)
        BEGIN
            SET @ERROR_ID = 2;
            SET @ERROR_DESCRIPTION = 'El paciente no está asociado a este evento';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Eliminar la relación del paciente con el evento
        DELETE FROM EVENTO_USUARIO
        WHERE ID_EVENTO = @ID_EVENTO 
        AND ID_USUARIO = @ID_PACIENTE;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @ERROR_ID = ERROR_NUMBER();
        SET @ERROR_DESCRIPTION = ERROR_MESSAGE();
    END CATCH
END;
GO

-- SP017: OBTENER EVENTOS DE PACIENTE
CREATE OR ALTER PROCEDURE SP_OBTENER_EVENTOS_PACIENTE
    @ID_PACIENTE INT,
	 @ID_RETURN INT OUTPUT,
    @ERROR_ID INT OUTPUT,
    @ERROR_DESCRIPTION NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        -- Obtener todos los eventos asociados al paciente, sin importar el cuidador
        SELECT 
            E.ID_EVENTO, -- Identificador único del evento
            E.TITULO, -- Título del evento
            E.DESCRIPCION, -- Descripción opcional del evento
            E.FECHA_HORA, -- Fecha y hora programada para el evento
            P.ID_PRIORIDAD, -- Identificador de la prioridad del evento (1: Baja, 2: Media, 3: Alta)
            P.DESCRIPCION AS PRIORIDAD, -- Nombre de la prioridad (Baja, Media, Alta)
            U.ID_USUARIO AS ID_CUIDADOR, -- Identificador del cuidador que creó el evento
            U.NOMBRE AS NOMBRE_CUIDADOR -- Nombre del cuidador que creó el evento
        FROM EVENTO E
        -- Relaciona el evento con la prioridad
        INNER JOIN PRIORIDAD P ON E.ID_PRIORIDAD = P.ID_PRIORIDAD
        -- Relaciona el evento con los pacientes asignados
        INNER JOIN EVENTO_USUARIO EU ON E.ID_EVENTO = EU.ID_EVENTO
        -- Relaciona el evento con el cuidador que lo creó
        INNER JOIN USUARIO U ON E.ID_USUARIO = U.ID_USUARIO
        -- Filtra los eventos asignados al paciente solicitado
        WHERE EU.ID_USUARIO = @ID_PACIENTE;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @ID_RETURN = -1;
        SET @ERROR_ID = ERROR_NUMBER();
        SET @ERROR_DESCRIPTION = ERROR_MESSAGE();
    END CATCH
END;

-- SP018: OBTENER EVENTOS DE CUIDADOR
CREATE OR ALTER PROCEDURE SP_OBTENER_EVENTOS_CUIDADOR
    @ID_CUIDADOR INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Obtener los eventos del cuidador con la lista de pacientes en formato JSON
    SELECT 
        E.ID_EVENTO,
        E.TITULO,
        E.DESCRIPCION,
        E.FECHA_HORA,
        P.ID_PRIORIDAD,
        P.DESCRIPCION AS PRIORIDAD,
        (
            SELECT U.ID_USUARIO AS ID, U.NOMBRE AS NOMBRE
            FROM EVENTO_USUARIO EU
            INNER JOIN USUARIO U ON EU.ID_USUARIO = U.ID_USUARIO
            WHERE EU.ID_EVENTO = E.ID_EVENTO
            FOR JSON PATH
        ) AS PACIENTES
    FROM EVENTO E
    INNER JOIN PRIORIDAD P ON E.ID_PRIORIDAD = P.ID_PRIORIDAD
    WHERE E.ID_USUARIO = @ID_CUIDADOR;
END;
GO

-- MODULO 5: MENSAJE


-- SP019: INSERTAR MENSAJE (ENVIAR MENSAJE DE CUIDADOR A PACIENTE)
CREATE OR ALTER PROCEDURE SP_INSERTAR_MENSAJE
    @ID_CUIDADOR INT,
    @ID_PACIENTE INT,
    @CONTENIDO VARCHAR(255),
    @ID_RETURN INT OUTPUT,
    @ERROR_ID INT OUTPUT,
    @ERROR_DESCRIPTION NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el usuario que envía el mensaje es un cuidador
        IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE ID_USUARIO = @ID_CUIDADOR AND ID_TIPO_USUARIO = 2)
        BEGIN
            SET @ID_RETURN = -1;
            SET @ERROR_ID = 1;
            SET @ERROR_DESCRIPTION = 'El usuario no es un cuidador o no existe';
            ROLLBACK TRANSACTION;
            RETURN;
        END
    
        -- Validar que el paciente existe
        IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE ID_USUARIO = @ID_PACIENTE AND ID_TIPO_USUARIO = 1)
        BEGIN
            SET @ID_RETURN = -1;
            SET @ERROR_ID = 2;
            SET @ERROR_DESCRIPTION = 'El paciente no existe';
            ROLLBACK TRANSACTION;
            RETURN;
        END

		IF NOT EXISTS (SELECT 1 FROM CUIDADOR_PACIENTE WHERE ID_USUARIO_CUIDADOR = @ID_CUIDADOR AND ID_USUARIO_PACIENTE = @ID_PACIENTE)
		BEGIN
			SET @ID_RETURN = -1;
            SET @ERROR_ID = 2;
            SET @ERROR_DESCRIPTION = 'NO SE ENCONTRÓ RELACION CON EL CLIENTE';
            ROLLBACK TRANSACTION;
            RETURN;
		END

        -- Insertar mensaje
        INSERT INTO MENSAJE (CONTENIDO, FECHA_ENVIADO, FECHA_RECIBIDO, ID_USUARIO_CUIDADOR, ID_USUARIO_PACIENTE, ID_ESTADO) 
        VALUES (@CONTENIDO, GETDATE(), NULL, @ID_CUIDADOR, @ID_PACIENTE, 1)

        SET @ID_RETURN = SCOPE_IDENTITY(); -- Obtener el ID del mensaje generado

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @ID_RETURN = -1;
        SET @ERROR_ID = ERROR_NUMBER();
        SET @ERROR_DESCRIPTION = ERROR_MESSAGE();
    END CATCH
END;
GO

-- SP020: OBTENER MENSAJES (USUARIO PACIENTE)
CREATE OR ALTER PROCEDURE SP_OBTENER_MENSAJES
    @ID_PACIENTE INT,
	@ERROR_ID INT OUTPUT,
    @ERROR_DESCRIPTION NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Actualizar el estado de los mensajes no recibidos (ID_ESTADO = 1 → 2)
        UPDATE MENSAJE
        SET ID_ESTADO = 2, FECHA_RECIBIDO = GETDATE()
        WHERE ID_USUARIO_PACIENTE = @ID_PACIENTE AND ID_ESTADO = 1;

        -- Obtener todos los mensajes asignados al paciente
        SELECT 
            M.ID_MENSAJE,
            M.CONTENIDO,
            M.FECHA_ENVIADO,
            M.ID_USUARIO_CUIDADOR AS ID_CUIDADOR,
            U.NOMBRE AS NOMBRE_CUIDADOR,
            M.ID_ESTADO
        FROM MENSAJE M
        INNER JOIN USUARIO U ON M.ID_USUARIO_CUIDADOR = U.ID_USUARIO
        WHERE M.ID_USUARIO_PACIENTE = @ID_PACIENTE;

        -- Si todo salió bien, confirmar los cambios
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        SET @ERROR_ID = ERROR_NUMBER();
        SET @ERROR_DESCRIPTION = ERROR_MESSAGE();
        ROLLBACK TRANSACTION;
    END CATCH
END;
GO

-- SP021: ACTUALIZAR ESTADO DEL MENSAJE (DE RECIBIDO A LEIDO)
CREATE OR ALTER PROCEDURE SP_ACTUALIZAR_ESTADO_MENSAJES
    @ID_PACIENTE INT,
	@ID_MENSAJE INT,
	@ERROR_ID INT OUTPUT,
    @ERROR_DESCRIPTION NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
		
		IF NOT EXISTS ( SELECT 1 FROM USUARIO WHERE @ID_PACIENTE = ID_USUARIO AND ID_TIPO_USUARIO = 1)
		BEGIN
            SET @ERROR_ID = 1;
            SET @ERROR_DESCRIPTION = 'El usuario no es un PACIENTE o no existe';
            ROLLBACK TRANSACTION;
            RETURN;
		END
		
		IF NOT EXISTS ( SELECT 1 FROM MENSAJE WHERE @ID_MENSAJE = ID_MENSAJE AND @ID_PACIENTE = ID_USUARIO_PACIENTE)
		BEGIN
		    SET @ERROR_ID = 1;
            SET @ERROR_DESCRIPTION = 'NO EXISTE EL MENSAJE O NO PERTENECE AL PACIENTE';
            ROLLBACK TRANSACTION;
            RETURN;
		END

        -- Actualizar el estado del mensaje a leído y registrar la hora de recepción
        UPDATE MENSAJE
        SET ID_ESTADO = 3
        WHERE ID_USUARIO_PACIENTE = @ID_PACIENTE AND ID_ESTADO = 2 AND @ID_MENSAJE = ID_MENSAJE

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
    END CATCH
END;
GO


-- MODULO 6: JUEGO


-- SP022: INSERTAR JUEGO
CREATE OR ALTER PROCEDURE SP_INSERTAR_JUEGO
    @ID_CUIDADOR INT,
    @NOMBRE VARCHAR(255),
    @ID_RETURN INT OUTPUT,
    @ERROR_ID INT OUTPUT,
    @ERROR_DESCRIPTION NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el usuario sea un cuidador
        IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE ID_USUARIO = @ID_CUIDADOR AND ID_TIPO_USUARIO = 2)
        BEGIN
            SET @ID_RETURN = -1;
            SET @ERROR_ID = 1;
            SET @ERROR_DESCRIPTION = 'El usuario no es un cuidador o no existe';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Insertar el juego
        INSERT INTO JUEGO (NOMBRE, ID_USUARIO_CREADOR)
        VALUES (@NOMBRE, @ID_CUIDADOR);

        SET @ID_RETURN = SCOPE_IDENTITY(); -- Obtener el ID del juego creado

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @ID_RETURN = -1;
        SET @ERROR_ID = ERROR_NUMBER();
        SET @ERROR_DESCRIPTION = ERROR_MESSAGE();
    END CATCH
END;
GO

-- SP023: INSERTAR PREGUNTA (PUEDE INCLUIR IMAGEN)
CREATE OR ALTER PROCEDURE SP_INSERTAR_PREGUNTA
    @ID_JUEGO INT,
    @TITULO VARCHAR(255),
    @DESCRIPCION VARCHAR(MAX),
    @BINARIO_FOTO VARBINARY(MAX),
    @TITULO_IMAGEN VARCHAR(255),
    @ID_USUARIO INT,
	@ID_RETURN INT OUTPUT,
    @ID_RETURN_2 INT OUTPUT,
    @ERROR_ID INT OUTPUT,
    @ERROR_DESCRIPTION NVARCHAR(MAX) OUTPUT
AS
BEGIN
    
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el juego exista y pertenezca al usuario
        IF NOT EXISTS (SELECT 1 FROM JUEGO WHERE ID_JUEGO = @ID_JUEGO AND ID_USUARIO_CREADOR = @ID_USUARIO)
        BEGIN
            SET @ID_RETURN = -1;
			SET @ID_RETURN_2 = -1;
            SET @ERROR_ID = 1;
            SET @ERROR_DESCRIPTION = 'El juego no existe o no pertenece al usuario';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Insertar la imagen
        INSERT INTO IMAGEN (BINARIO_FOTO)
        VALUES (@BINARIO_FOTO);

        -- Obtener el ID de la imagen creada
        SET @ID_RETURN = SCOPE_IDENTITY();

        -- Insertar la pregunta con la imagen asociada
        INSERT INTO PREGUNTA (DESCRIPCION, ID_JUEGO, ID_IMAGEN)
        VALUES (@DESCRIPCION, @ID_JUEGO, @ID_RETURN);

        -- Obtener el ID de la pregunta creada
        SET @ID_RETURN_2 = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @ID_RETURN = -1;
		SET @ID_RETURN_2 = -1;
        SET @ERROR_ID = ERROR_NUMBER();
        SET @ERROR_DESCRIPTION = ERROR_MESSAGE();
    END CATCH
END;
GO

-- SP024: INSERTAR OPCION (OPCIÓN CORRECTA O OPCIONES INCORRECTAS)
CREATE OR ALTER PROCEDURE SP_INSERTAR_OPCION
    @ID_PREGUNTA INT,
	@ID_CUIDADOR INT,
    @DESCRIPCION VARCHAR(255),
    @CONDICION BIT, -- 1 = Correcta, 0 = Incorrecta
    @ID_RETURN INT OUTPUT,
    @ERROR_ID INT OUTPUT,
    @ERROR_DESCRIPTION NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

		IF NOT EXISTS (SELECT 1 FROM PREGUNTA P INNER JOIN JUEGO J ON J.ID_JUEGO = P.ID_JUEGO WHERE J.ID_USUARIO_CREADOR = @ID_CUIDADOR)
		BEGIN
		    SET @ID_RETURN = -1;
            SET @ERROR_ID = 1;
            SET @ERROR_DESCRIPTION = 'La pregunta no PERTENECE AL USUARIO';
            ROLLBACK TRANSACTION;
            RETURN;
		END

        -- Validar que la pregunta exista
        IF NOT EXISTS (SELECT 1 FROM PREGUNTA WHERE ID_PREGUNTA = @ID_PREGUNTA)
        BEGIN
            SET @ID_RETURN = -1;
            SET @ERROR_ID = 1;
            SET @ERROR_DESCRIPTION = 'La pregunta no existe';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Si la nueva opción es la correcta, asegurarse de que no haya otra opción correcta ya asignada
        IF @CONDICION = 1 AND EXISTS (SELECT 1 FROM OPCION WHERE ID_PREGUNTA = @ID_PREGUNTA AND CONDICION = 1)
        BEGIN
            SET @ID_RETURN = -1;
            SET @ERROR_ID = 2;
            SET @ERROR_DESCRIPTION = 'Ya existe una opción marcada como correcta para esta pregunta';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Insertar la opción de respuesta
        INSERT INTO OPCION (DESCRIPCION, CONDICION, ID_PREGUNTA)
        VALUES (@DESCRIPCION, @CONDICION, @ID_PREGUNTA);

        SET @ID_RETURN = SCOPE_IDENTITY(); -- Obtener el ID de la opción creada

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @ID_RETURN = -1;
        SET @ERROR_ID = ERROR_NUMBER();
        SET @ERROR_DESCRIPTION = ERROR_MESSAGE();
    END CATCH
END;
GO

-- SP025: INSERTAR PACIENTE A UN JUEGO (RELACION QUE LE PERMITE AL PACIENTE DAR USO AL JUEGO)
CREATE OR ALTER PROCEDURE SP_INSERTAR_PACIENTE_JUEGO
    @ID_JUEGO INT,
    @ID_CUIDADOR INT,
    @ID_PACIENTE INT,
    @ID_RETURN INT OUTPUT,
    @ERROR_ID INT OUTPUT,
    @ERROR_DESCRIPTION NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el paciente está relacionado con el cuidador
        IF NOT EXISTS (SELECT 1 FROM CUIDADOR_PACIENTE WHERE ID_USUARIO_CUIDADOR = @ID_CUIDADOR AND ID_USUARIO_PACIENTE = @ID_PACIENTE)
        BEGIN
            SET @ID_RETURN = -1;
            SET @ERROR_ID = 2;
            SET @ERROR_DESCRIPTION = 'El paciente no está asignado a este cuidador';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar que el juego ya no esté asignado al paciente
        IF EXISTS (SELECT 1 FROM JUEGO_PACIENTE WHERE ID_JUEGO = @ID_JUEGO AND ID_PACIENTE = @ID_PACIENTE)
        BEGIN
            SET @ID_RETURN = -1;
            SET @ERROR_ID = 3;
            SET @ERROR_DESCRIPTION = 'El paciente ya tiene asignado este juego';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Asignar el juego al paciente
        INSERT INTO JUEGO_PACIENTE (ID_JUEGO, ID_PACIENTE)
        VALUES (@ID_JUEGO, @ID_PACIENTE);

        SET @ID_RETURN = @ID_JUEGO;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @ID_RETURN = -1;
        SET @ERROR_ID = ERROR_NUMBER();
        SET @ERROR_DESCRIPTION = ERROR_MESSAGE();
    END CATCH
END;
GO

-- SP026: OBTENER JUEGOS CREADOS (POR USUARIO CUIDADOR)
CREATE OR ALTER PROCEDURE SP_OBTENER_JUEGOS_CREADOS
    @ID_CUIDADOR INT,
	@ERROR_ID INT OUTPUT,
    @ERROR_DESCRIPTION NVARCHAR(MAX) OUTPUT
AS
BEGIN

    BEGIN TRY
		BEGIN TRANSACTION; 


		IF NOT EXISTS(SELECT 1 FROM USUARIO WHERE ID_USUARIO = @ID_CUIDADOR AND ID_TIPO_USUARIO = 2)
		BEGIN
            SET @ERROR_ID = 2;
            SET @ERROR_DESCRIPTION = 'Usuario no existe o no es cuidador';
            ROLLBACK TRANSACTION;
            RETURN;
		END
        -- Obtener los juegos creados por el cuidador con el número de preguntas asociadas
        SELECT 
            J.ID_JUEGO,
            J.NOMBRE,
            (SELECT COUNT(*) FROM PREGUNTA WHERE ID_JUEGO = J.ID_JUEGO) AS TOTAL_PREGUNTAS
        FROM JUEGO J
        WHERE WHERE ID_USUARIO_CREADOR = @ID_CUIDADOR;

        COMMIT TRANSACTION; 
    END TRY
    BEGIN CATCH
	    SET @ERROR_ID = ERROR_NUMBER();
        SET @ERROR_DESCRIPTION = ERROR_MESSAGE();
        ROLLBACK TRANSACTION;
    END CATCH
END;
GO
-- SP027: OBTENER JUEGOS DISPONIBLES (PARA USUARIO PACIENTE)
CREATE OR ALTER PROCEDURE SP_OBTENER_JUEGOS_DISPONIBLES
    @ID_PACIENTE INT,
	@ERROR_ID INT OUTPUT,
    @ERROR_DESCRIPTION NVARCHAR(MAX) OUTPUT
AS
BEGIN

    BEGIN TRY
		BEGIN TRANSACTION; 


		IF NOT EXISTS(SELECT 1 FROM USUARIO WHERE ID_USUARIO = @ID_PACIENTE AND ID_TIPO_USUARIO = 1)
		BEGIN
            SET @ERROR_ID = 2;
            SET @ERROR_DESCRIPTION = 'Usuario no existe o no es paciente';
            ROLLBACK TRANSACTION;
            RETURN;
		END

        -- Obtener los juegos creados por el cuidador con el número de preguntas asociadas
        SELECT 
            J.ID_JUEGO,
            J.NOMBRE,
            (SELECT COUNT(*) FROM PREGUNTA WHERE ID_JUEGO = J.ID_JUEGO) AS TOTAL_PREGUNTAS
        FROM JUEGO J
		INNER JOIN JUEGO_PACIENTE JP ON JP.ID_JUEGO = J.ID_JUEGO
        WHERE JP.ID_PACIENTE = @ID_PACIENTE;

        COMMIT TRANSACTION; 
    END TRY
    BEGIN CATCH
	    SET @ERROR_ID = ERROR_NUMBER();
        SET @ERROR_DESCRIPTION = ERROR_MESSAGE();
        ROLLBACK TRANSACTION;
    END CATCH
END;
GO

-- SP028: OBTENER PREGUNTAS DE UN JUEGO (JUNTO A SUS OPCIONES)
CREATE OR ALTER PROCEDURE SP_OBTENER_PREGUNTAS
    @ID_JUEGO INT,
    @ERROR_ID INT OUTPUT,
    @ERROR_DESCRIPTION NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
		BEGIN TRANSACTION
        -- Validar que el juego exista
        IF NOT EXISTS (SELECT 1 FROM JUEGO WHERE ID_JUEGO = @ID_JUEGO)
        BEGIN
            SET @ERROR_ID = 1;
            SET @ERROR_DESCRIPTION = 'El juego no existe';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Obtener las preguntas con la imagen asociada y las opciones formateadas en JSON
        SELECT 
            P.ID_PREGUNTA,
            P.DESCRIPCION,
            I.BINARIO_FOTO AS IMAGEN_BINARIA,
            (SELECT O.ID_OPCION, O.DESCRIPCION, O.CONDICION
             FROM OPCION O
             WHERE O.ID_PREGUNTA = P.ID_PREGUNTA
             FOR JSON PATH, INCLUDE_NULL_VALUES) AS OPCIONES
        FROM PREGUNTA P
        INNER JOIN IMAGEN I ON P.ID_IMAGEN = I.ID_IMAGEN
        WHERE P.ID_JUEGO = @ID_JUEGO;
		
		COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @ERROR_ID = ERROR_NUMBER();
        SET @ERROR_DESCRIPTION = ERROR_MESSAGE();
    END CATCH
END;
GO

-- SP029: ELIMINAR JUEGO
CREATE OR ALTER PROCEDURE SP_ELIMINAR_JUEGO
    @ID_JUEGO INT,
	@ID_CUIDADOR INT,
    @ERROR_ID INT OUTPUT,
    @ERROR_DESCRIPTION NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;


        -- Validar que el juego existe
        IF NOT EXISTS (SELECT 1 FROM JUEGO WHERE ID_JUEGO = @ID_JUEGO)
        BEGIN
            SET @ERROR_ID = 1;
            SET @ERROR_DESCRIPTION = 'El juego no existe';
            ROLLBACK TRANSACTION;
            RETURN;
        END
				-- VALIDAR QUE EL JUEGO PERTENEZCA AL CUIDADOR
		IF NOT EXISTS (SELECT 1 FROM JUEGO WHERE ID_USUARIO_CREADOR = @ID_CUIDADOR)
        BEGIN
            SET @ERROR_ID = 1;
            SET @ERROR_DESCRIPTION = 'eL JUEGO NO PERTENECE AL USUARIO';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar que no tenga pacientes asignados
        IF EXISTS (SELECT 1 FROM JUEGO_PACIENTE WHERE ID_JUEGO = @ID_JUEGO)
        BEGIN
            SET @ERROR_ID = 2;
            SET @ERROR_DESCRIPTION = 'No se puede eliminar el juego porque tiene pacientes asignados';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Eliminar opciones de las preguntas
        DELETE FROM OPCION WHERE ID_PREGUNTA IN (SELECT ID_PREGUNTA FROM PREGUNTA WHERE ID_JUEGO = @ID_JUEGO);

		--Eliminar imagenes del juego
		DELETE FROM IMAGEN WHERE ID_IMAGEN IN (SELECT ID_IMAGEN FROM PREGUNTA WHERE ID_JUEGO = @ID_JUEGO);

        -- Eliminar preguntas del juego
        DELETE FROM PREGUNTA WHERE ID_JUEGO = @ID_JUEGO;

        -- Eliminar el juego
        DELETE FROM JUEGO WHERE ID_JUEGO = @ID_JUEGO;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @ERROR_ID = ERROR_NUMBER();
        SET @ERROR_DESCRIPTION = ERROR_MESSAGE();
    END CATCH
END;
GO