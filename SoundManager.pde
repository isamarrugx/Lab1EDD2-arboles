import processing.sound.*;

class SoundManager {
  PApplet p;
  HashMap<String, SoundFile> sonidos = new HashMap<String, SoundFile>();
  SoundFile musicaFondo;
  boolean disponible = true;
  float volumenMusica = 0.22f;
  float volumenClicks = 0.75f;
  float volumenEfectos = 0.75f;

  SoundManager(PApplet parent) {
    this.p = parent;
    try {
      cargar("click",      "sonidos/ui_click.wav");
      cargar("hover",      "sonidos/ui_hover.wav");
      cargar("correcto",   "sonidos/correcto.wav");
      cargar("incorrecto", "sonidos/incorrecto.wav");
      cargar("parcial",    "sonidos/parcial.wav");
      cargar("insertar",   "sonidos/insertar_nodo.wav");
      cargar("rotacion",   "sonidos/rotacion_avl.wav");
      cargar("nivel",      "sonidos/subir_nivel.wav");
      cargar("reporte",    "sonidos/reporte_final.wav");
      cargarMusica("sonidos/musica_fondo.wav");
    } catch(Exception e) {
      disponible = false;
      println("SoundManager desactivado: " + e.getMessage());
    }
  }

  void cargar(String clave, String ruta) {
    try { sonidos.put(clave, new SoundFile(p, ruta)); }
    catch(Exception e) { /* si el archivo no existe, el juego continúa */ }
  }

  void cargarMusica(String ruta) {
    try {
      musicaFondo = new SoundFile(p, ruta);
      if (musicaFondo != null) musicaFondo.amp(volumenMusica);
    } catch(Exception e) {
      musicaFondo = null;
    }
  }

  void iniciarMusicaFondo() {
    if (!disponible || musicaFondo == null) return;
    try {
      musicaFondo.stop();
      musicaFondo.loop();
    } catch(Exception e) {
      println("No se pudo iniciar la música de fondo: " + e.getMessage());
    }
  }

  void detenerMusicaFondo() {
    if (musicaFondo == null) return;
    try { musicaFondo.stop(); } catch(Exception e) {}
  }

  void ajustarVolumenMusica(float v) {
    volumenMusica = constrain(v, 0.0f, 1.0f);
    if (musicaFondo != null) {
      try { musicaFondo.amp(volumenMusica); } catch(Exception e) {}
    }
  }

  void ajustarVolumenClicks(float v) {
    volumenClicks = constrain(v, 0.0f, 1.0f);
  }

  void ajustarVolumenEfectos(float v) {
    volumenEfectos = constrain(v, 0.0f, 1.0f);
  }

  float getVolumenMusica() { return volumenMusica; }
  float getVolumenClicks() { return volumenClicks; }
  float getVolumenEfectos() { return volumenEfectos; }

  void reproducir(String clave) {
    if (!disponible || !sonidos.containsKey(clave)) return;
    try {
      SoundFile s = sonidos.get(clave);
      if (s != null) {
        s.stop();
        float amp = (clave.equals("click") || clave.equals("hover")) ? volumenClicks : volumenEfectos;
        s.amp(amp);
        s.play();
      }
    } catch(Exception e) {
      println("Sonido '" + clave + "': " + e.getMessage());
    }
  }
}
