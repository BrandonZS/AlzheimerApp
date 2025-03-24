using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Backend.Entidades
{
   public class ResObtenerMensajes : ResBase
    {
        public List<Mensaje> listaMensajes { get; set; }

    }
}
