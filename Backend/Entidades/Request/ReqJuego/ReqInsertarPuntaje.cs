using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Backend.Entidades
{
    public class ReqInsertarPuntaje
    {
        public int idPaciente {  get; set; }
        public int idJuego { get; set; }
        public int puntaje { get; set; }
    }
}
