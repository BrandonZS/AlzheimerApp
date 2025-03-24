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

        [System.Web.Http.HttpPost]
        [System.Web.Http.Route("api/juego/insertarpregunta")]
        public List<ResInsertarPregunta> insertarPregunta(ReqInsertarPregunta req) //INVESTIGAR: Recibir y retornar HTTP
        {
            return new LogJuego().insertarPregunta(req);
        }

        [System.Web.Http.HttpPost]
        [System.Web.Http.Route("api/juego/insertarrelacion")]
        public ResInsertarRelacionJuego insertarRelacionJuego(ReqInsertarRelacionJuego req) //INVESTIGAR: Recibir y retornar HTTP
        {
            return new LogJuego().insertarRelacionJuego(req);
        }

        [System.Web.Http.HttpPost]
        [System.Web.Http.Route("api/juego/obtenerjuegoscuidador")]
        public ResObtenerJuegosCuidador obtenerJuegosCuidador(ReqObtenerJuegosCuidador req) //INVESTIGAR: Recibir y retornar HTTP
        {
            return new LogJuego().obtenerJuegosCuidador(req);
        }
    }
}
