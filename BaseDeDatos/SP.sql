--Registrar un usuario nuevo
CREATE OR ALTER PROCEDURE SP_REGISTRAR_USUARIO
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

--Actualizar foto de perfil
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

--Insertar un ping 
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

--Editar datos del usuario 
CREATE OR ALTER PROCEDURE SP_EDITAR_USUARIO
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

--Modificar ping
CREATE OR ALTER PROCEDURE SP_MODIFICAR_PING
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

--Sp cambio de contra
CREATE OR ALTER PROCEDURE SP_CAMBIAR_CONTRASENA
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




--SP RELACION ENTRE CUIDADOR PACIENTE 

CREATE OR ALTER PROCEDURE SP_RELACIONAR_PACIENTE_CUIDADOR
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
        IF EXISTS (SELECT 1 FROM CUIDADOR_PACIENTE WHERE ID_USUARIO_PACIENTE = @ID_USUARIO_PACIENTE AND ID_USUARIO_CUIDADOR = @ID_USUARIO_CUIDADOR)
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




-- SP para eliminar la foto de perfil con validación de PING si es paciente (1)
CREATE PROCEDURE SP_EliminarFotoPerfil
    @ID_USUARIO INT,
    @CODIGO_PING VARCHAR(6) = NULL,  -- Opcional, solo requerido si hay un ping activo
	@ERROR_ID INT OUTPUT,
    @ERROR_DESCRIPTION NVARCHAR(MAX) OUTPUT
AS
BEGIN

	DECLARE @PING_ACTIVO BIT = 0;


   
	IF EXISTS (SELECT 1 FROM [dbo].[PING] WHERE [ID_USUARIO] = @ID_USUARIO AND [ESTADO] = 1)
	BEGIN
	 IF NOT EXISTS(SELECT 1 FROM [dbo].[PING]  WHERE ID_USUARIO = @ID_USUARIO  AND CODIGO = @CODIGO_PING AND ESTADO = 1)
        BEGIN
            SET @ERROR_ID = 4;
            SET @ERROR_DESCRIPTION = 'PIN incorrecto.';
            ROLLBACK TRANSACTION;
            RETURN;
        END
	END

    -- Si el usuario no es paciente o no tiene PING activo, o el PING es válido, eliminar la foto
    IF EXISTS (SELECT 1 FROM [dbo].[USUARIO] WHERE @ID_USUARIO =[ID_USUARIO])
    BEGIN
        UPDATE USUARIO
        SET FOTO_PERFIL = NULL
        WHERE ID_USUARIO = @ID_USUARIO;
    END
	ELSE 
	BEGIN
	 SET @ERROR_ID = 4;
            SET @ERROR_DESCRIPTION = 'USUARIO NO EXISTE.';
            ROLLBACK TRANSACTION;
	END
END;
GO