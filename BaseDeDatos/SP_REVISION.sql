
CREATE OR ALTER PROCEDURE SP_AGREGAR_EVENTO
    @ID_CUIDADOR INT,
    @TITULO VARCHAR(255),
    @DESCRIPCION VARCHAR(255) = NULL,
    @FECHA_HORA DATETIME,
    @ID_PRIORIDAD INT,
    @ID_PACIENTE INT,
    @ID_RETURN INT OUTPUT,
    @ERROR_ID INT OUTPUT,
    @ERROR_DESCRIPTION NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el cuidador existe, que el paciente está relacionado y que la prioridad es válida
        IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE ID_USUARIO = @ID_CUIDADOR AND ID_TIPO_USUARIO = 2)
        BEGIN
            SET @ID_RETURN = -1;
            SET @ERROR_ID = 1;
            SET @ERROR_DESCRIPTION = 'El usuario no es un cuidador o no existe';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM CUIDADOR_PACIENTE WHERE ID_USUARIO_CUIDADOR = @ID_CUIDADOR AND ID_USUARIO_PACIENTE = @ID_PACIENTE)
        BEGIN
            SET @ID_RETURN = -1;
            SET @ERROR_ID = 2;
            SET @ERROR_DESCRIPTION = 'El paciente no está asignado a este cuidador';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar que la prioridad sea válida (1: Baja, 2: Media, 3: Alta)
        IF @ID_PRIORIDAD NOT IN (1, 2, 3)
        BEGIN
            SET @ID_RETURN = -1;
            SET @ERROR_ID = 3;
            SET @ERROR_DESCRIPTION = 'La prioridad seleccionada no es válida';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Insertar evento y obtener ID
        INSERT INTO EVENTO (TITULO, DESCRIPCION, FECHA_HORA, ID_PRIORIDAD, ID_USUARIO)
        VALUES (@TITULO, @DESCRIPCION, @FECHA_HORA, @ID_PRIORIDAD, @ID_CUIDADOR);
        
        SET @ID_RETURN = SCOPE_IDENTITY();

        -- Relacionar evento con el paciente
        INSERT INTO EVENTO_USUARIO (ID_EVENTO, ID_USUARIO, ID_ESTADO)
        VALUES (@ID_RETURN, @ID_PACIENTE, 1);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @ID_RETURN = -1;
        SET @ERROR_ID = ERROR_NUMBER();
        SET @ERROR_DESCRIPTION = ERROR_MESSAGE();
    END CATCH
END;
