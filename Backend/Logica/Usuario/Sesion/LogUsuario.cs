using Backend.Entidades;
using Backend.Logica.Usuario.Varios;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using AccesoDatos;
using Backend.Entidades.Entity;
using static System.Collections.Specialized.BitVector32;

namespace Backend.Logica
{
   public class LogUsuario
    {
        public ResInsertarUsuario insertarUsuario(ReqInsertarUsuario req)
        {

            ResInsertarUsuario res = new ResInsertarUsuario();
            res.listaDeErrores = new List<Error>();

            try
            {
                res.listaDeErrores = Validaciones.validarUsuario(req);

                if (!res.listaDeErrores.Any())
                {
                    //CERO errores ¡Todo bien!
                    int? idReturn = 0;
                    int? errorId = 0;
                    string errorCode = "";
                    string errorDescrip = "";
                    using (MiLinqDataContext linq = new MiLinqDataContext())
                    {
                        linq.SP_INSERTAR_USUARIO(req.Nombre, req.CorreoElectronico, req.Contrasena, req.FechaNacimiento, req.FotoPerfil, req.Direccion, req.IdTipoUsuario, ref idReturn, ref errorId, ref errorCode, ref errorDescrip);
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
        public ResIniciarSesion iniciarSesion(ReqIniciarSesion req)
        {

            ResIniciarSesion res = new ResIniciarSesion();
            res.listaDeErrores = new List<Error>();

            try
            {
                res.listaDeErrores = Validaciones.validarLogin(req);

                if (!res.listaDeErrores.Any())
                {
                    //CERO errores ¡Todo bien!
                    int? idReturn = 0;
                    int? errorId = 0;
                    string errorCode = "";
                    string errorDescrip = "";
                    using (MiLinqDataContext linq = new MiLinqDataContext())
                    {
                        var resultado = linq.SP_INSERTAR_SESION(req.CorreoElectronico, req.Contrasena, req.Origen, ref idReturn, ref errorId, ref errorCode, ref errorDescrip).FirstOrDefault(); // ✅ Extraer el primer resultado

                        if (resultado != null)
                        {
                            res.Sesion = this.factorySesion(resultado);
                        }
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

        public ResConsultarSesion consultarSesion(ReqConsultarSesion req)
        {

            ResConsultarSesion res = new ResConsultarSesion();
            res.listaDeErrores = new List<Error>();

            try
            {
                res.listaDeErrores = Validaciones.validarConsSesion(req);

                if (!res.listaDeErrores.Any())
                {
                    //CERO errores ¡Todo bien!
                    int? errorId = 0;
                    string errorCode = "";
                    string errorDescrip = "";
                    using (MiLinqDataContext linq = new MiLinqDataContext())
                    {
                        var resultado = linq.SP_CONSULTAR_SESION(req.tokem, ref errorId, ref errorCode, ref errorDescrip).FirstOrDefault(); // ✅ Extraer el primer resultado

                        if (resultado != null)
                        {
                            res.usuario = this.factoryUsurario(resultado);
                        }
                    }
                    if (errorId == null || errorId == 0) 
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
        //Funciona
        public ResCerrarSesion cerrarSesion(ReqCerrarSesion req)
        {
            ResCerrarSesion res = new ResCerrarSesion();
            res.listaDeErrores = new List<Error>();

            try
            {
                // Validar los datos de la solicitud
                res.listaDeErrores = Validaciones.validarCerrarSesion(req);

                if (!res.listaDeErrores.Any()) // Si no hay errores, proceder con la consulta
                {
                    int? idReturn = 0;
                    int? errorId = 0;
                    string errorCode = "";
                    string errorDescrip = "";

                    using (MiLinqDataContext linq = new MiLinqDataContext())
                    {
                        // Ejecutar el Stored Procedure SP_CERRAR_SESION
                        var resultado = linq.SP_CERRAR_SESION( req.IdUsuario, req.Origen, ref idReturn, ref errorId, ref errorCode, ref errorDescrip);
                    }

                    // ✅ Manejo seguro de `idReturn` y `errorId`
                    if (idReturn != null && idReturn == 0)
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
        //Funciona
        public ResActualizarUsuario actualizarUsuario(ReqActualizarUsuario req)
        {
            ResActualizarUsuario res = new ResActualizarUsuario();
            res.listaDeErrores = new List<Error>();

            try
            {
                res.listaDeErrores = Validaciones.validarActualizarUsuario(req);

                if (!res.listaDeErrores.Any()) 
                {
                    //CERO errores ¡Todo bien!
                    int? idReturn = 0;
                    int? errorId = 0;
                    string errorCode = "";
                    string errorDescrip = "";

                    using (MiLinqDataContext linq = new MiLinqDataContext())
                    {
                        var resultado = linq.SP_ACTUALIZAR_USUARIO( req.IdUsuario,req.Nombre,req.FechaNacimiento,req.Direccion, req.Pin,ref idReturn,ref errorId,ref errorCode,ref errorDescrip);
                    }

                    // ✅ Manejo seguro de `idReturn` y `errorId`
                    if (idReturn != null && idReturn == 0)
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
                res.listaDeErrores.Add(new Error
                {
                    idError = -1,
                    error = ex.Message
                });
            }

            return res;
        }
        //Funciona
        public ResActualizarContrasena actualizarContrasena(ReqActualizarContrasena req)
        {
            ResActualizarContrasena res = new ResActualizarContrasena();
            res.listaDeErrores = new List<Error>();

            try
            {
                res.listaDeErrores = Validaciones.validarActualizarContrasena(req);

                if (!res.listaDeErrores.Any())
                {
                    int? errorId = 0;
                    string errorCode = "";
                    string errorDescrip = "";

                    using (MiLinqDataContext linq = new MiLinqDataContext())
                    {
                        linq.SP_ACTUALIZAR_CONTRASENA( req.IdUsuario,req.ContrasenaActual,req.NuevaContrasena,req.Pin,ref errorId,ref errorCode,ref errorDescrip);
                    }

                    if (errorId == null || errorId == 0)
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
                res.listaDeErrores.Add(new Error
                {
                    idError = -1,
                    error = ex.Message
                });
            }

            return res;
        }




        private Sesion factorySesion(SP_INSERTAR_SESIONResult tc)
        {

            Backend.Entidades.Usuario usuario = new Backend.Entidades.Usuario();
            usuario.IdUsuario = (int)tc.ID_USUARIO;
            usuario.Nombre = tc.NOMBRE;
            usuario.CorreoElectronico = tc.CORREO_ELECTRONICO;   
            usuario.FechaNacimiento = tc.FECHA_NACIMIENTO;
            usuario.FotoPerfil = tc.FOTO_PERFIL?.ToArray();
            usuario.Codigo = tc.CODIGO;  
            usuario.Direccion = tc.DIRECCION;
            usuario.IdTipoUsuario = tc.ID_TIPO_USUARIO;

            Sesion sesion = new Sesion();
            sesion.usuario = usuario;
            sesion.tokem = tc.TOKEN_SESION;
            sesion.expira = (DateTime)tc.EXPIRACION;

            return sesion;
        }

        private Backend.Entidades.Usuario factoryUsurario(SP_CONSULTAR_SESIONResult tc)
        {

            Backend.Entidades.Usuario usuario = new Backend.Entidades.Usuario();
            usuario.IdUsuario = (int)tc.ID_USUARIO;
            usuario.Nombre = tc.NOMBRE;
            usuario.CorreoElectronico = tc.CORREO_ELECTRONICO;
            usuario.FechaNacimiento = tc.FECHA_NACIMIENTO;
            usuario.FotoPerfil = tc.FOTO_PERFIL?.ToArray();
            usuario.Codigo = tc.CODIGO;
            usuario.Direccion = tc.DIRECCION;
            usuario.IdTipoUsuario = tc.ID_TIPO_USUARIO;


            return usuario;
        }
    }

}