String[] barajar(String[] original) {
  String[] copia = new String[original.length];
  arrayCopy(original, copia);
  for (int i = copia.length - 1; i > 0; i--) {
    int j = int(random(i + 1));
    String temp = copia[i]; copia[i] = copia[j]; copia[j] = temp;
  }
  return copia;
}

String[] seleccionarTextosAleatorios(String[] banco, int cantidad) {
  String[] mezclado = barajar(banco);
  int limite = min(cantidad, mezclado.length);
  String[] salida = new String[limite];
  for (int i = 0; i < limite; i++) salida[i] = mezclado[i];
  return salida;
}


ArrayList<String>  feedbackActivo  = new ArrayList<String>();
ArrayList<Integer> feedbackColors  = new ArrayList<Integer>();
ArrayList<Integer> feedbackTimers  = new ArrayList<Integer>();

void mostrarFeedback(String msg, int c) {
  feedbackActivo.add(msg);
  feedbackColors.add(c);
  feedbackTimers.add(180);
}

void dibujarFeedback(PApplet p) {
  for (int i = feedbackActivo.size() - 1; i >= 0; i--) {
    int t = feedbackTimers.get(i);
    if (t <= 0) { feedbackActivo.remove(i); feedbackColors.remove(i); feedbackTimers.remove(i); continue; }
    String msg = feedbackActivo.get(i);
    int c = feedbackColors.get(i);
    float alpha = min(255, t * 5);
    // Fondo semiopaco para legibilidad
    p.noStroke();
    p.fill(10, 16, 28, alpha * 0.7);
    float tw = p.textWidth(msg) + 24;
    p.rect(p.width/2 - tw/2, p.height - 128 - (feedbackActivo.size()-1-i)*38 - 14, tw, 26, 8);
    p.fill(c, alpha);
    p.textAlign(p.CENTER, p.CENTER);
    p.textSize(20);
    p.text(msg, p.width/2, p.height - 115 - (feedbackActivo.size()-1-i)*38);
    feedbackTimers.set(i, t - 1);
  }
}


void reproducirSonido(String clave) {
  if (sonidoGlobal != null) sonidoGlobal.reproducir(clave);
}


int getColor(int id) {
  switch(id) {
    case 1:  return color(34, 40, 49);
    case 2:  return color(0, 173, 181);
    case 3:  return color(238, 238, 238);
    case 4:  return color(255, 87, 34);
    case 5:  return color(255);
    case 6:  return color(100, 255, 180);
    case 7:  return color(255, 80, 80);
    case 8:  return color(180, 200, 200);
    default: return color(200);
  }
}
