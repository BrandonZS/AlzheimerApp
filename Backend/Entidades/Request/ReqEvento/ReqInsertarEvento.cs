using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Backend.Entidades
{
   public class ReqInsertarEvento
    {
        public int IdCuidador { get; set; } // ID del cuidador que crea el evento
        public string Titulo { get; set; }
        public string Descripcion { get; set; } // Puede ser NULL
        public DateTime FechaHora { get; set; }
        public int IdPrioridad { get; set; }
    }
}
