using Backend.Entidades;
using Backend.Logica;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace API.Controllers
{
    public class MensajeController : ApiController
    {


        //Api para mensajes 
        [System.Web.Http.HttpPost]
        [System.Web.Http.Route("api/mensaje/insertar")]
        public ResInsertarMensaje insertarMensaje(ReqInsertarMensaje req)
        {
            return new LogMensaje().insertarMensaje(req);
        }
        [System.Web.Http.HttpPost]
        [System.Web.Http.Route("api/mensaje/obtener")]
        public ResObtenerMensajes obtenerMensajes(ReqObtenerMensajes req)
        {
            return new LogMensaje().obtenerMensajes(req);
        }
        [System.Web.Http.HttpPost]
        [System.Web.Http.Route("api/mensaje/actualizarestado")]
        public ResActualizarMensaje actualizarEstadoMensaje(ReqActualizarMensaje req)
        {
            return new LogMensaje().actualizarEstadoMensaje(req);
        }
    }
}
