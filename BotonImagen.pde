class BotonImagen {
  float x, y, w, h;
  String rutaNormal;   // Conservado por compatibilidad (no se usa para dibujo)
  String rutaHover;
  String texto;
  boolean seleccionado = false;

  // ─── Paleta de acento por tipo de botón ─────────────────────────────────
  static final int ACENTO_NORMAL    = 0;
  static final int ACENTO_POSITIVO  = 1;
  static final int ACENTO_PELIGRO   = 2;
  static final int ACENTO_ADVERTIR  = 3;
  static final int ACENTO_PURPURA   = 4;
  static final int ACENTO_CYAN      = 5;

  BotonImagen(float x, float y, float w, float h,
              String rutaNormal, String rutaHover, String texto) {
    this.x = x; this.y = y; this.w = w; this.h = h;
    this.rutaNormal = rutaNormal; this.rutaHover = rutaHover;
    this.texto = texto;
  }

  void actualizar() { /* reservado */ }

  void dibujar(AssetManager assets) {
    boolean hover = estaSobre();
    pushStyle();

    int[] acento = resolverAcento();
    int colBorde  = acento[0];
    int colBrillo = hover ? acento[1] : acento[2];
    float r = min(w, h) * 0.22;

    // Sombra
    noStroke(); fill(0, 80);
    rect(x + 4, y + 6, w, h, r);

    // Halo externo cuando hover o seleccionado
    fill(colBrillo);
    rect(x - 2, y - 2, w + 4, h + 4, r + 2);

    // Cuerpo
    fill(hover ? color(24, 34, 54, 250) : color(16, 24, 40, 230));
    stroke(seleccionado ? color(255, 220, 110) : colBorde);
    strokeWeight(seleccionado ? 3.8 : (hover ? 2.6 : 1.8));
    rect(x, y, w, h, r);

    // Brillo superior
    noStroke();
    fill(255, hover ? 32 : 18);
    rect(x + 3, y + 3, w - 6, h * 0.38, r * 0.7);

    // Borde selección
    if (seleccionado) {
      noFill();
      stroke(255, 220, 110, 160);
      strokeWeight(2);
      rect(x - 5, y - 5, w + 10, h + 10, r + 4);
    }

    // Texto
    fill(color(245));
    textSize(constrain(h * 0.28, 13, 22));
    textAlign(CENTER, CENTER);
    text(texto, x + w * 0.5, y + h * 0.5 - max(1, h * 0.02));

    popStyle();
  }

  // Devuelve [color borde, color brillo hover, color brillo normal]
  int[] resolverAcento() {
    if (texto == null) return new int[]{color(88,155,255), color(88,155,255,60), color(88,155,255,20)};
    String t = texto.toUpperCase();
    if (t.contains("SALIR"))
      return new int[]{color(255,102,122), color(255,102,122,70), color(255,102,122,28)};
    if (t.contains("CONFIRMAR")||t.contains("INSERTAR")||t.contains("SIGUIENTE")||t.contains("INICIAR")||t.contains("CONTINUAR"))
      return new int[]{color(84,221,189), color(84,221,189,72), color(84,221,189,28)};
    if (t.contains("CONTRASTE"))
      return new int[]{color(255,214,87), color(255,214,87,65), color(255,214,87,28)};
    if (t.contains("MANUAL"))
      return new int[]{color(180,126,255), color(180,126,255,65), color(180,126,255,28)};
    if (t.contains("REPORTE"))
      return new int[]{color(255,160,80), color(255,160,80,65), color(255,160,80,28)};
    return new int[]{color(88,155,255), color(88,155,255,60), color(88,155,255,22)};
  }

  boolean estaSobre() {
    return mouseX >= x && mouseX <= x+w && mouseY >= y && mouseY <= y+h;
  }
}
