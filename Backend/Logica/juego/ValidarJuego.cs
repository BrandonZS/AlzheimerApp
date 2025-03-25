using Backend.Entidades;
using Backend.Entidades.Entity;
using Backend.Entidades.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Backend.Logica.Juego
{
    public static class ValidarJuego
    {
        public static List<Error> validarJuego(ReqInsertarJuego req)
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
                if (String.IsNullOrEmpty(req.nombre))
                {
                    //Cambiar nombre de los errores   <<<--------------
                    error.idError = (int)ErroresBrandon.nombreJuegoNuloVacio;
                    error.error = "Falta el nombre del usuario";
                    errores.Add(error);
                }

                if (req.idUsuario < 1 )
                {
                    //Cambiar nombre de los errores  <<<--------------
                    error.idError = (int)ErroresBrandon.usuarioInvalido;
                    error.error = "Falta el correo electronico del usuario";
                    errores.Add(error);
                }

            }
            return errores;
        }

        public static List<Error> validarPregunta(Pregunta pregunta, int idJuego)
        {
            List<Error> errores = new List<Error>();
            Error error = new Error();

            if (pregunta == null)
            {
                error.idError = (int)CatalogoErrores.requestNull;
                error.error = "Request null";
                errores.Add(error);
            }
            else
            {
                if (String.IsNullOrEmpty(pregunta.Descripcion))
                {
                    //Cambiar nombre de los errores   <<<--------------
                    error.idError = (int)ErroresBrandon.descripcionNuloVacia;
                    error.error = "Falta la Descripcion";
                    errores.Add(error);
                }
                if(idJuego < 1)
                {
                    //Cambiar nombre de los errores   <<<--------------
                    error.idError = (int)ErroresBrandon.juegoNoValido;
                    error.error = "Juego no valido";
                    errores.Add(error);
                }

            }
            bool opcionCorrecta = false;

            foreach (Opcion opcion in pregunta.opciones)
            {
                if (opcion == null)
                {
                    //Cambiar nombre de los errores   <<<--------------
                    error.idError = (int)ErroresBrandon.opcionNula;
                    error.error = "Opcion Nula";
                    errores.Add(error);
                }
                else
                {
                    if (String.IsNullOrEmpty(opcion.Descripcion))
                    {
                        //Cambiar nombre de los errores   <<<--------------
                        error.idError = (int)ErroresBrandon.descripcionNuloVacia;
                        error.error = "Falta la Descripcion";
                        errores.Add(error);
                    }
                    if (opcionCorrecta && opcion.Condicion)
                    {
                        //Cambiar nombre de los errores   <<<--------------
                        error.idError = (int)ErroresBrandon.yaExisteOpcionCorrecta;
                        error.error = "Ya se asigno una opcion correcta";
                        errores.Add(error);
                    }
                    if (opcion.Condicion)
                    {
                        opcionCorrecta = true;
                    }


                }
            }
            if (!opcionCorrecta)
            {
                //Cambiar nombre de los errores   <<<--------------
                error.idError = (int)ErroresBrandon.noIngresoOpcionCorrecta;
                error.error = "No se asigno ninguna opcion correcta";
                errores.Add(error);
            }
            return errores;
        }

        public static List<Error> validarRelacion(ReqInsertarRelacionJuego req)
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
                if(req.idPaciente < 1 )
                {
                    error.idError = (int)ErroresBrandon.usuarioInvalido;
                    error.error = "Usuario Paciente NO valido";
                    errores.Add(error);
                }
                if(req.idUsuario < 1)
                {
                    error.idError = (int)ErroresBrandon.usuarioInvalido;
                    error.error = "Usuario Cuidador NO valido";
                    errores.Add(error);
                }
                if(req.idJuego < 1)
                {
                    error.idError = (int)ErroresBrandon.juegoNoValido;
                    error.error = "Juego NO valido";
                    errores.Add(error);
                }
            }

                return errores;
        }

        public static List<Error> validarUsuario(int id)
        {
            List<Error> errores = new List<Error>();
            Error error = new Error();

            if (id < 1)
            {
                error.idError = (int)ErroresBrandon.usuarioInvalido;
                error.error = "Usuario NO valido";
                errores.Add(error);
            }

            return errores;
        }

        public static List<Error> validarJuego(int id)
        {
            List<Error> errores = new List<Error>();
            Error error = new Error();

            if (id < 1)
            {
                error.idError = (int)ErroresBrandon.juegoNoValido;
                error.error = "Juego NO valido";
                errores.Add(error);
            }

            return errores;
        }
    }
}
