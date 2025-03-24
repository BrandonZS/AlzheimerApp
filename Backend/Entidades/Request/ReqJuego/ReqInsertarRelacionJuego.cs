using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Backend.Entidades
{
    public class ReqInsertarRelacionJuego
    {
        public int idJuego {  get; set; }
        public int idUsuario { get; set; }
        public int idPaciente { get; set; }

    }
}
