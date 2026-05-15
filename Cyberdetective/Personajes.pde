float _animT = 0;

class Personaje {
  AssetManager assets;
  String[] rutasSkins;
  String etiqueta;

  Personaje(AssetManager assets, String[] rutasSkins, String etiqueta) {
    this.assets = assets;
    this.rutasSkins = rutasSkins;
    this.etiqueta = etiqueta;
    precargar();
  }

  void precargar() {
    for (int i = 0; i < rutasSkins.length; i++) {
      assets.get(rutasSkins[i]);
    }
  }

  PImage getSkin(int indice) {
    if (rutasSkins == null || rutasSkins.length == 0) return null;
    int idx = constrain(indice, 0, rutasSkins.length - 1);
    return assets.get(rutasSkins[idx]);
  }

  void dibujar(float cx, float cy, float radio, int skinIndex, boolean hablando) {
    pushStyle();

    float resp = sin(_animT * 1.05) * 1.8;
    float escala = radio / 60.0;
    float maxW = radio * 1.7;
    float maxH = radio * 2.2;
    float drawW = maxW;
    float drawH = maxH;

    PImage skin = getSkin(skinIndex);
    if (skin != null && skin.width > 0 && skin.height > 0) {
      float escalaSprite = min(maxW / skin.width, maxH / skin.height);
      drawW = skin.width * escalaSprite;
      drawH = skin.height * escalaSprite;
    }

    // sombra suave
    noStroke();
    fill(0, 45);
    ellipse(cx, cy + drawH * 0.62 + resp, drawW * 0.92, 14 * escala);

    if (skin != null && skin.width > 0 && skin.height > 0) {
      imageMode(CENTER);
      image(skin, cx, cy + resp, drawW, drawH);
      imageMode(CORNER);
    } else {
      dibujarFallback(cx, cy + resp, drawW, drawH);
    }

    if (hablando) {
      noFill();
      stroke(120, 220, 255, 120);
      strokeWeight(max(1, 2 * escala));
      arc(cx, cy + drawH * 0.42 + resp, drawW * 0.18, drawH * 0.07 + abs(sin(_animT * 6)) * 6 * escala, 0, PI);
    }

    popStyle();
  }

  void dibujarEnMarco(float x, float y, float w, float h, int skinIndex) {
    float cx = x + w * 0.5;
    float cy = y + h * 0.50;
    float radio = min(w, h) * 0.36;
    dibujar(cx, cy, radio, skinIndex, false);
  }

  void dibujarFallback(float cx, float cy, float w, float h) {
    rectMode(CENTER);
    fill(42, 58, 86, 220);
    stroke(110, 180, 255, 120);
    strokeWeight(2);
    rect(cx, cy, w * 0.8, h * 0.9, 16);
    noStroke();
    fill(220);
    textAlign(CENTER, CENTER);
    textSize(max(12, h * 0.10));
    text(etiqueta, cx, cy);
    rectMode(CORNER);
    textAlign(LEFT, TOP);
  }
}

void actualizarPersonajes() {
  _animT += 0.04;
}

void dibujarAlex(float cx, float cy, float radio, boolean hablando) {
  if (juego != null && juego.personajeDetective != null) {
    juego.personajeDetective.dibujar(cx, cy, radio, juego.skinDetective, hablando);
  }
}

void dibujarValeriaCodigo(float cx, float cy, float radio, boolean preocupada, boolean hablando) {
  if (juego != null && juego.personajeValeria != null) {
    juego.personajeValeria.dibujar(cx, cy, radio, juego.skinValeria, hablando);
  }
}

void dibujarAvatarValeria(float x, float y, float w, float h, boolean preocupada) {
  juego.dibujarPanelMarco(x, y, w, h, false);
  if (juego != null && juego.personajeValeria != null) {
    juego.personajeValeria.dibujarEnMarco(x, y, w, h, juego.skinValeria);
  }
}
