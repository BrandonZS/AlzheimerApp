using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Backend.Entidades
{
   public class ReqActualizarContrasena
    {
        public int IdUsuario { get; set; }
        public string ContrasenaActual { get; set; }
        public string NuevaContrasena { get; set; }
        public string Pin { get; set; } // Puede ser null
    }
}
