using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Backend.Entidades
{
   public class Ping
    {
        public int IdPing { get; set; }
        public string Codigo { get; set; }
        public DateTime Fecha { get; set; }
        public bool Estado { get; set; }
        public int IdUsuario { get; set; }
    }
}
