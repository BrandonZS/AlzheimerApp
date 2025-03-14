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
        WHERE EXISTS (SELECT 1 FROM PREGUNTA WHERE ID_JUEGO = J.ID_JUEGO);
    END TRY
    BEGIN CATCH
    END CATCH
END;



go


-- SP agregar pergunta

CREATE OR ALTER PROCEDURE SP_AGREGAR_PREGUNTA_CON_IMAGEN
    @ID_JUEGO INT,
    @TITULO VARCHAR(255),
    @DESCRIPCION VARCHAR(MAX),
    @BINARIO_FOTO VARBINARY(MAX),
    @TITULO_IMAGEN VARCHAR(255),
    @ID_USUARIO INT,
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


GO


--SP para agregar respuestas  con imagen
CREATE OR ALTER PROCEDURE SP_AGREGAR_RESPUESTA
    @ID_PREGUNTA INT,
    @DESCRIPCION VARCHAR(255),
    @CONDICION BIT, -- 1 = Correcta, 0 = Incorrecta
    @ID_RETURN INT OUTPUT,
    @ERROR_ID INT OUTPUT,
    @ERROR_DESCRIPTION NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

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



--SP para asignar un juego a un paciente
CREATE OR ALTER PROCEDURE SP_ASIGNAR_JUEGO_A_PACIENTE
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
        IF EXISTS (SELECT 1 FROM JUEGO_USUARIO WHERE ID_JUEGO = @ID_JUEGO AND ID_USUARIO = @ID_PACIENTE)
        BEGIN
            SET @ID_RETURN = -1;
            SET @ERROR_ID = 3;
            SET @ERROR_DESCRIPTION = 'El paciente ya tiene asignado este juego';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Asignar el juego al paciente
        INSERT INTO JUEGO_USUARIO (ID_JUEGO, ID_USUARIO)
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



--SP para obtener las preguntas con su imagen
CREATE OR ALTER PROCEDURE SP_OBTENER_PREGUNTAS_JUEGO
    @ID_JUEGO INT
AS
BEGIN
    BEGIN TRY
        -- Validar que el juego exista
        IF NOT EXISTS (SELECT 1 FROM JUEGO WHERE ID_JUEGO = @ID_JUEGO)
        BEGIN
            PRINT 'El juego no existe';
            RETURN;
        END

        -- Obtener las preguntas con la imagen asociada y las opciones formateadas en JSON
        SELECT 
            P.ID_PREGUNTA,
            P.TITULO,
            P.DESCRIPCION,
            I.TITULO AS IMAGEN_TITULO,
            I.BINARIO_FOTO AS IMAGEN_BINARIA,
            (SELECT O.ID_OPCION, O.DESCRIPCION, O.CONDICION
             FROM OPCION O
             WHERE O.ID_PREGUNTA = P.ID_PREGUNTA
             FOR JSON PATH, INCLUDE_NULL_VALUES) AS OPCIONES
        FROM PREGUNTA P
        INNER JOIN IMAGEN I ON P.ID_IMAGEN = I.ID_IMAGEN
        WHERE P.ID_JUEGO = @ID_JUEGO;
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END;

go




--SP para eliminar un juego y sus relaciones
CREATE OR ALTER PROCEDURE SP_ELIMINAR_JUEGO
    @ID_JUEGO INT,
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

        -- Validar que no tenga pacientes asignados
        IF EXISTS (SELECT 1 FROM JUEGO_USUARIO WHERE ID_JUEGO = @ID_JUEGO)
        BEGIN
            SET @ERROR_ID = 2;
            SET @ERROR_DESCRIPTION = 'No se puede eliminar el juego porque tiene pacientes asignados';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Eliminar opciones de las preguntas
        DELETE FROM OPCION WHERE ID_PREGUNTA IN (SELECT ID_PREGUNTA FROM PREGUNTA WHERE ID_JUEGO = @ID_JUEGO);

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


go


----------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE SP_OBTENER_PACIENTES_CUIDADOR
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
        IF NOT EXISTS (SELECT 1 FROM CUIDADOR_PACIENTE WHERE ID_USUARIO_CUIDADOR = @ID_CUIDADOR)
        BEGIN
            SET @ERROR_ID = 2;
            SET @ERROR_DESCRIPTION = 'El cuidador no tiene pacientes asignados';
            RETURN;
        END

        -- Obtener los pacientes asignados al cuidador
        SELECT 
            U.ID_USUARIO AS ID_PACIENTE,
            U.NOMBRE,
            U.FECHA_NACIMIENTO,
            U.FOTO_PERFIL
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
