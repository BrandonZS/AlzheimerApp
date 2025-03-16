using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Backend.Entidades
{
    public class Juego
    {
        public int IdJuego { get; set; }
        public string Nombre { get; set; }
        public int IdUsuarioCreador { get; set; }

    }
}
