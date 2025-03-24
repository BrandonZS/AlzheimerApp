using AccesoDatos;
using Backend.Entidades;
using Backend.Entidades.Entity;
using Backend.Logica.Usuario.Varios;
using System;
using System.Collections.Generic;
using System.Data.Linq;
using System.Diagnostics.Eventing.Reader;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Backend.Logica.Juego
{
    public class LogJuego
    {
        public ResInsertarJuego insertarJuego(ReqInsertarJuego req)
        {

            ResInsertarJuego res = new ResInsertarJuego();
            res.listaDeErrores = new List<Error>();

            try
            {
                res.listaDeErrores = ValidarJuego.validarJuego(req);

                if (!res.listaDeErrores.Any())
                {
                    //CERO errores ¡Todo bien!
                    int? idReturn = 0;
                    int? errorId = 0;
                    string errorCode = "";
                    string errorDescrip = "";
                    using (MiLinqDataContext linq = new MiLinqDataContext())
                    {
                        linq.SP_INSERTAR_JUEGO(req.idUsuario, req.nombre, ref idReturn, ref errorId, ref errorCode, ref errorDescrip);
                    }
                    if (idReturn > 0) // Si el ID devuelto es mayor que 0, el usuario se insertó correctamente
                    {
                        res.resultado = true;
                    }
                    else // Si no se insertó, manejar el error devuelto por el SP
                    {
                        res.resultado = false;
                        res.listaDeErrores.Add(new Error
                        {
                            idError = (int)errorId,
                            error = errorCode
                        });
                    }
                }
            }
            catch (Exception ex)
            {
                res.resultado = false;
                Error error = new Error();
                error.idError = -1;
                error.error = ex.Message;
                res.listaDeErrores.Add(error);
            }
            return res;
        }

        public List<ResInsertarPregunta> insertarPregunta(ReqInsertarPregunta req)
        {

            List<ResInsertarPregunta> res = new List<ResInsertarPregunta>();

            bool ErrorPreg = false;
            int numPregunta = 1;
            ResInsertarPregunta resPregunta = new ResInsertarPregunta();
            ResBase resBase = new ResBase();
            try
            {
                foreach (Pregunta preg in req.preguntas)
                {
                    resPregunta = new ResInsertarPregunta();
                    resBase = new ResBase();

                    resBase.listaDeErrores = new List<Error>();
                    resBase.listaDeErrores = ValidarJuego.validarPregunta(preg, req.idJuego);

                    if (!resBase.listaDeErrores.Any())
                    {
                        //CERO errores ¡Todo bien!
                        int? idReturn = 0;
                        int? errorId = 0;
                        string errorCode = "";
                        string errorDescrip = "";
                        using (MiLinqDataContext linq = new MiLinqDataContext())
                        {
                            linq.SP_INSERTAR_PREGUNTA(req.idJuego, preg.Titulo, preg.Descripcion, preg.Imagen, req.idUsuario, ref idReturn, ref errorId, ref errorCode, ref errorDescrip);
                            int? idPregunta = idReturn;

                            if (idReturn > 0)
                            {
                                resBase.resultado = true;
                                foreach (Opcion opcion in preg.opciones)
                                {
                                    int? idReturnOpcion = 0;
                                    int? errorIdOpcion = 0;
                                    string errorCodeOpcion = "";
                                    string errorDescripOpcion = "";
                                    linq.SP_INSERTAR_OPCION(idPregunta, req.idUsuario, opcion.Descripcion, opcion.Condicion, ref idReturnOpcion, ref errorIdOpcion, ref errorCodeOpcion, ref errorDescripOpcion);

                                    if (idReturnOpcion < 1)
                                    {
                                        resBase.resultado = false;
                                        resBase.listaDeErrores.Add(new Error
                                        {
                                            idError = (int)errorIdOpcion,
                                            error = errorCodeOpcion
                                        });
                                    }

                                }
                            }
                            else
                            {

                                resBase.resultado = false;
                                resBase.listaDeErrores.Add(new Error
                                {
                                    idError = (int)errorId,
                                    error = errorCode
                                });

                            }
                        }
                        resPregunta.numPregunta = numPregunta;
                        numPregunta++;

                        resPregunta.ResBase = resBase;

                        
                    }
                    else
                    {
                        resBase.resultado = false;
                        resPregunta.numPregunta = numPregunta;
                        numPregunta++;
                        resPregunta.ResBase = resBase;
                    }
                    res.Add(resPregunta);

                }

            }
            catch (Exception ex)
            {
                Error error = new Error();
                error.idError = -1;
                error.error = ex.Message;
                resBase.resultado = false;
                resBase.listaDeErrores.Add(error);
                resPregunta.numPregunta = numPregunta;
                resPregunta.ResBase = resBase;
                res.Add(resPregunta);
            }
            return res;
        }

        public ResInsertarRelacionJuego insertarRelacionJuego(ReqInsertarRelacionJuego req)
        {

            ResInsertarRelacionJuego res = new ResInsertarRelacionJuego();
            res.listaDeErrores = new List<Error>();

            try
            {
                res.listaDeErrores = ValidarJuego.validarRelacion(req);

                if (!res.listaDeErrores.Any())
                {
                    int? idReturn = 0;
                    int? errorId = 0;
                    string errorCode = "";
                    string errorDescrip = "";
                    using (MiLinqDataContext linq = new MiLinqDataContext())
                    {
                        linq.SP_INSERTAR_PACIENTE_JUEGO(req.idJuego, req.idUsuario, req.idPaciente, ref idReturn, ref errorId, ref errorCode , ref errorDescrip);
                    }
                    if (errorId == null) // Si el ID devuelto es mayor que 0, el usuario se insertó correctamente
                    {
                        res.resultado = true;
                    }
                    else // Si no se insertó, manejar el error devuelto por el SP
                    {
                        res.resultado = false;
                        res.listaDeErrores.Add(new Error
                        {
                            idError = (int)errorId,
                            error = errorCode
                        });
                    }
                }
            }
            catch (Exception ex)
            {
                res.resultado = false;
                Error error = new Error();
                error.idError = -1;
                error.error = ex.Message;
                res.listaDeErrores.Add(error);
            }
            return res;
        }

        public ResObtenerJuegosCuidador obtenerJuegosCuidador(ReqObtenerJuegosCuidador req)
        {

            ResObtenerJuegosCuidador res = new ResObtenerJuegosCuidador();
            res.listaDeErrores = new List<Error>();

            try
            {
                res.listaDeErrores = ValidarJuego.validarUsuario(req.idCuidador);

                if (!res.listaDeErrores.Any())
                {
                    int? idReturn = 0;
                    int? errorId = 0;
                    string errorCode = "";
                    string errorDescrip = "";
                    using (MiLinqDataContext linq = new MiLinqDataContext())
                    {
                        linq.SP_OBTENER_JUEGOS_CREADOS(req.idCuidador, ref errorId, ref errorCode, ref errorDescrip);
                    }
                    if (errorId == null) // Si el ID devuelto es mayor que 0, el usuario se insertó correctamente
                    {
                        res.resultado = true;
                    }
                    else // Si no se insertó, manejar el error devuelto por el SP
                    {
                        res.resultado = false;
                        res.listaDeErrores.Add(new Error
                        {
                            idError = (int)errorId,
                            error = errorCode
                        });
                    }
                }
            }
            catch (Exception ex)
            {
                res.resultado = false;
                Error error = new Error();
                error.idError = -1;
                error.error = ex.Message;
                res.listaDeErrores.Add(error);
            }
            return res;
        }
    }
}
