using AccesoDatos;
using Backend.Entidades;
using Backend.Logica.Usuario.Varios;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Backend.Logica
{
  public  class LogMensaje
    {
        //Metodos para Mensaje
        public ResInsertarMensaje insertarMensaje(ReqInsertarMensaje req)
        {
            ResInsertarMensaje res = new ResInsertarMensaje();
            res.listaDeErrores = new List<Error>();

            try
            {
                // Validar datos del request
                res.listaDeErrores = Validaciones.validarInsertarMensaje(req);

                if (!res.listaDeErrores.Any())
                {
                    int? idReturn = 0;
                    int? errorId = 0;
                    string errorCode = "";
                    string errorDescrip = "";

                    using (MiLinqDataContext linq = new MiLinqDataContext())
                    {
                        linq.SP_INSERTAR_MENSAJE(req.IdCuidador, req.IdPaciente, req.Contenido, ref idReturn, ref errorId, ref errorCode, ref errorDescrip);
                    }

                    if (idReturn > 0)
                    {
                        res.resultado = true;
                    }
                    else
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
                res.listaDeErrores.Add(new Error
                {
                    idError = -1,
                    error = ex.Message
                });
            }

            return res;
        }

        public ResObtenerMensajes obtenerMensajes(ReqObtenerMensajes req)
        {
            ResObtenerMensajes res = new ResObtenerMensajes();
            res.listaDeErrores = new List<Error>();
            res.listaMensajes = new List<Mensaje>();

            try
            {
                res.listaDeErrores = Validaciones.validarObtenerMensajes(req);

                if (!res.listaDeErrores.Any())
                {
                    int? errorId = 0;
                    string errorCode = "";
                    string errorDescrip = "";

                    using (MiLinqDataContext linq = new MiLinqDataContext())
                    {
                        var resultado = linq.SP_OBTENER_MENSAJES(req.IdPaciente, ref errorId, ref errorCode, ref errorDescrip).ToList();

                        if (resultado != null && resultado.Any())
                        {
                            res.listaMensajes = factoryListaMensajes(resultado, req.IdPaciente);
                        }
                    }

                    res.resultado = errorId == null || errorId == 0;
                    if (!res.resultado)
                    {
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
                res.listaDeErrores.Add(new Error
                {
                    idError = -1,
                    error = ex.Message
                });
            }

            return res;
        }

        public ResActualizarMensaje actualizarEstadoMensaje(ReqActualizarMensaje req)
        {
            ResActualizarMensaje res = new ResActualizarMensaje();
            res.listaDeErrores = new List<Error>();

            try
            {
                // Validar los datos de entrada
                res.listaDeErrores = Validaciones.validarActualizarMensaje(req);

                if (!res.listaDeErrores.Any())
                {
                    int? errorId = 0;
                    string errorCode = "";
                    string errorDescrip = "";

                    using (MiLinqDataContext linq = new MiLinqDataContext())
                    {
                        linq.SP_ACTUALIZAR_ESTADO_MENSAJES(req.IdPaciente, req.IdMensaje, ref errorId, ref errorCode, ref errorDescrip);
                    }

                    if (errorId == null || errorId == 0)
                    {
                        res.resultado = true;
                    }
                    else
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
                res.listaDeErrores.Add(new Error
                {
                    idError = -1,
                    error = ex.Message
                });
            }

            return res;
        }


        private List<Mensaje> factoryListaMensajes(List<SP_OBTENER_MENSAJESResult> resultado, int idPaciente)
        {
            List<Mensaje> mensajes = new List<Mensaje>();

            foreach (var m in resultado)
            {
                mensajes.Add(new Mensaje
                {
                    IdMensaje = m.ID_MENSAJE,
                    Contenido = m.CONTENIDO,
                    FechaEnviado = (DateTime)m.FECHA_ENVIADO,
                    FechaRecibido = null, // No viene del SP
                    IdUsuarioCuidador = m.ID_CUIDADOR,
                    IdUsuarioPaciente = idPaciente,
                    IdEstado = m.ID_ESTADO
                });
            }

            return mensajes;
        }
    }
}
