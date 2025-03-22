using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Backend.Entidades
{
   public class ResObtenerEventosPaciente : ResBase
    {
        public List<Evento> eventos { get; set; }

    }
}
