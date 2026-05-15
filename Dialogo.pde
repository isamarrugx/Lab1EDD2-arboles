final int HABLANTE_NARRADOR = 0;
final int HABLANTE_ALEX     = 1;
final int HABLANTE_VALERIA  = 2;

//  Linea de Diálogo
class LineaDialogo {
  int hablante;
  String texto;
  LineaDialogo(int h, String t) { hablante = h; texto = t; }
}

//  Diálogo
class SistemaDialogo {
  ArrayList<LineaDialogo> lineas;
  int indiceActual = 0;
  int charMostrado = 0;
  int velocidadChar = 2;        
  int frameContador = 0;
  boolean activo = false;
  boolean completado = false;   
  boolean esperandoInput = false;

  // Flecha indicadora
  float flechaAlpha = 0;
  boolean flechaSubiendo = true;

  SistemaDialogo() {
    lineas = new ArrayList<LineaDialogo>();
  }

  void iniciar(ArrayList<LineaDialogo> nuevasLineas) {
    lineas       = nuevasLineas;
    indiceActual = 0;
    charMostrado = 0;
    frameContador = 0;
    activo       = true;
    completado   = false;
    esperandoInput = false;
  }

  void actualizar() {
    if (!activo || completado) return;

    // Animación de flecha
    if (flechaSubiendo) { flechaAlpha += 8; if (flechaAlpha >= 255) flechaSubiendo = false; }
    else                { flechaAlpha -= 8; if (flechaAlpha <=   0) flechaSubiendo = true;  }

    if (esperandoInput) return;

    // Typewriter
    String textoActual = lineas.get(indiceActual).texto;
    frameContador++;
    if (frameContador >= velocidadChar) {
      frameContador = 0;
      if (charMostrado < textoActual.length()) {
        charMostrado++;
      } else {
        esperandoInput = true;
      }
    }
  }

  void avanzar() {
    if (!activo || completado) return;
    String textoActual = lineas.get(indiceActual).texto;
    if (!esperandoInput && charMostrado < textoActual.length()) {
      // Completar texto instantáneamente
      charMostrado = textoActual.length();
      esperandoInput = true;
      return;
    }
    // Siguiente línea
    indiceActual++;
    if (indiceActual >= lineas.size()) {
      completado = true;
      activo     = false;
    } else {
      charMostrado   = 0;
      frameContador  = 0;
      esperandoInput = false;
    }
  }

  void dibujar(float sx, float sy, float sw, float sh) {
    if (!activo && !completado) return;
    if (indiceActual >= lineas.size()) return;

    LineaDialogo linea = lineas.get(indiceActual);
    String textoVisible = linea.texto.substring(0, min(charMostrado, linea.texto.length()));

    pushStyle();

    // ── Panel principal ──────────────────────────────────────────────────
    float panelH = sh * 0.22;
    float panelY = sy + sh - panelH - sh * 0.02;
    float panelX = sx + sw * 0.01;
    float panelW = sw * 0.98;
    float panelR = 18;

    // Sombra
    noStroke(); fill(0, 130);
    rect(panelX + 5, panelY + 7, panelW, panelH, panelR);

    // Fondo panel
    stroke(resolverColorBorde(linea.hablante)); strokeWeight(2.2);
    fill(10, 16, 30, 240);
    rect(panelX, panelY, panelW, panelH, panelR);

    // Franja de color según hablante
    noStroke();
    fill(resolverColorBorde(linea.hablante), 30);
    rect(panelX, panelY, panelW, panelH * 0.3, panelR, panelR, 0, 0);

    // ── Avatar pequeño ───────────────────────────────────────────────────
    float avatarSize = panelH * 0.72;
    float avatarX    = panelX + panelH * 0.14;
    float avatarY    = panelY + panelH * 0.14;

    if (linea.hablante == HABLANTE_ALEX) {
      dibujarAlex(avatarX + avatarSize/2, avatarY + avatarSize/2, avatarSize * 0.92, esperandoInput ? false : true);
    } else if (linea.hablante == HABLANTE_VALERIA) {
      dibujarValeriaCodigo(avatarX + avatarSize/2, avatarY + avatarSize/2, avatarSize * 0.92, false, !esperandoInput);
    } else {
      // Narrador: icono estilizado
      fill(resolverColorBorde(HABLANTE_NARRADOR), 40);
      noStroke();
      ellipse(avatarX + avatarSize/2, avatarY + avatarSize/2, avatarSize, avatarSize);
      fill(resolverColorBorde(HABLANTE_NARRADOR));
      textAlign(CENTER, CENTER); textSize(avatarSize * 0.38);
      text("★", avatarX + avatarSize/2, avatarY + avatarSize/2 - 2);
    }

    // ── Nombre del hablante ───────────────────────────────────────────────
    float textStartX = avatarX + avatarSize + panelH * 0.1;
    float textW      = panelW - avatarSize - panelH * 0.25;

    fill(resolverColorBorde(linea.hablante));
    textAlign(LEFT, TOP); textSize(constrain(panelH * 0.16, 13, 20));
    text(resolverNombre(linea.hablante), textStartX, panelY + panelH * 0.08);

    // ── Texto del diálogo ─────────────────────────────────────────────────
    fill(240); textSize(constrain(panelH * 0.14, 12, 18));
    textLeading(constrain(panelH * 0.19, 16, 24));
    text(textoVisible, textStartX, panelY + panelH * 0.28, textW, panelH * 0.62);

    // ── Indicador de continuar ────────────────────────────────────────────
    if (esperandoInput) {
      float fX = panelX + panelW - 38;
      float fY = panelY + panelH - 22;
      noStroke(); fill(resolverColorBorde(linea.hablante), flechaAlpha);
      triangle(fX, fY - 10, fX + 14, fY + 2, fX + 28, fY - 10);
      textSize(10); fill(resolverColorBorde(linea.hablante), flechaAlpha * 0.7);
      textAlign(RIGHT, CENTER); text("CLIC / ESPACIO", fX - 4, fY - 4);
    }

    popStyle();
  }

  int resolverColorBorde(int hablante) {
    if (hablante == HABLANTE_ALEX)    return color(84, 200, 255);
    if (hablante == HABLANTE_VALERIA) return color(255, 160, 200);
    return color(200, 180, 120);  // Narrador: dorado suave
  }

  String resolverNombre(int hablante) {
    if (hablante == HABLANTE_ALEX)    return "ALEX – Detective Digital";
    if (hablante == HABLANTE_VALERIA) return "VALERIA";
    return "NARRADOR";
  }
}

// ─── Diálogos predefinidos de la narrativa ───────────────────────────────────
ArrayList<LineaDialogo> dialogo(LineaDialogo... args) {
  ArrayList<LineaDialogo> lista = new ArrayList<LineaDialogo>();
  for (LineaDialogo l : args) lista.add(l);
  return lista;
}
LineaDialogo L(int h, String t) { return new LineaDialogo(h, t); }

ArrayList<LineaDialogo> getDialogoContexto() {
  return dialogo(
    L(HABLANTE_NARRADOR, "En NetCity, los casos de ciberacoso se han multiplicado. Una estudiante necesita ayuda."),
    L(HABLANTE_VALERIA,  "Alguien me está atacando en redes desde hace semanas. Primero fueron insultos, ahora es peor..."),
    L(HABLANTE_ALEX,     "Soy el Detective Alex. Uso un sistema especial: un Árbol AVL donde registro cada delito según su gravedad."),
    L(HABLANTE_ALEX,     "Cada incidente que investigues se convierte en un nodo. El árbol se autoequilibra para mostrar la escalada del acoso."),
    L(HABLANTE_NARRADOR, "Tu misión: analizar las evidencias, clasificar cada delito y reconstruir el árbol de pruebas para identificar al agresor.")
  );
}

ArrayList<LineaDialogo> getDialogoNivel1() {
  return dialogo(
    L(HABLANTE_ALEX,     "Primer caso: Valeria recibe mensajes directos en una red social. Analiza la conversación."),
    L(HABLANTE_VALERIA,  "Son mensajes que llegan de madrugada. Unos me hacen daño y otros parecen normales."),
    L(HABLANTE_ALEX,     "Revisa la conversación con cuidado. Primero identifica la evidencia más fuerte y luego clasifica el caso."),
    L(HABLANTE_NARRADOR, "Analiza el chat y toma una decisión.")
  );
}

ArrayList<LineaDialogo> getDialogoNivel2() {
  return dialogo(
    L(HABLANTE_ALEX,     "Segundo caso: un rumor sobre Valeria se vuelve viral. Pero ¿cuál fue la publicación original?"),
    L(HABLANTE_VALERIA,  "Vi que todos lo compartían, pero nadie sabe quién lo inició. ¿Eso no importa?"),
    L(HABLANTE_ALEX,     "El origen importa más que las réplicas. Sigue el rastro de dónde empezó todo."),
    L(HABLANTE_NARRADOR, "Identifica la publicación inicial y clasifica el caso.")
  );
}

ArrayList<LineaDialogo> getDialogoNivel3() {
  return dialogo(
    L(HABLANTE_ALEX,     "Tercer caso: encontramos una cuenta falsa que usa la identidad de Valeria."),
    L(HABLANTE_VALERIA,  "¡Esa cuenta no soy yo! Usa mi foto y un nombre casi igual. Ya me escribieron preguntando por esos mensajes que yo nunca envié."),
    L(HABLANTE_ALEX,     "Necesitamos reunir señales claras: identidad duplicada, alias imitador o datos copiados."),
    L(HABLANTE_NARRADOR, "Selecciona los elementos que sirven como evidencia.")
  );
}

ArrayList<LineaDialogo> getDialogoNivel4() {
  return dialogo(
    L(HABLANTE_ALEX,     "Caso final: esto no es un atacante solitario. Hay una red coordinada de cuentas atacando a Valeria."),
    L(HABLANTE_VALERIA,  "¿Una red? ¿Varias personas? Pensé que era solo una..."),
    L(HABLANTE_ALEX,     "Busca patrones repetidos entre las cuentas: horario, lenguaje y conexiones."),
    L(HABLANTE_NARRADOR, "Relaciona las cuentas involucradas y clasifica el caso.")
  );
}

ArrayList<LineaDialogo> getDialogoArbol() {
  return dialogo(
    L(HABLANTE_ALEX,     "Excelente trabajo. Aquí está el Árbol AVL con todos los casos que registraste."),
    L(HABLANTE_ALEX,     "Cada nodo tiene una gravedad calculada según tus decisiones. El árbol se balanceó automáticamente."),
    L(HABLANTE_NARRADOR, "Haz clic en un nodo para ver sus detalles. Cuando estés listo, explora los recorridos del árbol.")
  );
}

ArrayList<LineaDialogo> getDialogoReporte() {
  return dialogo(
    L(HABLANTE_ALEX,     "El caso está cerrado. El árbol AVL refleja la escalada del acoso, de menor a mayor gravedad."),
    L(HABLANTE_VALERIA,  "Gracias. Ahora hay evidencias reales y están organizadas. Eso cambia todo."),
    L(HABLANTE_NARRADOR, "El reporte final sintetiza todos los delitos, leyes y penas aplicables. La investigación concluye.")
  );
}

ArrayList<LineaDialogo> getDialogoMultijugador() {
  return dialogo(
    L(HABLANTE_NARRADOR, "Modo Multijugador: dos detectives compiten por el caso. Cada uno juega la investigación completa por turnos."),
    L(HABLANTE_ALEX,     "Quien acumule más puntaje al final gana el rango de Detective Principal."),
    L(HABLANTE_NARRADOR, "¡Que comience la competencia!")
  );
}
