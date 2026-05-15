class EstadoJugador {
  String nombre;
  int puntaje      = 0;
  int gravedad     = 0;
  int aciertos     = 0;
  int niveles      = 0;        

  EstadoJugador(String nombre) { this.nombre = nombre; }

  void reset() { puntaje = 0; gravedad = 0; aciertos = 0; niveles = 0; }

  String resumen() {
    return nombre + "\nPuntaje: " + puntaje + "\nNiveles: " + niveles + "\nGravedad acum.: " + gravedad;
  }
}

class SistemaMultijugador {
  boolean activo = false;

  EstadoJugador j1;
  EstadoJugador j2;

  
  int turnoActual = 0;

  
  int nivelMulti  = 1;
  boolean[] turnoTerminado = { false, false };

  
  String inputNombreJ1 = "Jugador 1";
  String inputNombreJ2 = "Jugador 2";
  boolean editandoJ1   = true;

  SistemaMultijugador() {
    j1 = new EstadoJugador("Jugador 1");
    j2 = new EstadoJugador("Jugador 2");
  }

  void iniciar() {
    activo = true;
    turnoActual = 0;
    nivelMulti  = 1;
    turnoTerminado[0] = false;
    turnoTerminado[1] = false;
    j1 = new EstadoJugador(inputNombreJ1.length() > 0 ? inputNombreJ1 : "Jugador 1");
    j2 = new EstadoJugador(inputNombreJ2.length() > 0 ? inputNombreJ2 : "Jugador 2");
    j1.reset();
    j2.reset();
  }

  void detener() { activo = false; turnoActual = 0; nivelMulti = 1; turnoTerminado[0] = false; turnoTerminado[1] = false; }

  EstadoJugador jugadorActual() { return turnoActual == 0 ? j1 : j2; }
  EstadoJugador jugadorInactivo() { return turnoActual == 0 ? j2 : j1; }

  
  boolean finalizarTurnoActual() {
    turnoTerminado[turnoActual] = true;
    if (turnoTerminado[0] && turnoTerminado[1]) return true;
    turnoActual = 1 - turnoActual;
    nivelMulti = 1;
    return false;
  }

  boolean juegoTerminado() { return turnoTerminado[0] && turnoTerminado[1]; }

  void prepararSiguienteJugador() {
    nivelMulti = 1;
  }

  EstadoJugador ganador() {
    if (j1.puntaje > j2.puntaje) return j1;
    if (j2.puntaje > j1.puntaje) return j2;
    return null; 
  }

  
  void dibujarConfiguracion(Juego g) {
    g.dibujarFondo("fondos/fondo_inicio.png", color(12, 16, 28));

    
    float pw = g.sx(780); float ph = g.sy(520);
    float px = width/2 - pw/2; float py = height/2 - ph/2;
    g.dibujarPanelMarco(px, py, pw, ph, true);

    // Título
    fill(g.colorTexto()); textAlign(CENTER, TOP);
    textSize(g.tx(36)); text("MODO MULTIJUGADOR", width/2, py + g.sy(30));
    textSize(g.tx(18)); fill(180, 210, 255);
    text("Dos detectives, cuatro niveles, un solo ganador", width/2, py + g.sy(78));

    
    fill(g.colorTexto()); textSize(g.tx(16)); textAlign(LEFT, TOP);
    String desc = "• " + (inputNombreJ1.length()>0?inputNombreJ1:"J1") + " juega el caso completo (niveles 1 al 4)\n" +
                  "• Luego " + (inputNombreJ2.length()>0?inputNombreJ2:"J2") + " juega su propia partida completa\n" +
                  "• Al final se comparan puntaje, aciertos y gravedad acumulada";
    text(desc, px + g.sx(40), py + g.sy(120), pw - g.sx(80), g.sy(120));

    
    dibujarCampoNombre(g, "Nombre Detective 1:", inputNombreJ1, editandoJ1,
                       px + g.sx(40), py + g.sy(260), pw/2 - g.sx(60), g.sy(52));
    dibujarCampoNombre(g, "Nombre Detective 2:", inputNombreJ2, !editandoJ1,
                       px + pw/2 + g.sx(20), py + g.sy(260), pw/2 - g.sx(60), g.sy(52));

    
    fill(180); textSize(g.tx(14)); textAlign(CENTER, CENTER);
    text("Clic en un campo para editarlo · TAB para cambiar de campo · ENTER para confirmar",
         width/2, py + g.sy(340));

    
    
    float bw = g.sx(220); float bh = g.sy(58);
    float bx = width/2 - bw - g.sx(20); float by = py + ph - g.sy(80);
    dibujarBotonSimple(g, bx, by, bw, bh, "INICIAR PARTIDA", color(84, 221, 189));

    
    bx = width/2 + g.sx(20);
    dibujarBotonSimple(g, bx, by, bw, bh, "VOLVER", color(255, 102, 122));
  }

  void dibujarCampoNombre(Juego g, String etiqueta, String valor, boolean activo,
                           float x, float y, float w, float h) {
    fill(g.colorTexto()); textAlign(LEFT, TOP); textSize(g.tx(15));
    text(etiqueta, x, y - g.sy(22));

    
    noStroke();
    fill(activo ? color(20, 40, 70, 230) : color(14, 22, 40, 200));
    stroke(activo ? color(84, 200, 255) : color(60, 100, 160));
    strokeWeight(activo ? 2.5 : 1.5);
    rect(x, y, w, h, 8);

    
    noStroke(); fill(g.colorTexto()); textAlign(LEFT, CENTER); textSize(g.tx(18));
    text(valor + (activo && (frameCount % 60 < 30) ? "|" : ""), x + 12, y + h/2);
  }

  void dibujarBotonSimple(Juego g, float x, float y, float w, float h, String txt, int col) {
    boolean hover = mouseX>=x && mouseX<=x+w && mouseY>=y && mouseY<=y+h;
    noStroke(); fill(0, 70); rect(x+3, y+5, w, h, 10);
    fill(col, hover ? 40 : 18); rect(x-1, y-1, w+2, h+2, 11);
    fill(hover ? color(18,30,50,245) : color(14,22,40,230));
    stroke(col); strokeWeight(hover ? 2.4 : 1.8); rect(x, y, w, h, 10);
    noStroke(); fill(g.colorTexto()); textAlign(CENTER, CENTER); textSize(g.tx(17));
    text(txt, x+w/2, y+h/2);
  }

  boolean clicIniciar(Juego g, float px, float py, float pw, float ph) {
    float bw = g.sx(220); float bh = g.sy(58);
    float bx = width/2 - bw - g.sx(20); float by = py + ph - g.sy(80);
    return mouseX>=bx && mouseX<=bx+bw && mouseY>=by && mouseY<=by+bh;
  }

  boolean clicVolver(Juego g, float px, float py, float pw, float ph) {
    float bw = g.sx(220); float bh = g.sy(58);
    float bx = width/2 + g.sx(20); float by = py + ph - g.sy(80);
    return mouseX>=bx && mouseX<=bx+bw && mouseY>=by && mouseY<=by+bh;
  }

  boolean clicCampoJ1(Juego g, float px, float py, float pw) {
    float fw = pw/2 - g.sx(60); float fh = g.sy(52);
    float fx = px + g.sx(40); float fy = py + g.sy(260);
    return mouseX>=fx && mouseX<=fx+fw && mouseY>=fy && mouseY<=fy+fh;
  }

  boolean clicCampoJ2(Juego g, float px, float py, float pw) {
    float fw = pw/2 - g.sx(60); float fh = g.sy(52);
    float fx = px + pw/2 + g.sx(20); float fy = py + g.sy(260);
    return mouseX>=fx && mouseX<=fx+fw && mouseY>=fy && mouseY<=fy+fh;
  }

  
  void dibujarMarcadorFinal(Juego g) {
    g.dibujarFondo("fondos/fondo_final.png", color(8, 12, 22));
    g.dibujarPanelMarco(g.sx(80), g.sy(60), width - g.sx(160), height - g.sy(120), true);

    fill(g.colorTexto()); textAlign(CENTER, TOP);
    textSize(g.tx(38)); text("CASO CERRADO", width/2, g.sy(86));
    textSize(g.tx(20)); fill(180, 210, 255);
    text("Multijugador · Resultados finales", width/2, g.sy(138));

    EstadoJugador gan = ganador();

    
    dibujarTarjetaJugador(g, j1, gan == j1, g.sx(130), g.sy(190), g.sx(450), g.sy(330), 0);
    
    dibujarTarjetaJugador(g, j2, gan == j2, g.sx(680), g.sy(190), g.sx(450), g.sy(330), 1);

    int diferencia = abs(j1.puntaje - j2.puntaje);
    String comparativa = j1.nombre + ": " + j1.puntaje + " puntos   vs   " + j2.nombre + ": " + j2.puntaje + " puntos";

    fill(180, 220, 255);
    textAlign(CENTER, CENTER);
    textSize(g.tx(20));
    text(comparativa, width/2, g.sy(552));

    textSize(g.tx(25));
    if (gan == null) {
      fill(230, 215, 120);
      text("¡EMPATE! Ambos detectives cerraron el caso con el mismo puntaje.", width/2, g.sy(595));
      fill(g.colorTexto());
      textSize(g.tx(16));
      text("Excelente trabajo de los dos. La investigación quedó completamente resuelta.", width/2, g.sy(628));
    } else {
      fill(100, 255, 180);
      text("¡FELICITACIONES, " + gan.nombre.toUpperCase() + "!", width/2, g.sy(592));
      fill(g.colorTexto());
      textSize(g.tx(16));
      text("Ganó por " + diferencia + " puntos y obtuvo el mejor desempeño de la investigación.", width/2, g.sy(624));
    }

    
    float bw = g.sx(240); float bh = g.sy(58);
    dibujarBotonSimple(g, width/2 - bw/2, g.sy(662), bw, bh, "NUEVO JUEGO", color(84, 221, 189));
  }

  void dibujarTarjetaJugador(Juego g, EstadoJugador jug, boolean esGanador,
                               float x, float y, float w, float h, int avatarTipo) {
    g.dibujarPanelMarco(x, y, w, h, esGanador);

    if (esGanador) {
      fill(255, 220, 80, 40); noStroke(); rect(x, y, w, h, 18);
      fill(255, 220, 80); textAlign(CENTER, TOP); textSize(g.tx(15));
      text("★ DETECTIVE PRINCIPAL ★", x + w/2, y + g.sy(12));
    }

    
    float avR = h * 0.2;
    float avCX = x + w/2;
    float avCY = y + h * 0.3;
    if (avatarTipo == 0) dibujarAlex(avCX, avCY, avR, false);
    else                 dibujarValeriaCodigo(avCX, avCY, avR, false, false);

    
    fill(g.colorTexto()); textAlign(CENTER, TOP); textSize(g.tx(22));
    text(jug.nombre, x + w/2, y + h * 0.55);

    
    textSize(g.tx(17)); fill(180, 210, 255);
    text("Puntaje: " + jug.puntaje, x + w/2, y + h * 0.66);
    text("Niveles: " + jug.niveles + "  |  Aciertos: " + jug.aciertos, x + w/2, y + h * 0.77);
    text("Gravedad acum.: " + jug.gravedad, x + w/2, y + h * 0.87);
  }

  
  String etiquetaTurno() {
    if (!activo) return "";
    return "Turno: " + jugadorActual().nombre;
  }
}
