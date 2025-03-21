using Backend.Entidades;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace Backend.Logica.Usuario.Varios
{
    public static class Validaciones
    {
        public static List<Error> validarUsuario(ReqInsertarUsuario req)
        {
            List<Error> errores = new List<Error>();
            Error error = new Error();

            if (req == null)
            {
                error.idError = (int)CatalogoErrores.requestNull;
                error.error = "Request null";
                errores.Add(error);
            }
            else
            {
                if (String.IsNullOrEmpty(req.Nombre))
                {
                    error.idError = (int)CatalogoErrores.nombreNuloVacio;
                    error.error = "Falta el nombre del usuario";
                    errores.Add(error);
                }

                if (String.IsNullOrEmpty(req.CorreoElectronico))
                {
                    error.idError = (int)CatalogoErrores.correoNuloVacio;
                    error.error = "Falta el correo electronico del usuario";
                    errores.Add(error);
                }

                if (String.IsNullOrEmpty(req.Contrasena))
                {
                    error.idError = (int)CatalogoErrores.passwordNuloVacio;
                    error.error = "Falta la contraseña";
                    errores.Add(error);
                }
                else if (!EsCorreoValido(req.CorreoElectronico))
                {
                    error.idError = (int)CatalogoErrores.correoIncorrecto;
                    error.error = "Correo incorrecto";
                    errores.Add(error);

                }
                if (String.IsNullOrEmpty(req.Contrasena))
                {
                    error.idError = (int)CatalogoErrores.passwordFaltante;
                    error.error = "Contrasena vacio";
                    errores.Add(error);

                }
                else if (!EsPasswordSeguro(req.Contrasena))
                {
                    error.idError = (int)CatalogoErrores.passwordMuyDebil;
                    error.error = "Contrasena debil";
                    errores.Add(error);
                }
                else if (!EsFechaNacimientoValida(req.FechaNacimiento))
                {
                    error.idError = (int)CatalogoErrores.fechaInvalida;
                    error.error = "Fecha invalida";
                    errores.Add(error);

                }


            }
            return errores;
        }

        public static List<Error> validarLogin(ReqIniciarSesion req)
        {
            List<Error> errores = new List<Error>();
            Error error = new Error();

            if (req == null)
            {
                error.idError = (int)CatalogoErrores.requestNull;
                error.error = "Request null";
                errores.Add(error);
            }
            else
            {
                if (String.IsNullOrEmpty(req.CorreoElectronico))
                {
                    error.idError = (int)CatalogoErrores.correoNuloVacio;
                    error.error = "Falta el correo electronico del usuario";
                    errores.Add(error);
                }

                if (String.IsNullOrEmpty(req.Contrasena))
                {
                    error.idError = (int)CatalogoErrores.passwordNuloVacio;
                    error.error = "Falta la contraseña";
                    errores.Add(error);
                }
                else if (!EsCorreoValido(req.CorreoElectronico))
                {
                    error.idError = (int)CatalogoErrores.correoIncorrecto;
                    error.error = "Correo incorrecto o correo no valido";
                    errores.Add(error);

                }
            }
            return errores;
        }
        public static List<Error> validarConsSesion(ReqConsultarSesion req)
        {
            List<Error> errores = new List<Error>();
            Error error = new Error();

            if (req == null)
            {
                error.idError = (int)CatalogoErrores.requestNull;
                error.error = "Request null";
                errores.Add(error);
            }
            else
            {
                if (String.IsNullOrEmpty(req.tokem))
                {
                    error.idError = (int)CatalogoErrores.faltaTokem;
                    error.error = "Falta el tokem";
                    errores.Add(error);
                }



            }
            return errores;
        }
        public static List<Error> validarCerrarSesion(ReqCerrarSesion req)
        {
            List<Error> errores = new List<Error>();

            if (req == null)
            {
                errores.Add(new Error
                {
                    idError = (int)CatalogoErrores.requestNull,
                    error = "Request null"
                });
            }

            return errores;
        }
        public static List<Error> validarActualizarUsuario(ReqActualizarUsuario req)
        {
            List<Error> errores = new List<Error>();

            if (req == null)
            {
                errores.Add(new Error
                {
                    idError = (int)CatalogoErrores.requestNull,
                    error = "Request null"
                });
            }
            else
            {
                if (string.IsNullOrEmpty(req.Nombre))
                {
                    errores.Add(new Error
                    {
                        idError = (int)CatalogoErrores.nombreNuloVacio,
                        error = "Falta el nombre del usuario"
                    });
                }

                // ✅ Primero, verificar si la fecha está vacía (default DateTime es 01/01/0001)
                if (req.FechaNacimiento == default(DateTime))
                {
                    errores.Add(new Error
                    {
                        idError = (int)CatalogoErrores.fechaVacia,
                        error = "Falta la fecha de nacimiento"
                    });
                }
                // ✅ Luego, verificar si la fecha es inválida según la función helper
                else if (!EsFechaNacimientoValida(req.FechaNacimiento))
                {
                    errores.Add(new Error
                    {
                        idError = (int)CatalogoErrores.fechaInvalida,
                        error = "Fecha de nacimiento inválida"
                    });
                }

                if (string.IsNullOrEmpty(req.Direccion))
                {
                    errores.Add(new Error
                    {
                        idError = (int)CatalogoErrores.direccionVacia,
                        error = "Falta asignar dirección"
                    });
                }
            }

            return errores;
        }
        public static List<Error> validarActualizarContrasena(ReqActualizarContrasena req)
        {
            List<Error> errores = new List<Error>();

            if (req == null)
            {
                errores.Add(new Error
                {
                    idError = (int)CatalogoErrores.requestNull,
                    error = "Request null"
                });
            }
            else
            {
                if (string.IsNullOrEmpty(req.ContrasenaActual))
                {
                    errores.Add(new Error
                    {
                        idError = (int)CatalogoErrores.contrasenaActualVacia,
                        error = "La contraseña actual no puede estar vacía"
                    });
                }

                if (string.IsNullOrEmpty(req.NuevaContrasena))
                {
                    errores.Add(new Error
                    {
                        idError = (int)CatalogoErrores.nuevaContrasenaVacia,
                        error = "La nueva contraseña no puede estar vacía"
                    });
                }
                else if (!EsPasswordSeguro(req.NuevaContrasena)) // ✅ Validación de contraseña segura
                {
                    errores.Add(new Error
                    {
                        idError = (int)CatalogoErrores.passwordMuyDebil,
                        error = "La nueva contraseña es demasiado débil"
                    });
                }
            }

            return errores;
        }
        public static List<Error> validarInsertarRelacion(ReqInsertarRelacion req)
        {
            List<Error> errores = new List<Error>();

            if (req == null)
            {
                errores.Add(new Error
                {
                    idError = (int)CatalogoErrores.requestNull,
                    error = "Request null"
                });
            }
            else if (string.IsNullOrEmpty(req.CodigoPaciente))
            {
                errores.Add(new Error
                {
                    idError = (int)CatalogoErrores.codigoPacienteInvalido,
                    error = "El código del paciente no puede estar vacío"
                });
            }

            return errores;
        }

        public static List<Error> validarObtenerRelacion(ReqObtenerRelacion req)
        {
            List<Error> errores = new List<Error>();

            if (req == null)
            {
                errores.Add(new Error
                {
                    idError = (int)CatalogoErrores.requestNull,
                    error = "Request null"
                });
            }

            return errores;
        }

        public static List<Error> validarEliminarRelacion(ReqEliminarRelacion req)
        {
            List<Error> errores = new List<Error>();

            if (req == null)
            {
                errores.Add(new Error
                {
                    idError = (int)CatalogoErrores.requestNull,
                    error = "Request null"
                });
            }

            return errores;
        }







        public static bool EsCorreoValido(string correo)
        {
            // Verifica que el correo no sea nulo o vacío.
            if (string.IsNullOrWhiteSpace(correo))
                return false;

            // Patrón simple para validar correo electrónico.
            string patron = @"^[^@\s]+@[^@\s]+\.[^@\s]+$";

            return Regex.IsMatch(correo, patron);
        }

        public static bool EsPasswordSeguro(string password)
        {
            // Verifica que el password no sea nulo o vacío.
            if (string.IsNullOrWhiteSpace(password))
                return false;

            // Patrón que valida el password según los criterios mencionados.
            string patron = @"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$";

            return Regex.IsMatch(password, patron);
        }

        public static bool EsFechaNacimientoValida(DateTime fechaNacimiento)
        {
            // La fecha no puede ser en el futuro ni anterior al año 1900
            return fechaNacimiento <= DateTime.Now && fechaNacimiento.Year >= 1900;
        }
    }
}