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
