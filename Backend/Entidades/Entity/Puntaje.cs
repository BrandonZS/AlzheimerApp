using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Backend.Entidades
{
    public class Puntaje
    {
        public int IdPuntaje { get; set; }
        public DateTime FechaHora { get; set; }
        public int ValorPuntaje { get; set; }
        public int IdJuego { get; set; }
        public int IdUsuario { get; set; }
    }
}
