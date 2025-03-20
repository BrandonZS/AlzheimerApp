using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Backend.Entidades
{
  public enum CatalogoErrores
    {
        errorNoControlado = -1,
        requestNull = 1,
        nombreNuloVacio = 2,
        apellidoNuloVacio = 3,
        correoNuloVacio = 4,
        telefonoNuloVacio = 5,
        rolNuloVacio = 6,
        passwordNuloVacio = 7,
        errorDeBaseDatos = 8,
        especialidadNuloVacio = 9,
        descripcionNuloVacio = 10,
        duracionServicioNuloVacio = 11,
        precioNuloVacio = 12,
        stockNullVacio = 13,
        correoNoEnviado = 14,
        correoNoVerificado = 15,
        correoElectronicoRepetido = 16,
        usuarioInactivo = 17,
        usuarioVerficado = 18,

        correoIncorrecto = 19,
        passwordFaltante = 20,
        passwordMuyDebil = 21,
        fechaInvalida = 22,
        faltaTokem = 23,
        fechaVacia = 24,  
        direccionVacia = 25,
        contrasenaActualVacia = 26,
        nuevaContrasenaVacia = 27,
        codigoPacienteInvalido = 28,    
    }
}
