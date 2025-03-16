using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Backend.Entidades
{
    public enum enumErrores
    {
        excepcionBaseDatos = -2,
        excepcionLogica = -1,
        requestNulo = 1,
        nombreFaltante = 2,
        apellidoFaltante = 3,
        correoFaltante = 4,
        passwordFaltante = 5,
        correoIncorrecto = 6,
        passwordMuyDebil = 7,
        idFaltante = 8,
        sesionCerrada = 9,
        
    }
}
