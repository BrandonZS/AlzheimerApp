using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Backend.Entidades
{
    public class ResObtenerPuntaje : ResBase
    {
        public List<Puntaje> puntajes { get; set; }
    }
}
