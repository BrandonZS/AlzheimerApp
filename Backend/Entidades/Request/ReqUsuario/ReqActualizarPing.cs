using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Backend.Entidades
{
   public class ReqActualizarPing
    {
        public int IdUsuario { get; set; }
        public string PinActual { get; set; }
        public string NuevoCodigo { get; set; }
    }
}
