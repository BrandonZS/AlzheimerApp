using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Backend.Entidades
{
   public class ReqActualizarUsuario
    {
        public int IdUsuario { get; set; }
        public string Nombre { get; set; }
        public DateTime FechaNacimiento { get; set; }
        public string Direccion { get; set; }
        public string Pin { get; set; }  // Puede ser null si no se requiere
    }
}
