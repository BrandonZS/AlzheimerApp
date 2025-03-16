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
CREATE OR ALTER PROCEDURE SP_OBTENER_ULTIMOS_JUEGOS_JUGADOS
    @ID_PACIENTE INT
AS
BEGIN
    BEGIN TRY
        -- Verificar que el paciente exista y que tenga juegos jugados
        IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE ID_USUARIO = @ID_PACIENTE AND ID_TIPO_USUARIO = 1)
        BEGIN
            PRINT 'El paciente no existe o no es un paciente válido';
            RETURN;
        END

        -- Obtener los últimos 20 juegos jugados por el paciente con sus puntajes individuales
        SELECT TOP 20
            P.ID_PUNTAJE,  -- Identificador del puntaje
            P.ID_JUEGO,     -- Identificador del juego
            J.NOMBRE AS NOMBRE_JUEGO, -- Nombre del juego
            P.PUNTAJE,      -- Puntaje obtenido en ese intento
            P.FECHA_HORA    -- Fecha y hora del intento
        FROM PUNTAJE P
        INNER JOIN JUEGO J ON P.ID_JUEGO = J.ID_JUEGO
        WHERE P.ID_USUARIO = @ID_PACIENTE
        ORDER BY P.FECHA_HORA DESC; -- Ordenado por la fecha más reciente
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END;
