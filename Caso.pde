class Caso {
  int id;
  int nivel;
  String descripcion;
  String tipoDelito;
  String evidencias;
  String ley;
  String pena;
  int gravedad;

  Caso(int id, int nivel, String descripcion, String tipoDelito,
       String evidencias, String ley, String pena, int gravedad) {
    this.id          = id;
    this.nivel       = nivel;
    this.descripcion = descripcion;
    this.tipoDelito  = tipoDelito;
    this.evidencias  = evidencias;
    this.ley         = ley;
    this.pena        = pena;
    this.gravedad    = gravedad;
  }

  String resumen() {
    return "Caso " + id + " | Nivel " + nivel + " | " + tipoDelito + " | G:" + gravedad;
  }
}
