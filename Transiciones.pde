final int TRANS_NONE  = 0;
final int TRANS_FADE  = 1;
final int TRANS_FLASH = 2;


class SistemaTransicion {
  int tipo     = TRANS_NONE;
  float alpha  = 0;
  boolean saliendo = true;   
  boolean activo   = false;
  int duracionFrames = 22;   
  int frameActual    = 0;

 
  boolean puntoMedioEjecutado = false;
  int pantallaSiguiente = -1;

  void iniciarFade(int pantallaDestino) {
    tipo               = TRANS_FADE;
    alpha              = 0;
    saliendo           = true;
    activo             = true;
    frameActual        = 0;
    puntoMedioEjecutado = false;
    pantallaSiguiente  = pantallaDestino;
    duracionFrames     = 20;
  }

  void iniciarFlash(int pantallaDestino) {
    tipo               = TRANS_FLASH;
    alpha              = 0;
    saliendo           = true;
    activo             = true;
    frameActual        = 0;
    puntoMedioEjecutado = false;
    pantallaSiguiente  = pantallaDestino;
    duracionFrames     = 14;
  }

 
  boolean actualizar() {
    if (!activo) return false;
    frameActual++;
    float t = (float)frameActual / duracionFrames;
    if (saliendo) {
      alpha = t * 255;
      if (frameActual >= duracionFrames) {
        saliendo    = false;
        frameActual = 0;
        if (!puntoMedioEjecutado) {
          puntoMedioEjecutado = true;
          return true; 
        }
      }
    } else {
      alpha = (1.0 - t) * 255;
      if (frameActual >= duracionFrames) {
        activo = false;
        alpha  = 0;
      }
    }
    return false;
  }

  void dibujar() {
    if (!activo || alpha <= 0) return;
    pushStyle();
    noStroke();
    if (tipo == TRANS_FLASH) {
      fill(220, 235, 255, alpha);
    } else {
      fill(6, 10, 18, alpha);
    }
    rect(0, 0, width, height);
    popStyle();
  }

  boolean estaActivo() { return activo; }
}
