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

        //Validaciones para Ping

        public static List<Error> validarInsertarPing(ReqInsertarPing req)
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
                if (string.IsNullOrWhiteSpace(req.Codigo))
                {
                    errores.Add(new Error
                    {
                        idError = (int)CatalogoErrores.pingVacio,
                        error = "Ping es obligatorio"
                    });
                }
                else if (req.Codigo.Length != 6)
                {
                    errores.Add(new Error
                    {
                        idError = (int)CatalogoErrores.pingInsuficiente,
                        error = "El Ping debe tener exactamente 6 dígitos"
                    });
                }
                else if (!Regex.IsMatch(req.Codigo, @"^\d{6}$"))
                {
                    errores.Add(new Error
                    {
                        idError = (int)CatalogoErrores.pingSoloNumeros,
                        error = "El Ping debe contener solo números"
                    });
                }
            }

            return errores;
        }

        public static List<Error> validarActualizarPing(ReqActualizarPing req)
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
                if (string.IsNullOrWhiteSpace(req.PinActual))
                {
                    errores.Add(new Error
                    {
                        idError = (int)CatalogoErrores.pingActualOblicatorio,
                        error = "PIN actual es obligatorio"
                    });
                }

                if (string.IsNullOrWhiteSpace(req.NuevoCodigo))
                {
                    errores.Add(new Error
                    {
                        idError = (int)CatalogoErrores.nuevoPingVacio,
                        error = "Nuevo PIN es obligatorio"
                    });
                }
                else if (req.NuevoCodigo.Length != 6 || !Regex.IsMatch(req.NuevoCodigo, @"^\d{6}$"))
                {
                    errores.Add(new Error
                    {
                        idError = (int)CatalogoErrores.pingSoloNumeros,
                        error = "El nuevo PIN debe ser numérico de 6 dígitos"
                    });
                }
            }

            return errores;
        }

        public static List<Error> validarEliminarPing(ReqEliminarPing req)
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
                if (string.IsNullOrWhiteSpace(req.Codigo))
                {
                    errores.Add(new Error
                    {
                        idError = (int)CatalogoErrores.pingActualOblicatorio,
                        error = "PIN es obligatorio"
                    });
                }
                else if (req.Codigo.Length != 6 || !Regex.IsMatch(req.Codigo, @"^\d{6}$"))
                {
                    errores.Add(new Error
                    {
                        idError = (int)CatalogoErrores.pingSoloNumeros,
                        error = "El PIN debe ser numérico de 6 dígitos"
                    });
                }
            }

            return errores;
        }

        //Validaciones para Mensaje

        public static List<Error> validarInsertarMensaje(ReqInsertarMensaje req)
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
                if (string.IsNullOrWhiteSpace(req.Contenido))
                {
                    errores.Add(new Error
                    {
                        idError = (int)CatalogoErrores.mensajeVacio,
                        error = "El mensaje no puede estar vacío"
                    });
                }
            }

            return errores;
        }

        public static List<Error> validarObtenerMensajes(ReqObtenerMensajes req)
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

        public static List<Error> validarActualizarMensaje(ReqActualizarMensaje req)
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

        //Validacione Para Evento
        public static List<Error> validarInsertarEvento(ReqInsertarEvento req)
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
                if (string.IsNullOrWhiteSpace(req.Titulo))
                {
                    errores.Add(new Error
                    {
                        idError = (int)CatalogoErrores.tituloVacio,
                        error = "El título del evento es obligatorio"
                    });
                }

                if (req.FechaHora == default(DateTime))
                {
                    errores.Add(new Error
                    {
                        idError = (int)CatalogoErrores.fechaVacia,
                        error = "La fecha del evento es obligatoria"
                    });
                }

                if (req.IdPrioridad <= 0)
                {
                    errores.Add(new Error
                    {
                        idError = (int)CatalogoErrores.prioridadInvalida,
                        error = "La prioridad debe ser válida"
                    });
                }
            }

            return errores;
        }

        public static List<Error> validarActualizarEvento(ReqActualizarEvento req)
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
                if (string.IsNullOrWhiteSpace(req.Titulo))
                {
                    errores.Add(new Error
                    {
                        idError = (int)CatalogoErrores.tituloVacio,
                        error = "El título del evento es obligatorio"
                    });
                }

                if (req.FechaHora < DateTime.Now)
                {
                    errores.Add(new Error
                    {
                        idError = (int)CatalogoErrores.fechaInvalida,
                        error = "La fecha del evento debe ser futura"
                    });
                }

                if (req.IdPrioridad <= 0)
                {
                    errores.Add(new Error
                    {
                        idError = (int)CatalogoErrores.prioridadInvalida,
                        error = "ID de prioridad inválido"
                    });
                }
            }

            return errores;
        }

        public static List<Error> validarEliminarEvento(ReqEliminarEvento req)
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

        public static List<Error> validarInsertarPacienteEvento(ReqInsertarPacienteEvento req)
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
                if (req.IdEvento <= 0)
                {
                    errores.Add(new Error
                    {
                        idError = (int)CatalogoErrores.idEventoInvalido,
                        error = "ID del evento inválido"
                    });
                }

                if (req.IdCuidador <= 0)
                {
                    errores.Add(new Error
                    {
                        idError = (int)CatalogoErrores.idCuidadorInvalido,
                        error = "ID del cuidador inválido"
                    });
                }

                if (req.IdPaciente <= 0)
                {
                    errores.Add(new Error
                    {
                        idError = (int)CatalogoErrores.idPacienteInvalido,
                        error = "ID del paciente inválido"
                    });
                }
            }

            return errores;
        }

        public static List<Error> validarEliminarPacienteEvento(ReqEliminarPacienteEvento req)
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

        public static List<Error> validarObtenerEventosPaciente(ReqObtenerEventosPaciente req)
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
        public static List<Error> validarObtenerEventosCuidador(ReqObtenerEventosCuidador req)
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