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
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @ID_RETURN = -1;
		SET @ERROR_ID  = ERROR_NUMBER();
		SET @ERROR_DESCRIPTION =ERROR_MESSAGE();
    END CATCH
END;



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

