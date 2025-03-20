using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Backend.Entidades
{
    public class ReqInsertarUsuario
    {
        public string Nombre { get; set; }
        public string CorreoElectronico { get; set; }
        public string Contrasena { get; set; }
        public DateTime FechaNacimiento { get; set; }
        public byte[] FotoPerfil { get; set; } // Puede ser `null`
        public string Direccion { get; set; } // Puede ser `null`
        public int IdTipoUsuario { get; set; }
    }
}
