using Backend.Entidades;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace Backend.Logica.Usuario.Varios
{
   public static class Validaciones
    {
 public static List<Error> validarUsuario(ReqInsertarUsuario req)
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
                if (String.IsNullOrEmpty(req.Nombre))
                {
                    error.idError = (int)CatalogoErrores.nombreNuloVacio;
                    error.error = "Falta el nombre del usuario";
                    errores.Add(error);
                }

    

                if (String.IsNullOrEmpty(req.CorreoElectronico))
                {
                    error.idError = (int)CatalogoErrores.correoNuloVacio;
                    error.error = "Falta el correo electronico del usuario";
                    errores.Add(error);
                }

                if (String.IsNullOrEmpty(req.Contrasena))
                {
                    error.idError = (int)CatalogoErrores.passwordNuloVacio;
                    error.error = "Falta la contraseña";
                    errores.Add(error);
                }
                else if (!EsCorreoValido(req.CorreoElectronico))
                {
                    error.idError = (int)CatalogoErrores.correoIncorrecto;
                    error.error = "Correo incorrecto";
                    errores.Add(error);

                }
                if (String.IsNullOrEmpty(req.Contrasena))
                {
                    error.idError = (int)CatalogoErrores.passwordFaltante;
                    error.error = "Contrasena vacio";
                    errores.Add(error);

                }
                else if (!EsPasswordSeguro(req.Contrasena))
                {
                    error.idError = (int)CatalogoErrores.passwordMuyDebil;
                    error.error = "Contrasena debil";
                    errores.Add(error);
                }
                else if (!EsFechaNacimientoValida(req.FechaNacimiento))
                {
                    error.idError = (int)CatalogoErrores.fechaInvalida;
                    error.error = "Fecha invalida";
                    errores.Add(error);

                }


            }
            return errores;
        }

    //public static List<Error> validarLogin(ReqLogin req)
    //{
    //    List<Error> errores = new List<Error>();

    //    if (req == null)
    //    {
    //        Error error = new Error();
    //        error.idError = (int)CatalogoErrores.requestNull;
    //        error.error = "Request null";
    //        errores.Add(error);
    //    }
    //    else
    //    {
    //        //hacer validaciones       
    //    }
    //    return errores;
    //}

    //public static List<Error> validarEmpleado(ReqIngresarEmpleado req)
    //{
    //    List<Error> errores = new List<Error>();

    //    if (req == null)
    //    {
    //        Error error = new Error();
    //        error.idError = (int)CatalogoErrores.requestNull;
    //        error.error = "Request null";
    //        errores.Add(error);
    //    }
    //    else
    //    {
    //        if (String.IsNullOrEmpty(req.empleado.nombre))
    //        {
    //            Error error = new Error();
    //            error.idError = (int)CatalogoErrores.nombreNuloVacio;
    //            error.error = "Falta el nombre del empleado";
    //            errores.Add(error);
    //        }
    //        if (String.IsNullOrEmpty(req.empleado.apellido))
    //        {
    //            Error error = new Error();
    //            error.idError = (int)CatalogoErrores.apellidoNuloVacio;
    //            error.error = "Falta el apellido del empleado";
    //            errores.Add(error);
    //        }
    //        if (String.IsNullOrEmpty(req.empleado.telefono))
    //        {
    //            Error error = new Error();
    //            error.idError = (int)CatalogoErrores.telefonoNuloVacio;
    //            error.error = "Falta el telefono del empleado";
    //            errores.Add(error);
    //        }
    //        if (String.IsNullOrEmpty(req.empleado.espacialidad))
    //        {
    //            Error error = new Error();
    //            error.idError = (int)CatalogoErrores.especialidadNuloVacio;
    //            error.error = "Falta la especialidad del empleado";
    //            errores.Add(error);
    //        }
    //    }
    //    return errores;
    //}

    //public static List<Error> validarServicio(ReqIngresarServicio req)
    //{
    //    List<Error> errores = new List<Error>();

    //    if (req == null)
    //    {
    //        Error error = new Error();
    //        error.idError = (int)CatalogoErrores.requestNull;
    //        error.error = "Request null";
    //        errores.Add(error);
    //    }
    //    else
    //    {
    //        if (String.IsNullOrEmpty(req.servicio.nombre))
    //        {
    //            Error error = new Error();
    //            error.idError = (int)CatalogoErrores.nombreNuloVacio;
    //            error.error = "Falta el nombre del servicio";
    //            errores.Add(error);
    //        }

    //        if (String.IsNullOrEmpty(req.servicio.descripcion))
    //        {
    //            Error error = new Error();
    //            error.idError = (int)CatalogoErrores.descripcionNuloVacio;
    //            error.error = "Falta la descripcion del servicio";
    //            errores.Add(error);
    //        }

    //        if (req.servicio.duracionMinutos < 0)
    //        {
    //            Error error = new Error();
    //            error.idError = (int)CatalogoErrores.duracionServicioNuloVacio;
    //            error.error = "La duracion tiene que ser mayor a 0 ";
    //            errores.Add(error);
    //        }

    //        if (req.servicio.precio < 0)
    //        {
    //            Error error = new Error();
    //            error.idError = (int)CatalogoErrores.precioNuloVacio;
    //            error.error = "El precio debe ser mayor a 0";
    //            errores.Add(error);
    //        }
    //    }
    //    return errores;
    //}

    //public static List<Error> validarProducto(ReqIngresarProducto req)
    //{
    //    List<Error> errores = new List<Error>();

    //    if (req == null)
    //    {
    //        Error error = new Error();
    //        error.idError = (int)CatalogoErrores.requestNull;
    //        error.error = "Request null";
    //        errores.Add(error);
    //    }
    //    else
    //    {
    //        if (String.IsNullOrEmpty(req.producto.nombre))
    //        {
    //            Error error = new Error();
    //            error.idError = (int)CatalogoErrores.nombreNuloVacio;
    //            error.error = "Falta nombre del producto";
    //            errores.Add(error);
    //        }

    //        if (String.IsNullOrEmpty(req.producto.descripcion))
    //        {
    //            Error error = new Error();
    //            error.idError = (int)CatalogoErrores.descripcionNuloVacio;
    //            error.error = "Falta descripcion del producto";
    //            errores.Add(error);
    //        }

    //        if (req.producto.precio < 0)
    //        {
    //            Error error = new Error();
    //            error.idError = (int)CatalogoErrores.precioNuloVacio;
    //            error.error = "El producto tiene que valer mas de 0";
    //            errores.Add(error);
    //        }

    //        if (req.producto.stock < 0)
    //        {
    //            Error error = new Error();
    //            error.idError = (int)CatalogoErrores.stockNullVacio;
    //            error.error = "El stock tiene que ser mayor a 0";
    //            errores.Add(error);
    //        }

    //    }
    //    return errores;
    //}


        public static bool EsCorreoValido(string correo)
        {
            // Verifica que el correo no sea nulo o vacío.
            if (string.IsNullOrWhiteSpace(correo))
                return false;

            // Patrón simple para validar correo electrónico.
            string patron = @"^[^@\s]+@[^@\s]+\.[^@\s]+$";

            return Regex.IsMatch(correo, patron);
        }

        public static bool EsPasswordSeguro(string password)
        {
            // Verifica que el password no sea nulo o vacío.
            if (string.IsNullOrWhiteSpace(password))
                return false;

            // Patrón que valida el password según los criterios mencionados.
            string patron = @"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$";

            return Regex.IsMatch(password, patron);
        }

        public static bool EsFechaNacimientoValida(DateTime fechaNacimiento)
        {
            // La fecha no puede ser en el futuro ni anterior al año 1900
            return fechaNacimiento <= DateTime.Now && fechaNacimiento.Year >= 1900;
        }
    }
}