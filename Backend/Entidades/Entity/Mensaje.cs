using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Backend.Entidades
{
    public class Mensaje
    {
        public int IdMensaje { get; set; }
        public string Contenido { get; set; }
        public DateTime FechaEnviado { get; set; }
        public DateTime? FechaRecibido { get; set; } // Puede ser NULL
        public int IdUsuarioCuidador { get; set; }
        public int IdUsuarioPaciente { get; set; }
        public int IdEstado { get; set; }
    }
}
