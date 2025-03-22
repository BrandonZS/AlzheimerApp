using Backend.Entidades;
using Backend.Logica;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace API.Controllers
{
    public class MensajeController : Controller
    {
        [System.Web.Http.HttpPost]
        [System.Web.Http.Route("api/mensaje/insertar")]
        public ResInsertarMensaje insertarMensaje(ReqInsertarMensaje req)
        {
            return new LogUsuario().insertarMensaje(req);
        }


    }
}