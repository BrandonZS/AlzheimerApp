-- Procedimiento para enviar un mensaje a un paciente
CREATE OR ALTER PROCEDURE SP_ENVIAR_MENSAJE
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

        -- Insertar mensaje
        INSERT INTO MENSAJE (CONTENIDO, ID_USUARIO, FECHA_HORA)
        VALUES (@CONTENIDO, @ID_CUIDADOR, GETDATE());

        SET @ID_RETURN = SCOPE_IDENTITY(); -- Obtener el ID del mensaje generado

        -- Asignar el mensaje al paciente
        INSERT INTO MENSAJE_USUARIO (ID_MENSAJE, ID_USUARIO, ID_ESTADO, HORA_RECIBIDO)
        VALUES (@ID_RETURN, @ID_PACIENTE, 1, NULL); -- Estado 1: Enviado

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


-- Procedimiento para obtener los mensajes de un paciente
CREATE OR ALTER PROCEDURE SP_OBTENER_MENSAJES_PACIENTE
    @ID_PACIENTE INT
AS
BEGIN
    BEGIN TRY
        -- Obtener todos los mensajes asignados al paciente
        SELECT 
            M.ID_MENSAJE,
            M.CONTENIDO,
            M.FECHA_HORA,
            U.ID_USUARIO AS ID_CUIDADOR,
            U.NOMBRE AS NOMBRE_CUIDADOR,
            MU.ID_ESTADO,
            MU.HORA_RECIBIDO
        FROM MENSAJE M
        INNER JOIN MENSAJE_USUARIO MU ON M.ID_MENSAJE = MU.ID_MENSAJE
        INNER JOIN USUARIO U ON M.ID_USUARIO = U.ID_USUARIO
        WHERE MU.ID_USUARIO = @ID_PACIENTE;
    END TRY
    BEGIN CATCH
    END CATCH
END;
GO


-- Procedimiento para actualizar el estado de los mensajes como 'vistos'
CREATE OR ALTER PROCEDURE SP_ACTUALIZAR_ESTADO_MENSAJES
    @ID_PACIENTE INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Actualizar el estado del mensaje a leído y registrar la hora de recepción
        UPDATE MENSAJE_USUARIO
        SET ID_ESTADO = 2, HORA_RECIBIDO = GETDATE()
        WHERE ID_USUARIO = @ID_PACIENTE AND ID_ESTADO = 1; -- Solo actualizar mensajes no leídos

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
    END CATCH
END;
