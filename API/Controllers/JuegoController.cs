using Backend.Entidades;
using Backend.Logica.Juego;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace API.Controllers
{
    public class JuegoController : ApiController
    {
        [System.Web.Http.HttpPost]
        [System.Web.Http.Route("api/juego/insertarjuego")]
        public ResInsertarJuego insertarUsuario(ReqInsertarJuego req) //INVESTIGAR: Recibir y retornar HTTP
        {
            return new LogJuego().insertarJuego(req);
        }
    }
}
