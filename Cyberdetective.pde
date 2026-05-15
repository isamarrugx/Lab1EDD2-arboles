import processing.sound.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;


Juego juego;
PFont fuenteBase;
PFont fuenteTitulo;
SoundManager sonidoGlobal;

void setup() {
  size(1260, 752);
  surface.setTitle("CyberDetective v2.0");
  smooth(4);
  fuenteBase  = createFont("Verdana", 22);
  fuenteTitulo = createFont("Verdana Bold", 28);
  textFont(fuenteBase);
  imageMode(CORNER);
  rectMode(CORNER);
  textAlign(LEFT, TOP);
  sonidoGlobal = new SoundManager(this);
  sonidoGlobal.iniciarMusicaFondo();
  juego = new Juego(this);
}

void draw() {
  juego.actualizar();
  juego.dibujar();
}

void mousePressed() { juego.mousePressed(); }
void keyPressed()   { juego.keyPressed(key, keyCode); }
