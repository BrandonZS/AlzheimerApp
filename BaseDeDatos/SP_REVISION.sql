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

GO


--SP para crear un juego

CREATE OR ALTER PROCEDURE SP_CREAR_JUEGO
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
        INSERT INTO JUEGO (NOMBRE)
        VALUES (@NOMBRE);

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
go

--SP para obtener los juegos creados

CREATE OR ALTER PROCEDURE SP_OBTENER_JUEGOS_CREADOS
    @ID_CUIDADOR INT
AS
BEGIN
    BEGIN TRY
        -- Obtener los juegos creados por el cuidador con el número de preguntas asociadas
        SELECT 
            J.ID_JUEGO,
            J.NOMBRE,
            (SELECT COUNT(*) FROM PREGUNTA WHERE ID_JUEGO = J.ID_JUEGO) AS TOTAL_PREGUNTAS
        FROM JUEGO J
        INNER JOIN USUARIO U ON U.ID_USUARIO = @ID_CUIDADOR
        WHERE U.ID_TIPO_USUARIO = 2; -- Solo cuidadores pueden crear juegos
    END TRY
    BEGIN CATCH
    END CATCH
END;


go

--SP para agregar una pregunta con imagen

CREATE OR ALTER PROCEDURE SP_AGREGAR_PREGUNTA_CON_IMAGEN
    @ID_JUEGO INT,
    @TITULO VARCHAR(255),
    @DESCRIPCION VARCHAR(MAX),
    @BINARIO_FOTO VARBINARY(MAX),
    @TITULO_IMAGEN VARCHAR(255),
    @ID_USUARIO INT, -- Usuario que sube la imagen
    @ID_RETURN INT OUTPUT,
    @ERROR_ID INT OUTPUT,
    @ERROR_DESCRIPTION NVARCHAR(MAX) OUTPUT
AS
BEGIN
    DECLARE @ID_IMAGEN INT;
    
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el juego exista
        IF NOT EXISTS (SELECT 1 FROM JUEGO WHERE ID_JUEGO = @ID_JUEGO)
        BEGIN
            SET @ID_RETURN = -1;
            SET @ERROR_ID = 1;
            SET @ERROR_DESCRIPTION = 'El juego no existe';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Insertar la imagen
        INSERT INTO IMAGEN (BINARIO_FOTO, TITULO, ID_USUARIO)
        VALUES (@BINARIO_FOTO, @TITULO_IMAGEN, @ID_USUARIO);

        -- Obtener el ID de la imagen creada
        SET @ID_IMAGEN = SCOPE_IDENTITY();

        -- Insertar la pregunta con la imagen asociada
        INSERT INTO PREGUNTA (TITULO, DESCRIPCION, ID_JUEGO, ID_IMAGEN)
        VALUES (@TITULO, @DESCRIPCION, @ID_JUEGO, @ID_IMAGEN);

        -- Obtener el ID de la pregunta creada
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
go
