class OpcionInteractiva {
  float x, y, w, h;
  String texto;
  boolean esCorrecta;
  boolean seleccionada = false;

  OpcionInteractiva(float x, float y, float w, float h, String texto, boolean esCorrecta) {
    this.x = x; this.y = y; this.w = w; this.h = h;
    this.texto = texto; this.esCorrecta = esCorrecta;
  }

  void actualizar() { /* reservado */ }

  void dibujar(AssetManager assets, String fondoNormal, String fondoSeleccion) {
    boolean hover = estaSobre();
    pushStyle();
    float r = min(w, h) * 0.14;

    
    noStroke(); fill(0, 0, 0, hover ? 95 : 65);
    rect(x + 4, y + 6, w, h, r);

    int colBorde = seleccionada ? color(255, 220, 110) : (hover ? color(130, 200, 255) : color(90, 150, 220, 170));
    int colFondo = seleccionada ? color(32, 53, 82, 240) : (hover ? color(22, 36, 60, 240) : color(14, 22, 40, 215));

    
    fill(seleccionada ? color(255,220,110,40) : color(100,170,255,hover?30:14));
    rect(x-1, y-1, w+2, h+2, r+1);

    
    fill(colFondo);
    stroke(colBorde);
    strokeWeight(seleccionada ? 3.0 : (hover ? 2.2 : 1.5));
    rect(x, y, w, h, r);

    
    noStroke(); fill(255, hover ? 30 : 16);
    rect(x+4, y+4, w-8, h*0.28, r*0.75);

    
    if (seleccionada) {
      fill(255, 220, 110);
      rect(x, y + h*0.2, 4, h*0.6, 2);
    }

    
    fill(245);
    textAlign(CENTER, CENTER);
    textSize(constrain(h * 0.19, 13, 21));
    text(texto, x + 18, y + 12, w - 36, h - 24);

    popStyle();
  }

  boolean estaSobre() {
    return mouseX >= x && mouseX <= x+w && mouseY >= y && mouseY <= y+h;
  }
}
