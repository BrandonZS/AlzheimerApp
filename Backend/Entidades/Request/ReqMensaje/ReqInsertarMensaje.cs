using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Backend.Entidades
{
   public class ReqInsertarMensaje
    {
        public int IdCuidador { get; set; }
        public int IdPaciente { get; set; }
        public string Contenido { get; set; }
    }
}
