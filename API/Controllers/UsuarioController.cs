﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using Backend;
using Backend.Entidades;
using Backend.Logica;

namespace API.Controllers
{
    public class UsuarioController : ApiController
    {
        [System.Web.Http.HttpPost]
        [System.Web.Http.Route("api/usuario/insertar")]
        public  ResInsertarUsuario insertarUsuario(ReqInsertarUsuario req) //INVESTIGAR: Recibir y retornar HTTP
        {
            return new LogUsuario().insertarUsuario(req);
        }

        [System.Web.Http.HttpPost]
        [System.Web.Http.Route("api/usuario/iniciarsesion")]
        public ResIniciarSesion iniciarSesion(ReqIniciarSesion req) //INVESTIGAR: Recibir y retornar HTTP
        {
            return new LogUsuario().iniciarSesion(req);
        }

        [System.Web.Http.HttpPost]
        [System.Web.Http.Route("api/usuario/consultarsesion")]
        public ResConsultarSesion consultarSesion(ReqConsultarSesion req) //INVESTIGAR: Recibir y retornar HTTP
        {
            return new LogUsuario().consultarSesion(req);
        }

        [System.Web.Http.HttpPost]
        [System.Web.Http.Route("api/usuario/cerrarsesion")]
        public ResCerrarSesion cerrarSesion(ReqCerrarSesion req)
        {
            return new LogUsuario().cerrarSesion(req);
        }

        [System.Web.Http.HttpPost]
        [System.Web.Http.Route("api/usuario/actualizarusuario")]
        public ResActualizarUsuario actualizarUsuario(ReqActualizarUsuario req)
        {
            return new LogUsuario().actualizarUsuario(req);
        }
        [System.Web.Http.HttpPost]
        [System.Web.Http.Route("api/usuario/actualizarcontrasena")]
        public ResActualizarContrasena actualizarContrasena(ReqActualizarContrasena req)
        {
            return new LogUsuario().actualizarContrasena(req);
        }

        //Api para relacion 
        [System.Web.Http.HttpPost]
        [System.Web.Http.Route("api/usuario/insertarrelacion")]
        public ResInsertarRelacion insertarRelacion(ReqInsertarRelacion req)
        {
            return new LogUsuario().insertarRelacion(req);
        }
        [System.Web.Http.HttpPost]
        [System.Web.Http.Route("api/usuario/eliminarrelacion")]
        public ResEliminarRelacion eliminarRelacion(ReqEliminarRelacion req)
        {
            return new LogUsuario().eliminarRelacion(req);
        }

        [System.Web.Http.HttpPost]
        [System.Web.Http.Route("api/usuario/obtenerrelacion")]
        public ResObtenerRelacion obtenerRelacion(ReqObtenerRelacion req)
        {
            return new LogUsuario().obtenerRelacion(req);

            //Api para Ping
        }
        [System.Web.Http.HttpPost]
        [System.Web.Http.Route("api/usuario/insertarping")]
        public ResInsertarPing insertarPing(ReqInsertarPing req)
        {
            return new LogUsuario().insertarPing(req);
        }
        [System.Web.Http.HttpPost]
        [System.Web.Http.Route("api/usuario/actualizarping")]
        public ResActualizarPing actualizarPing(ReqActualizarPing req)
        {
            return new LogUsuario().actualizarPing(req);
        }
        [System.Web.Http.HttpPost]
        [System.Web.Http.Route("api/usuario/eliminarping")]
        public ResEliminarPing eliminarPing(ReqEliminarPing req)
        {
            return new LogUsuario().eliminarPing(req);
        }










    }
}
    

