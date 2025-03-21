using Backend.Entidades;
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

    }
}
