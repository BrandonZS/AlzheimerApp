using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Backend.Entidades.Entity
{
    class Pregunta
    {
        public int IdPregunta { get; set; }
        public string Titulo { get; set; }
        public string Descripcion { get; set; }
        public int IdJuego { get; set; }
        public int IdImagen { get; set; }
    }
}
