using AccesoDatos;
using Backend.Entidades;
using Backend.Logica.Usuario.Varios;
using System;
using System.Collections.Generic;
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
    }
}
