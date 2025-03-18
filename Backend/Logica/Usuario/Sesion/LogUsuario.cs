using Backend.Entidades;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using Backend.Logica;

namespace Backend.Logica
{
    public class LogUsuario
    {
        public ResInsertarUsuario Insertar(ReqInsertarUsuario req, Helpers helpers)
        {
            ResInsertarUsuario res = new ResInsertarUsuario();
            res.error = new List<Error>();
            Error error = new Error();


            try
            {
                #region validaciones

                if (req == null) //Esto nunca va ocurrir.
                {
                    error.ErrorCode = (int)enumErrores.requestNulo;
                    error.Message = "Req null";
                    res.error.Add(error);
                }
                else
                {
                    if (String.IsNullOrEmpty(req.usuario.Nombre))
                    {
                        error.ErrorCode = (int)enumErrores.nombreFaltante;
                        error.Message = "Nombre vacio";
                        res.error.Add(error);
                    }
                   
                    if (String.IsNullOrEmpty(req.usuario.CorreoElectronico))
                    {
                        error.ErrorCode = (int)enumErrores.correoFaltante;
                        error.Message = "Correo no valido vacio";
                        res.error.Add(error);
                    }
                    else if (!this.EsCorreoValido(req.usuario.CorreoElectronico))
                    {
                        error.ErrorCode = (int)enumErrores.correoIncorrecto;
                        error.Message = "Correo incorrecto";
                        res.error.Add(error);
                    }
                    if (String.IsNullOrEmpty(req.usuario.Contrasena))
                    {
                        error.ErrorCode = (int)enumErrores.passwordFaltante;
                        error.Message = "Contrasena vacio";
                        res.error.Add(error);
                    }
                    else if (!this.EsPasswordSeguro(req.usuario.Contrasena))
                    {
                        error.ErrorCode = (int)enumErrores.passwordMuyDebil;
                        error.Message = "Contrasena debil";
                        res.error.Add(error);
                    }
                    else if (!this.EsFechaNacimientoValida(req.usuario.FechaNacimiento))
                    {
                        error.ErrorCode = (int)enumErrores.fechaInvalida;
                        error.Message = "Fecha invalida";
                        res.error.Add(error);
                    }
                    #endregion
                    if (res.error.Any())
                    {
                        //Hay al menos un error
                        res.resultado = false;
                    }
                    else
                    {


                        //CERO errores ¡Todo bien!
                        int? idBD = 0;
                        int? errorIdBD = 0;
                        string errorMsgBD = "";
                        using (conexionLinqDataContext linq = new conexionLinqDataContext())
                        {
                            linq.SP_INGRESAR_USUARIO(req.usuario.nombre, req.usuario.apellidos, req.usuario.correoElectronico, req.usuario.password, this.GenerarPin(5), ref idBD, ref errorIdBD, ref errorMsgBD);
                        }

                        if (idBD >= 1)
                        {
                            //TODO BIEN 100%%
                            res.resultado = true;
                        }
                        else
                        {
                            error.ErrorCode = (int)enumErrores.excepcionBaseDatos;
                            error.Message = errorMsgBD; //MALISIMA PRACTICA
                            res.error.Add(error);
                        }

                    }
                }
            }
            catch (Exception ex)
            {
                res.resultado = false;
                error.ErrorCode = (int)enumErrores.excepcionLogica;
                error.Message = ex.Message;
            }

            return res;
        }


        public bool EsCorreoValido(string correo)
        {
            // Verifica que el correo no sea nulo o vacío.
            if (string.IsNullOrWhiteSpace(correo))
                return false;

            // Patrón simple para validar correo electrónico.
            string patron = @"^[^@\s]+@[^@\s]+\.[^@\s]+$";

            return Regex.IsMatch(correo, patron);
        }

        public bool EsPasswordSeguro(string password)
        {
            // Verifica que el password no sea nulo o vacío.
            if (string.IsNullOrWhiteSpace(password))
                return false;

            // Patrón que valida el password según los criterios mencionados.
            string patron = @"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$";

            return Regex.IsMatch(password, patron);
        }

        public bool EsFechaNacimientoValida(DateTime fechaNacimiento)
        {
            // La fecha no puede ser en el futuro ni anterior al año 1900
            return fechaNacimiento <= DateTime.Now && fechaNacimiento.Year >= 1900;
        }

    }
}
