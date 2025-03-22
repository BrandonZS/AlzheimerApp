using Backend.Entidades;
using Backend.Entidades.Response.ResEvento;
using Backend.Logica;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace API.Controllers
{
    public class EventoController : ApiController
    {


        //Api para Evento
        [System.Web.Http.HttpPost]
        [System.Web.Http.Route("api/evento/insertar")]
        public ResInsertarEvento insertarEvento(ReqInsertarEvento req)
        {
            return new LogEvento().insertarEvento(req);
        }
        [System.Web.Http.HttpPost]
        [System.Web.Http.Route("api/evento/actualizar")]
        public ResActualizarEvento actualizarEvento(ReqActualizarEvento req)
        {
            return new LogEvento().actualizarEvento(req);
        }
        [System.Web.Http.HttpPost]
        [System.Web.Http.Route("api/evento/eliminar")]
        public ResEliminarEvento eliminarEvento(ReqEliminarEvento req)
        {
            return new LogEvento().eliminarEvento(req);
        }
        [System.Web.Http.HttpPost]
        [System.Web.Http.Route("api/evento/agregarPaciente")]
        public ResInsertarPacienteEvento insertarPacienteEvento(ReqInsertarPacienteEvento req)
        {
            return new LogEvento().insertarPacienteEvento(req);
        }
        [System.Web.Http.HttpPost]
        [System.Web.Http.Route("api/evento/eliminarpacienteevento")]
        public ResEliminarPacienteEvento eliminarPacienteEvento(ReqEliminarPacienteEvento req)
        {
            return new LogEvento().eliminarPacienteEvento(req);
        }
        [System.Web.Http.HttpPost]
        [System.Web.Http.Route("api/evento/obtenereventospaciente")]
        public ResObtenerEventosPaciente obtenerEventosPaciente(ReqObtenerEventosPaciente req)
        {
            return new LogEvento().obtenerEventosPaciente(req);
        }
        [System.Web.Http.HttpPost]
        [System.Web.Http.Route("api/evento/obtenereventoscuidador")]
        public List<ResObtenerEventosCuidador> obtenerEventosCuidador(ReqObtenerEventosCuidador req)
        {
            return new LogEvento().obtenerEventosCuidador(req);
        }


    }
}
