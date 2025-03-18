using Backend.Entidades;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Backend.Logica.Usuario.Varios
{
   public static class Validaciones
    {
 public static List<Error> validarUsuario(ReqInsertarUsuario req)
        {
            List<Error> errores = new List<Error>();

            if (req == null)
            {
                Error error = new Error();
                error.idError = (int)CatalogoErrores.requestNull;
                error.error = "Request null";
                errores.Add(error);
            }
            else
            {
                if (String.IsNullOrEmpty(req.usuario.nombre))
                {
                    Error error = new Error();
                    error.idError = (int)CatalogoErrores.nombreNuloVacio;
                    error.error = "Falta el nombre del usuario";
                    errores.Add(error);
                }

                if (String.IsNullOrEmpty(req.usuario.apellido))
                {
                    Error error = new Error();
                    error.idError = (int)CatalogoErrores.apellidoNuloVacio;
                    error.error = "Falta el apellido del usuario";
                    errores.Add(error);
                }

                if (String.IsNullOrEmpty(req.usuario.correoElectronico))
                {
                    Error error = new Error();
                    error.idError = (int)CatalogoErrores.correoNuloVacio;
                    error.error = "Falta el correo electronico del usuario";
                    errores.Add(error);
                }

                if (String.IsNullOrEmpty(req.usuario.telefono))
                {
                    Error error = new Error();
                    error.idError = (int)CatalogoErrores.telefonoNuloVacio;
                    error.error = "Falta el telefono del usuario";
                    errores.Add(error);
                }

                if (String.IsNullOrEmpty(req.usuario.password))
                {
                    Error error = new Error();
                    error.idError = (int)CatalogoErrores.passwordNuloVacio;
                    error.error = "Falta la contraseña";
                    errores.Add(error);
                }

                if (req.usuario.idRol == 0)
                {
                    Error error = new Error();
                    error.idError = (int)CatalogoErrores.rolNuloVacio;
                    error.error = "Falta un rol al usuario";
                    errores.Add(error);
                }
            }
            return errores;
        }

    public static List<Error> validarLogin(ReqLogin req)
    {
        List<Error> errores = new List<Error>();

        if (req == null)
        {
            Error error = new Error();
            error.idError = (int)CatalogoErrores.requestNull;
            error.error = "Request null";
            errores.Add(error);
        }
        else
        {
            //hacer validaciones       
        }
        return errores;
    }

    public static List<Error> validarEmpleado(ReqIngresarEmpleado req)
    {
        List<Error> errores = new List<Error>();

        if (req == null)
        {
            Error error = new Error();
            error.idError = (int)CatalogoErrores.requestNull;
            error.error = "Request null";
            errores.Add(error);
        }
        else
        {
            if (String.IsNullOrEmpty(req.empleado.nombre))
            {
                Error error = new Error();
                error.idError = (int)CatalogoErrores.nombreNuloVacio;
                error.error = "Falta el nombre del empleado";
                errores.Add(error);
            }
            if (String.IsNullOrEmpty(req.empleado.apellido))
            {
                Error error = new Error();
                error.idError = (int)CatalogoErrores.apellidoNuloVacio;
                error.error = "Falta el apellido del empleado";
                errores.Add(error);
            }
            if (String.IsNullOrEmpty(req.empleado.telefono))
            {
                Error error = new Error();
                error.idError = (int)CatalogoErrores.telefonoNuloVacio;
                error.error = "Falta el telefono del empleado";
                errores.Add(error);
            }
            if (String.IsNullOrEmpty(req.empleado.espacialidad))
            {
                Error error = new Error();
                error.idError = (int)CatalogoErrores.especialidadNuloVacio;
                error.error = "Falta la especialidad del empleado";
                errores.Add(error);
            }
        }
        return errores;
    }

    public static List<Error> validarServicio(ReqIngresarServicio req)
    {
        List<Error> errores = new List<Error>();

        if (req == null)
        {
            Error error = new Error();
            error.idError = (int)CatalogoErrores.requestNull;
            error.error = "Request null";
            errores.Add(error);
        }
        else
        {
            if (String.IsNullOrEmpty(req.servicio.nombre))
            {
                Error error = new Error();
                error.idError = (int)CatalogoErrores.nombreNuloVacio;
                error.error = "Falta el nombre del servicio";
                errores.Add(error);
            }

            if (String.IsNullOrEmpty(req.servicio.descripcion))
            {
                Error error = new Error();
                error.idError = (int)CatalogoErrores.descripcionNuloVacio;
                error.error = "Falta la descripcion del servicio";
                errores.Add(error);
            }

            if (req.servicio.duracionMinutos < 0)
            {
                Error error = new Error();
                error.idError = (int)CatalogoErrores.duracionServicioNuloVacio;
                error.error = "La duracion tiene que ser mayor a 0 ";
                errores.Add(error);
            }

            if (req.servicio.precio < 0)
            {
                Error error = new Error();
                error.idError = (int)CatalogoErrores.precioNuloVacio;
                error.error = "El precio debe ser mayor a 0";
                errores.Add(error);
            }
        }
        return errores;
    }

    public static List<Error> validarProducto(ReqIngresarProducto req)
    {
        List<Error> errores = new List<Error>();

        if (req == null)
        {
            Error error = new Error();
            error.idError = (int)CatalogoErrores.requestNull;
            error.error = "Request null";
            errores.Add(error);
        }
        else
        {
            if (String.IsNullOrEmpty(req.producto.nombre))
            {
                Error error = new Error();
                error.idError = (int)CatalogoErrores.nombreNuloVacio;
                error.error = "Falta nombre del producto";
                errores.Add(error);
            }

            if (String.IsNullOrEmpty(req.producto.descripcion))
            {
                Error error = new Error();
                error.idError = (int)CatalogoErrores.descripcionNuloVacio;
                error.error = "Falta descripcion del producto";
                errores.Add(error);
            }

            if (req.producto.precio < 0)
            {
                Error error = new Error();
                error.idError = (int)CatalogoErrores.precioNuloVacio;
                error.error = "El producto tiene que valer mas de 0";
                errores.Add(error);
            }

            if (req.producto.stock < 0)
            {
                Error error = new Error();
                error.idError = (int)CatalogoErrores.stockNullVacio;
                error.error = "El stock tiene que ser mayor a 0";
                errores.Add(error);
            }

        }
        return errores;
    }
}
}