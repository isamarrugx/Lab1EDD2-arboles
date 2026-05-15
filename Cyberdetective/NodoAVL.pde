class NodoAVL {
  Caso caso;
  NodoAVL izq, der;
  int altura;

  float x, y;
  float targetX, targetY;
  int brilloFrames = 0;
  String etiquetaAnimacion = "";

  NodoAVL(Caso caso) {
    this.caso = caso;
    altura    = 1;
    x = 1260 / 2.0;
    y = -100;
    targetX = x;
    targetY = y;
    resaltar("NUEVO");
  }

  void resaltar(String etiqueta) {
    brilloFrames     = 70;
    etiquetaAnimacion = etiqueta;
  }

  boolean contiene(float mx, float my) {
    return dist(mx, my, x, y) <= 40;
  }
}
