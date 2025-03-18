using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Backend.Entidades.Entity
{
    public class Sesion
    {
        public DateTime inicio { get; set; }
        public int Id { get; set; }
        public Usuario usuario { get; set; }
        public string origen { get; set; }
        public int rol { get; set; }

        public enumEstadoSesion estado { get; set; }

    }
}
