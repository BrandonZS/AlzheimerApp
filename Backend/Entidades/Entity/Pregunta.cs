using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Backend.Entidades.Entity
{
    public class Pregunta
    {
        public int IdPregunta { get; set; }
        public string Titulo { get; set; }
        public string Descripcion { get; set; }
        public byte[] IdImagen { get; set; }
        public List<Opcion> opciones { get; set; } = new List<Opcion>();
    }
}
