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



----------------------------------------------------------------------------------------------------------
--Manejo de sesion, se pretende solo manejar 1 sesion por dispositivo
CREATE TABLE SESION (
    ID_SESION INT IDENTITY(1,1) NOT NULL,
    TOKEN NVARCHAR(255) NOT NULL, -- Identificador de la sesión (JWT, GUID, etc.)
    ID_USUARIO INT NOT NULL,
    DISPOSITIVO NVARCHAR(255) NOT NULL, -- Identificador del dispositivo (User-Agent, UUID, etc.)
    IP_ORIGEN NVARCHAR(45) NOT NULL, -- Dirección IP del usuario
    FECHA_INICIO DATETIME NOT NULL DEFAULT GETDATE(), -- Inicio de sesión
    FECHA_EXPIRACION DATETIME NOT NULL, -- Expiración de la sesión
    ESTADO BIT NOT NULL DEFAULT 1, -- 1=Activa, 0=Expirada/Cerrada
    CONSTRAINT PK_SESION PRIMARY KEY (ID_SESION),
    CONSTRAINT FK_SESION_USUARIO FOREIGN KEY (ID_USUARIO) REFERENCES USUARIO(ID_USUARIO)
);
GO


ALTER TABLE USUARIO ADD ID_SESION_ACTUAL INT NULL;
ALTER TABLE USUARIO ADD CONSTRAINT FK_USUARIO_SESION FOREIGN KEY (ID_SESION_ACTUAL) REFERENCES SESION(ID_SESION);
GO


--Para asegurarnos de que un usuario solo tenga una sesión activa por dispositivo, agregamos una restricción UNIQUe
ALTER TABLE SESION ADD CONSTRAINT UQ_SESION_USUARIO_DISPOSITIVO UNIQUE (ID_USUARIO, DISPOSITIVO);
GO



--sp para manejo de sesion en el login...
CREATE PROCEDURE [dbo].[sp_Login]
    @CORREO_ELECTRONICO NVARCHAR(50),
    @PASSWORD NVARCHAR(MAX),
    @DISPOSITIVO NVARCHAR(255), -- Identificador del dispositivo
    @IP_ORIGEN NVARCHAR(45) -- Dirección IP
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ID_USUARIO INT;
    DECLARE @TOKEN NVARCHAR(255);
    DECLARE @FECHA_EXPIRACION DATETIME;
    DECLARE @ID_SESION INT;

    -- 1️⃣ Validar credenciales del usuario
    SELECT @ID_USUARIO = ID_USUARIO
    FROM USUARIO
    WHERE CORREO_ELECTRONICO = @CORREO_ELECTRONICO AND CONTRASENA = @PASSWORD;

    -- Si el usuario no existe, salir
    IF @ID_USUARIO IS NULL
    BEGIN
        PRINT 'Credenciales incorrectas';
        RETURN;
    END

    -- 2️ Cerrar sesiones activas en otros dispositivos
    UPDATE SESION
    SET ESTADO = 0, FECHA_EXPIRACION = GETDATE()
    WHERE ID_USUARIO = @ID_USUARIO AND DISPOSITIVO <> @DISPOSITIVO AND ESTADO = 1;

    -- 3️ Generar un nuevo token
    SET @TOKEN = NEWID(); -- Si usas JWT, cámbialo por tu lógica
    SET @FECHA_EXPIRACION = DATEADD(MINUTE, 30, GETDATE()); -- Sesión expira en 30 min

    -- 4️ Cerrar sesión en el mismo dispositivo (si existe)
    UPDATE SESION
    SET ESTADO = 0, FECHA_EXPIRACION = GETDATE()
    WHERE ID_USUARIO = @ID_USUARIO AND DISPOSITIVO = @DISPOSITIVO AND ESTADO = 1;

    -- 5️ Insertar nueva sesión
    INSERT INTO SESION (TOKEN, ID_USUARIO, DISPOSITIVO, IP_ORIGEN, FECHA_INICIO, FECHA_EXPIRACION, ESTADO)
    VALUES (@TOKEN, @ID_USUARIO, @DISPOSITIVO, @IP_ORIGEN, GETDATE(), @FECHA_EXPIRACION, 1);

    -- Obtener el ID de la sesión recién creada
    SET @ID_SESION = SCOPE_IDENTITY();

    -- 6️ Actualizar la sesión actual del usuario en USUARIO (opcional)
    UPDATE USUARIO SET ID_SESION_ACTUAL = @ID_SESION WHERE ID_USUARIO = @ID_USUARIO;

    -- 7️Devolver los datos del usuario y la sesión
    SELECT 
        U.ID_USUARIO,
        U.NOMBRE,
        U.CORREO_ELECTRONICO,
        @TOKEN AS TOKEN_SESION,
        @FECHA_EXPIRACION AS EXPIRACION
    FROM USUARIO U
    WHERE U.ID_USUARIO = @ID_USUARIO;
END;
GO
