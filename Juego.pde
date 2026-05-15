class Juego {
  PApplet p;
  AssetManager assets;
  ArbolAVL arbol;

  
  final int PANTALLA_INICIO        = 0;
  final int PANTALLA_COMO_JUGAR    = 1;
  final int PANTALLA_NIVEL_1       = 2;
  final int PANTALLA_RESULTADO_1   = 3;
  final int PANTALLA_NIVEL_2       = 4;
  final int PANTALLA_RESULTADO_2   = 5;
  final int PANTALLA_NIVEL_3       = 6;
  final int PANTALLA_RESULTADO_3   = 7;
  final int PANTALLA_NIVEL_4       = 8;
  final int PANTALLA_RESULTADO_4   = 9;
  final int PANTALLA_ARBOL         = 10;
  final int PANTALLA_RECORRIDOS    = 11;
  final int PANTALLA_REPORTE       = 12;
  final int PANTALLA_MANUAL        = 13;
  final int PANTALLA_CONTEXTO      = 14;
  final int PANTALLA_MULTI_CONFIG  = 15;   
  final int PANTALLA_MULTI_FIN     = 16;   
  final int PANTALLA_CAMBIO_TURNO  = 17;   
  final int PANTALLA_CONFIG_AUDIO = 18;   
  final int PANTALLA_CONFIG_SKINS = 19;   

  
  final float BASE_W = 1440.0;
  final float BASE_H = 860.0;
  float sx(float x) { return x * width  / BASE_W; }
  float sy(float y) { return y * height / BASE_H; }
  float ss(float v) { return min(width / BASE_W, height / BASE_H) * v; }
  int   tx(float t) { return max(12, round(ss(t))); }

  
  int pantallaActual  = PANTALLA_INICIO;
  boolean altoContraste   = false;
  boolean mostrarSubtitulos = false;

  int nivelActual     = 1;
  int puntaje         = 0;
  int casosResueltos  = 0;
  int gravedadTotal   = 0;
  String agresorIdentificado  = "Pendiente";
  String detectiveActivo      = "Alex";
  String sospechosoPrincipal  = "Pendiente";
  String reporteFinalGenerado = "";
  String reporteFinalVisible  = "";
  boolean[] casoInsertado     = new boolean[5];

  ArrayList<Caso> casosRegistrados;
  String subtituloActual = "";

  
  OpcionInteractiva[] opcionesNivel1;
  int     indiceCorrectoNivel1    = -1;
  int     indiceSeleccionadoNivel1 = -1;
  String  clasificacionElegidaNivel1 = "";
  int     gravedadNivel1  = 0;
  String  resultadoNivel1 = "";

  OpcionInteractiva[] opcionesNivel2;
  int     indiceCorrectoNivel2    = -1;
  int     indiceSeleccionadoNivel2 = -1;
  String  clasificacionElegidaNivel2 = "";
  int     gravedadNivel2  = 0;
  String  resultadoNivel2 = "";

  OpcionInteractiva[] opcionesNivel3;
  boolean[] seleccionPerfil   = new boolean[3];
  String  clasificacionElegidaNivel3 = "";
  int     gravedadNivel3  = 0;
  String  resultadoNivel3 = "";

  OpcionInteractiva[] opcionesNivel4;
  boolean[] seleccionCuentas  = new boolean[4];
  String  clasificacionElegidaNivel4 = "";
  int     gravedadNivel4  = 0;
  String  resultadoNivel4 = "";

  String  explicacionNivel1 = "";
  String  explicacionNivel2 = "";
  String  explicacionNivel3 = "";
  String  explicacionNivel4 = "";
  String  pistaNivel1 = "";
  String  pistaNivel2 = "";
  String  pistaNivel3 = "";
  String  pistaNivel4 = "";
  boolean pistaVisible  = false;
  String  pistaMostrada = "";

  String recorridoMostrado   = "";
  String tipoRecorridoActual = "";

  BotonImagen btnIniciar, btnComoJugar, btnSalir, btnMultijugador, btnSkins;
  BotonImagen btnSkinDetective, btnSkinValeria;
  BotonImagen btnContinuar, btnVolver;
  BotonImagen btnManual, btnAltoContraste, btnConfig;
  BotonImagen btnInsertarCaso, btnReporte;
  BotonImagen btnInorden, btnPreorden, btnPostorden;
  BotonImagen btnInjuria, btnCalumnia, btnSuplantacion;
  BotonImagen btnConfirmar, btnSiguiente;

  SistemaDialogo     dialogo;
  SistemaTransicion  transicion;
  SistemaMultijugador multi;

  int pantallaPrevConfig = PANTALLA_INICIO;
  int skinDetective = 0;
  int skinValeria = 0;
  Personaje personajeDetective;
  Personaje personajeValeria;

  boolean dialogoMostrandose = false;
  int pantallaTrasDialogo    = -1;

  float[] particX, particY, particV, particA;
  int NUM_PARTIC = 60;

  Juego(PApplet parent) {
    this.p  = parent;
    assets  = new AssetManager(parent);
    arbol   = new ArbolAVL();
    casosRegistrados = new ArrayList<Caso>();

    dialogo    = new SistemaDialogo();
    transicion = new SistemaTransicion();
    multi      = new SistemaMultijugador();

    inicializarPersonajes();
    inicializarBotones();
    inicializarParticulas();
    reiniciarPartida();
  }


  void inicializarPersonajes() {
    personajeDetective = new Personaje(
      assets,
      new String[]{
        "personajes/detective_skin1.png",
        "personajes/detective_skin2.png"
      },
      "Detective"
    );

    personajeValeria = new Personaje(
      assets,
      new String[]{
        "personajes/valeria_skin1.png",
        "personajes/valeria_skin2.png"
      },
      "Valeria"
    );
  }

  void inicializarParticulas() {
    particX = new float[NUM_PARTIC];
    particY = new float[NUM_PARTIC];
    particV = new float[NUM_PARTIC];
    particA = new float[NUM_PARTIC];
    for (int i = 0; i < NUM_PARTIC; i++) {
      particX[i] = random(width);
      particY[i] = random(height);
      particV[i] = random(0.2, 0.8);
      particA[i] = random(30, 100);
    }
  }

  void actualizarParticulas() {
    for (int i = 0; i < NUM_PARTIC; i++) {
      particY[i] -= particV[i];
      if (particY[i] < 0) { particY[i] = height; particX[i] = random(width); }
    }
  }

  void dibujarParticulas() {
    noStroke();
    for (int i = 0; i < NUM_PARTIC; i++) {
      fill(100, 180, 255, particA[i]);
      ellipse(particX[i], particY[i], 2, 2);
    }
  }

  void inicializarBotones() {
    btnIniciar     = new BotonImagen(sx(510), sy(380), sx(360), sy(88), "", "", "INICIAR");
    btnComoJugar   = new BotonImagen(sx(510), sy(488), sx(360), sy(88), "", "", "CÓMO JUGAR");
    btnMultijugador= new BotonImagen(sx(510), sy(596), sx(360), sy(88), "", "", "MULTIJUGADOR");
    btnSalir       = new BotonImagen(sx(510), sy(704), sx(360), sy(88), "", "", "SALIR");
    btnSkins       = new BotonImagen(sx(510), sy(704), sx(360), sy(88), "", "", "SKINS");
    btnSkinDetective = new BotonImagen(sx(205), sy(650), sx(260), sy(62), "", "", "DETECTIVE");
    btnSkinValeria   = new BotonImagen(sx(795), sy(650), sx(260), sy(62), "", "", "VALERIA");

    btnContinuar   = new BotonImagen(sx(1040), sy(760), sx(270), sy(72), "", "", "CONTINUAR");
    btnVolver      = new BotonImagen(sx(80),   sy(780), sx(210), sy(72), "", "", "VOLVER");

    btnManual        = new BotonImagen(sx(1280), sy(14), sx(120), sy(60), "", "", "MANUAL");
    btnAltoContraste = new BotonImagen(sx(1050), sy(14), sx(210), sy(60), "", "", "CONTRASTE");
    btnConfig        = new BotonImagen(sx(925), sy(14), sx(105), sy(60), "", "", "AUDIO");

    
    btnInsertarCaso = new BotonImagen(sx(1060), sy(760), sx(290), sy(72), "", "", "INSERTAR CASO");
    btnReporte      = new BotonImagen(sx(1170), sy(780), sx(180), sy(60), "", "", "REPORTE");
    btnInorden      = new BotonImagen(sx(250), sy(760), sx(220), sy(68), "", "", "INORDEN");
    btnPreorden     = new BotonImagen(sx(500), sy(760), sx(220), sy(68), "", "", "PREORDEN");
    btnPostorden    = new BotonImagen(sx(750), sy(760), sx(220), sy(68), "", "", "POSTORDEN");

    
    btnInjuria     = new BotonImagen(sx(130), sy(700), sx(250), sy(72), "", "", "INJURIA");
    btnCalumnia    = new BotonImagen(sx(410), sy(700), sx(250), sy(72), "", "", "CALUMNIA");
    btnSuplantacion= new BotonImagen(sx(690), sy(700), sx(250), sy(72), "", "", "SUPLANTACIÓN");
    btnConfirmar   = new BotonImagen(sx(1080), sy(700), sx(270), sy(72), "", "", "CONFIRMAR");
    btnSiguiente   = new BotonImagen(sx(1110), sy(780), sx(250), sy(72), "", "", "SIGUIENTE");
  }

  void reiniciarPartida() {
    nivelActual    = 1;
    puntaje        = 0;
    casosResueltos = 0;
    gravedadTotal  = 0;
    agresorIdentificado  = "Pendiente";
    sospechosoPrincipal  = "Pendiente";
    detectiveActivo      = "Alex";
    reporteFinalGenerado = "";
    reporteFinalVisible  = "";
    for (int i = 0; i < casoInsertado.length; i++) casoInsertado[i] = false;
    arbol = new ArbolAVL();
    casosRegistrados.clear();
    prepararNivel1();
    prepararNivel2();
    prepararNivel3();
    prepararNivel4();
    dialogoMostrandose = false;
    pistaVisible = false;
    pistaMostrada = "";
    pantallaActual = PANTALLA_INICIO;
  }

  void actualizar() {
    actualizarPersonajes();
    actualizarParticulas();

    if (transicion.estaActivo()) {
      if (transicion.actualizar()) {
        if (transicion.pantallaSiguiente >= 0) {
          pantallaActual = transicion.pantallaSiguiente;
          transicion.pantallaSiguiente = -1;
        }
      }
    }

    
    if (dialogoMostrandose) {
      dialogo.actualizar();
      if (dialogo.completado) {
        dialogoMostrandose = false;
        if (pantallaTrasDialogo >= 0) {
          irAPantalla(pantallaTrasDialogo);
          pantallaTrasDialogo = -1;
        }
      }
    }

    
    btnManual.actualizar();        btnAltoContraste.actualizar(); btnConfig.actualizar();
    btnVolver.actualizar();        btnContinuar.actualizar();
    btnSiguiente.actualizar();     btnConfirmar.actualizar();
    btnInsertarCaso.actualizar();  btnReporte.actualizar();
    btnInorden.actualizar();       btnPreorden.actualizar();
    btnPostorden.actualizar();
    btnIniciar.actualizar();       btnComoJugar.actualizar();
    btnSalir.actualizar();         btnMultijugador.actualizar(); btnSkins.actualizar();
    btnSkinDetective.actualizar(); btnSkinValeria.actualizar();
    btnInjuria.actualizar();       btnCalumnia.actualizar();
    btnSuplantacion.actualizar();

    if (pantallaActual == PANTALLA_NIVEL_1 && opcionesNivel1 != null)
      for (OpcionInteractiva op : opcionesNivel1) op.actualizar();
    if (pantallaActual == PANTALLA_NIVEL_2 && opcionesNivel2 != null)
      for (OpcionInteractiva op : opcionesNivel2) op.actualizar();
    if (pantallaActual == PANTALLA_NIVEL_3 && opcionesNivel3 != null)
      for (OpcionInteractiva op : opcionesNivel3) op.actualizar();
    if (pantallaActual == PANTALLA_NIVEL_4 && opcionesNivel4 != null)
      for (OpcionInteractiva op : opcionesNivel4) op.actualizar();

    normalizarBotonesBase();
  }

  void irAPantalla(int pantalla) {
    transicion.iniciarFade(pantalla);
  }

  void irAPantallaConDialogo(int pantalla, ArrayList<LineaDialogo> lineas) {
    dialogoMostrandose = true;
    pantallaTrasDialogo = pantalla;
    dialogo.iniciar(lineas);
  }

  void dibujar() {
    switch(pantallaActual) {
      case PANTALLA_INICIO:       dibujarInicio();                              break;
      case PANTALLA_COMO_JUGAR:   dibujarComoJugar();                          break;
      case PANTALLA_NIVEL_1:      dibujarNivel1();                             break;
      case PANTALLA_RESULTADO_1:  dibujarResultadoNivel(1, resultadoNivel1, gravedadNivel1); break;
      case PANTALLA_NIVEL_2:      dibujarNivel2();                             break;
      case PANTALLA_RESULTADO_2:  dibujarResultadoNivel(2, resultadoNivel2, gravedadNivel2); break;
      case PANTALLA_NIVEL_3:      dibujarNivel3();                             break;
      case PANTALLA_RESULTADO_3:  dibujarResultadoNivel(3, resultadoNivel3, gravedadNivel3); break;
      case PANTALLA_NIVEL_4:      dibujarNivel4();                             break;
      case PANTALLA_RESULTADO_4:  dibujarResultadoNivel(4, resultadoNivel4, gravedadNivel4); break;
      case PANTALLA_ARBOL:        dibujarPantallaArbol();                      break;
      case PANTALLA_RECORRIDOS:   dibujarRecorridos();                         break;
      case PANTALLA_REPORTE:      dibujarReporteFinal();                       break;
      case PANTALLA_MANUAL:       dibujarManual();                             break;
      case PANTALLA_CONTEXTO:     dibujarContexto();                           break;
      case PANTALLA_MULTI_CONFIG: multi.dibujarConfiguracion(this);            break;
      case PANTALLA_CONFIG_AUDIO: dibujarConfigAudio();                    break;
      case PANTALLA_MULTI_FIN:    multi.dibujarMarcadorFinal(this);            break;
      case PANTALLA_CAMBIO_TURNO:  dibujarPantallaCambioTurno();                 break;
      case PANTALLA_CONFIG_SKINS:  dibujarConfigSkins();                         break;
    }

    
    if (pantallaActual != PANTALLA_INICIO &&
        pantallaActual != PANTALLA_COMO_JUGAR &&
        pantallaActual != PANTALLA_MULTI_CONFIG &&
        pantallaActual != PANTALLA_CONFIG_AUDIO &&
        pantallaActual != PANTALLA_CONFIG_SKINS &&
        pantallaActual != PANTALLA_MULTI_FIN) {
      dibujarBarraSuperior();
    }

    
    if (mostrarSubtitulos && subtituloActual != null && subtituloActual.length() > 0) {
      dibujarSubtitulo(subtituloActual);
    }

    
    if (pistaVisible && pistaMostrada != null && pistaMostrada.length() > 0 && esPantallaDeNivel()) {
      dibujarPanelPista(pistaMostrada);
    }

    
    if (dialogoMostrandose) {
      dialogo.dibujar(0, 0, width, height);
    }

    
    transicion.dibujar();

    
    dibujarFeedback(p);
  }

  

  void dibujarInicio() {
    String fondo = altoContraste ? "accesibilidad/fondo_inicio_alto_contraste.png" : "fondos/fondo_inicio.png";
    dibujarFondo(fondo, color(12, 16, 28));
    dibujarParticulas();

    PImage logo = assets.get("ui/logo_juego.png");
    float anchoLogo = min(logo.width * 0.7, sx(900));
    float altoLogo  = logo.height * (anchoLogo / logo.width);
    image(logo, width/2 - anchoLogo/2, sy(-80), anchoLogo, altoLogo);

    
    noStroke(); fill(8, 14, 26, 160);
    rect(sx(480), sy(358), sx(420), sy(448), 22);

    
    btnConfig.x = width - sx(150);
    btnConfig.y = sy(24);
    btnConfig.w = sx(120);
    btnConfig.h = sy(56);
    btnConfig.dibujar(assets);

    btnIniciar.dibujar(assets);
    btnComoJugar.dibujar(assets);
    btnMultijugador.dibujar(assets);
    btnSkins.dibujar(assets);

    btnSalir.x = sx(1040);
    btnSalir.y = height - sy(86);
    btnSalir.w = sx(180);
    btnSalir.h = sy(54);
    btnSalir.dibujar(assets);

    
    fill(120); textAlign(RIGHT, BOTTOM); textSize(tx(13));
    text("v2.0 – CyberDetective", width - sx(20), height - sy(10));

    subtituloActual = "Pantalla principal. Ajusta audio, elige modo de juego y comienza la investigación.";
  }


  void dibujarConfigSkins() {
    dibujarFondo("fondos/fondo_howtoplay.png", color(14, 18, 28));
    dibujarParticulas();

    float pw = sx(1120), ph = sy(560);
    float px = width/2 - pw/2, py = height/2 - ph/2;
    dibujarPanelMarco(px, py, pw, ph, false);

    fill(colorTexto());
    textAlign(CENTER, TOP);
    textSize(tx(34));
    text("SELECCIÓN DE SKINS", width/2, py + sy(26));

    textSize(tx(18));
    fill(170, 210, 255);
    text("Elige la apariencia del detective y de Valeria.", width/2, py + sy(78));

    dibujarSelectorSkinInicio(px + sx(80), py + sy(130), sx(400), sy(320), true);
    dibujarSelectorSkinInicio(px + pw - sx(480), py + sy(130), sx(400), sy(320), false);

    configurarBoton(btnSkinDetective, px + sx(150), py + ph - sy(90), sx(260), sy(64), "CAMBIAR DETECTIVE");
    configurarBoton(btnSkinValeria,   px + pw - sx(410), py + ph - sy(90), sx(260), sy(64), "CAMBIAR VALERIA");
    configurarBoton(btnVolver, width/2 - sx(105), py + ph - sy(90), sx(210), sy(64), "VOLVER");

    btnSkinDetective.dibujar(assets);
    btnSkinValeria.dibujar(assets);
    btnVolver.dibujar(assets);

    subtituloActual = "Aquí puedes cambiar la apariencia de los personajes sin recargar la pantalla principal.";
  }

  void dibujarSelectorSkinInicio(float x, float y, float w, float h, boolean esDetective) {
    dibujarPanelMarco(x, y, w, h, true);
    fill(colorTexto());
    textAlign(CENTER, TOP);
    textSize(tx(20));
    text(esDetective ? "Skin del detective" : "Skin de Valeria", x + w/2, y + sy(18));

    float cx = x + w/2;
    float cy = y + h*0.48;
    float radio = min(w, h) * 0.43;
    if (esDetective) dibujarAlex(cx, cy, radio, false);
    else dibujarValeriaCodigo(cx, cy, radio, false, false);

    textSize(tx(15));
    fill(170, 210, 255);
    text((esDetective ? skinDetective : skinValeria) == 0 ? "Skin 1" : "Skin 2", x + w/2, y + h - sy(92));
    textSize(tx(13));
    fill(150);
    text("Haz click para alternar", x + w/2, y + h - sy(37));
  }

  void dibujarComoJugar() {
    dibujarFondo("fondos/fondo_howtoplay.png", color(18, 24, 34));
    dibujarPanelMarco(sx(90), sy(90), width - sx(180), height - sy(180), false);

    fill(colorTexto()); textAlign(CENTER, TOP); textSize(tx(36));
    text("CÓMO JUGAR", width/2, sy(130));

    textAlign(LEFT, TOP); textSize(tx(22));
    String texto =
      "• Un nodo guarda un caso con su gravedad.\n\n" +
      "• El árbol AVL organiza los casos de menor a mayor gravedad y se balancea automáticamente.\n\n" +
      "• En cada nivel debes encontrar evidencia, clasificar el delito y confirmar el caso.\n\n" +
      "• Los delitos son: Injuria, Calumnia y Suplantación.\n\n" +
      "• Al final verás el árbol completo, sus recorridos y el reporte final.\n\n" +
      "• MULTIJUGADOR: cada detective juega el caso completo por turnos; al final gana quien acumule más puntaje.\n\n" +
      "• Tecla H/P: pista contextual  |  Tecla T: subtítulos  |  Tecla C: alto contraste";
    text(texto, sx(180), sy(220), width - sx(360), sy(400));

    dibujarBarraInferiorDoble("VOLVER", "CONTINUAR");
    subtituloActual = "Lee las reglas antes de jugar.";
  }

  void dibujarNivel1() {
    dibujarFondo("fondos/fondo_nivel1_mensajes.png", color(20, 24, 38));
    dibujarEncabezadoNivel(1, "INJURIA", "Valeria recibe mensajes ofensivos repetidos.");

    dibujarCelularDetective(sx(120), sy(190), sx(420), sy(470));
    dibujarAvatarValeria(sx(1050), sy(180), sx(220), sy(260), true);
    dibujarPanelMarco(sx(610), sy(190), sx(700), sy(450), true);

    fill(colorTexto()); textSize(tx(24)); textAlign(CENTER, CENTER);
    text("Selecciona el mensaje ofensivo:", sx(690), sy(185), sx(560), sy(55));
    textAlign(LEFT, BASELINE);

    for (int i = 0; i < opcionesNivel1.length; i++) {
      opcionesNivel1[i].seleccionada = (indiceSeleccionadoNivel1 == i);
      opcionesNivel1[i].dibujar(assets, "", "");
    }

    fill(colorTexto()); textSize(tx(22));
    text("Clasifica el delito:", sx(32), sy(720));
    btnInjuria.y = sy(750); btnCalumnia.y = sy(750); btnSuplantacion.y = sy(750); btnConfirmar.y = sy(750);

    btnInjuria.texto = "INJURIA";      btnCalumnia.texto = "CALUMNIA";
    btnSuplantacion.texto = "SUPLANTACIÓN";
    btnInjuria.seleccionado     = clasificacionElegidaNivel1.equals("Injuria");
    btnCalumnia.seleccionado    = clasificacionElegidaNivel1.equals("Calumnia");
    btnSuplantacion.seleccionado = clasificacionElegidaNivel1.equals("Suplantación");
    btnInjuria.dibujar(assets); btnCalumnia.dibujar(assets);
    btnSuplantacion.dibujar(assets); btnConfirmar.dibujar(assets);

    dibujarIndicadorMulti();
    subtituloActual = "Nivel 1. Identifica el mensaje ofensivo y clasifica el delito. Tecla H = pista.";
  }

  void dibujarNivel2() {
    dibujarFondo("fondos/fondo_nivel2_rumor.png", color(28, 22, 36));
    dibujarEncabezadoNivel(2, "CALUMNIA", "Se viraliza un rumor falso sobre Valeria.");
    dibujarPanelMarco(sx(90), sy(170), sx(1260), sy(500), true);

    fill(colorTexto()); textSize(tx(26));
    text("Selecciona la publicación original del rumor:", sx(130), sy(200));

    for (int i = 0; i < opcionesNivel2.length; i++) {
      opcionesNivel2[i].seleccionada = (indiceSeleccionadoNivel2 == i);
      opcionesNivel2[i].dibujar(assets, "", "");
    }

    fill(colorTexto()); textSize(tx(22)); textAlign(LEFT, TOP); text("Clasifica el delito:", sx(32), sy(720));
    btnInjuria.y = sy(750); btnCalumnia.y = sy(750); btnSuplantacion.y = sy(750); btnConfirmar.y = sy(750);
    btnInjuria.texto = "INJURIA"; btnCalumnia.texto = "CALUMNIA"; btnSuplantacion.texto = "SUPLANTACIÓN";
    btnInjuria.seleccionado  = clasificacionElegidaNivel2.equals("Injuria");
    btnCalumnia.seleccionado = clasificacionElegidaNivel2.equals("Calumnia");
    btnSuplantacion.seleccionado = clasificacionElegidaNivel2.equals("Suplantación");
    btnInjuria.dibujar(assets); btnCalumnia.dibujar(assets);
    btnSuplantacion.dibujar(assets); btnConfirmar.dibujar(assets);

    dibujarIndicadorMulti();
    subtituloActual = "Nivel 2. Detecta qué publicación inició el rumor falso. H = pista.";
  }

  void dibujarNivel3() {
    dibujarFondo("fondos/fondo_nivel3_perfilfalso.png", color(22, 28, 34));
    dibujarEncabezadoNivel(3, "SUPLANTACIÓN", "Aparece una cuenta falsa usando la imagen de Valeria.");
    dibujarTarjetaPerfilFalso(sx(95), sy(180), sx(520), sy(470));
    dibujarAvatarValeria(sx(142), sy(247), sx(146), sy(146), false);
    dibujarPanelMarco(sx(650), sy(180), sx(650), sy(470), true);

    fill(colorTexto()); textSize(tx(26)); textAlign(LEFT, TOP);
    text("Selecciona los elementos que prueban el delito:", sx(665), sy(205), sx(660), sy(55));

    for (int i = 0; i < opcionesNivel3.length; i++) {
      opcionesNivel3[i].seleccionada = seleccionPerfil[i];
      opcionesNivel3[i].dibujar(assets, "", "");
    }

    fill(colorTexto()); textSize(tx(22)); textAlign(LEFT, TOP); text("Clasifica el delito:", sx(32), sy(720));
    btnInjuria.y = sy(750); btnCalumnia.y = sy(750); btnSuplantacion.y = sy(750); btnConfirmar.y = sy(750);
    btnInjuria.texto = "INJURIA"; btnCalumnia.texto = "CALUMNIA"; btnSuplantacion.texto = "SUPLANTACIÓN";
    btnInjuria.seleccionado  = clasificacionElegidaNivel3.equals("Injuria");
    btnCalumnia.seleccionado = clasificacionElegidaNivel3.equals("Calumnia");
    btnSuplantacion.seleccionado = clasificacionElegidaNivel3.equals("Suplantación");
    btnInjuria.dibujar(assets); btnCalumnia.dibujar(assets);
    btnSuplantacion.dibujar(assets); btnConfirmar.dibujar(assets);

    dibujarIndicadorMulti();
    subtituloActual = "Nivel 3. Confirma la suplantación con evidencias del perfil falso. H = pista.";
  }

  void dibujarNivel4() {
    dibujarFondo("fondos/fondo_nivel4_ataque.png", color(28, 20, 24));
    dibujarEncabezadoNivel(4, "ATAQUE COORDINADO", "Relaciona las cuentas coordinadas y demuestra el patrón.");

    float areaX = sx(100); float areaY = sy(190);
    float areaW = sx(1240); float areaH = sy(350);
    dibujarPanelMarco(areaX, areaY, areaW, areaH, true);

    textAlign(CENTER, TOP); fill(colorTexto()); textSize(tx(24));
    text("Selecciona las cuentas relacionadas con el ataque", width/2, sy(205));

    float cardW = sx(250); float cardH = sy(112);
    float leftX = sx(145); float rightX = width - sx(145) - cardW;
    float topY = sy(300); float bottomY = sy(435);

    if (opcionesNivel4 != null && opcionesNivel4.length >= 4) {
      opcionesNivel4[0].x = leftX;  opcionesNivel4[0].y = topY;    opcionesNivel4[0].w = cardW; opcionesNivel4[0].h = cardH;
      opcionesNivel4[1].x = leftX;  opcionesNivel4[1].y = bottomY; opcionesNivel4[1].w = cardW; opcionesNivel4[1].h = cardH;
      opcionesNivel4[2].x = rightX; opcionesNivel4[2].y = topY;    opcionesNivel4[2].w = cardW; opcionesNivel4[2].h = cardH;
      opcionesNivel4[3].x = rightX; opcionesNivel4[3].y = bottomY; opcionesNivel4[3].w = cardW; opcionesNivel4[3].h = cardH;
    }

    dibujarPanelConexionCentral(width/2 - sx(170), sy(288), sx(340), sy(170));
    dibujarLineasConexionNivel4();

    for (int i = 0; i < opcionesNivel4.length; i++) {
      opcionesNivel4[i].seleccionada = seleccionCuentas[i];
      opcionesNivel4[i].dibujar(assets, "", "");
    }

    textAlign(LEFT, TOP); fill(colorTexto()); textSize(tx(22));
    text("Clasificación final del caso:", sx(32), sy(690));
    btnInjuria.texto = "INJURIA"; btnCalumnia.texto = "CALUMNIA"; btnSuplantacion.texto = "HOSTIGAMIENTO";
    btnInjuria.seleccionado  = clasificacionElegidaNivel4.equals("Injuria");
    btnCalumnia.seleccionado = clasificacionElegidaNivel4.equals("Calumnia");
    btnSuplantacion.seleccionado = clasificacionElegidaNivel4.equals("Hostigamiento digital");
    btnInjuria.y = sy(720); btnCalumnia.y = sy(720);
    btnSuplantacion.y = sy(720); btnConfirmar.y = sy(720);
    btnInjuria.dibujar(assets); btnCalumnia.dibujar(assets);
    btnSuplantacion.dibujar(assets); btnConfirmar.dibujar(assets);

    dibujarIndicadorMulti();
    subtituloActual = "Nivel 4. Selecciona las cuentas coordinadas y clasifica el caso. H = pista.";
  }

  void dibujarResultadoNivel(int nivel, String resultado, int gravedad) {
    dibujarFondo("fondos/fondo_juego_base.png", color(15, 18, 28));
    dibujarPanelMarco(sx(190), sy(120), sx(1060), sy(600), true);
    dibujarSelloResultado(resultado, sx(560), sy(160), sx(320), sy(120));

    fill(colorTexto()); textAlign(CENTER, TOP);
    textSize(tx(34)); text("RESULTADO NIVEL " + nivel, width/2, sy(310));
    textSize(tx(24)); text(resultado, width/2, sy(360));

    String explicacion = "";
    if (nivel == 1) explicacion = explicacionNivel1;
    else if (nivel == 2) explicacion = explicacionNivel2;
    else if (nivel == 3) explicacion = explicacionNivel3;
    else if (nivel == 4) explicacion = explicacionNivel4;

    textAlign(CENTER, TOP); textSize(tx(18));
    text(explicacion, width/2 - sx(360), sy(410), sx(720), sy(90));
    textSize(tx(22));
    text("Gravedad calculada: " + gravedad, width/2, sy(520));
    text("Puntaje acumulado: " + puntaje, width/2, sy(560));

    
    if (multi.activo) {
      textSize(tx(18));
      fill(100, 220, 255);
      text(multi.j1.nombre + ": " + multi.j1.puntaje + "    |    " + multi.j2.nombre + ": " + multi.j2.puntaje, width/2, sy(600));
      fill(190, 220, 255);
      text("Turno actual: " + multi.jugadorActual().nombre, width/2, sy(635));
    }

    btnInsertarCaso.dibujar(assets);
    btnVolver.dibujar(assets);

    subtituloActual = casoInsertado[nivel]
      ? "Caso ya insertado. Continúa al árbol o vuelve a revisar."
      : "Resultado del nivel. Inserta el caso en el árbol AVL.";
  }

  void dibujarPantallaArbol() {
    dibujarFondo("fondos/fondo_arbol.png", color(12, 14, 22));
    fill(colorTexto()); textAlign(CENTER, TOP); textSize(tx(36));
    text("ÁRBOL AVL DE CASOS", width/2, sy(100));

    dibujarPanelMarco(sx(70), sy(150), width - sx(140), sy(500), true);
    arbol.actualizarAnimaciones(arbol.raiz);
    arbol.dibujarAnimado(arbol.raiz, altoContraste, p);
    arbol.dibujarInfoNodo(sx(95), sy(495), width - sx(190), sy(230), altoContraste, p);
    dibujarFeedback(p);

    if (casosResueltos < 4) {
      configurarBoton(btnSiguiente, width/2 - sx(135), height - sy(92), sx(270), sy(66), "SIGUIENTE NIVEL");
      btnSiguiente.dibujar(assets);
    } else {
      dibujarBarraInferiorArbol();
    }

    subtituloActual = arbol.nodoSeleccionado == null
      ? "Clic en un nodo para ver detalles del caso."
      : "Nodo seleccionado. Revisa delito, ley, pena y gravedad.";
  }

  void dibujarRecorridos() {
    dibujarFondo("fondos/fondo_arbol.png", color(18, 18, 26));
    dibujarPanelMarco(sx(110), sy(110), width - sx(220), height - sy(220), false);

    fill(colorTexto()); textAlign(CENTER, TOP);
    textSize(tx(34)); text("RECORRIDOS DEL ÁRBOL", width/2, sy(150));
    textSize(tx(26)); text("Recorrido actual: " + tipoRecorridoActual, width/2, sy(220));

    textAlign(LEFT, TOP); textSize(tx(24));
    text(recorridoMostrado, sx(190), sy(310), width - sx(380), sy(280));

    dibujarBarraInferiorRecorridos();
    subtituloActual = "Los recorridos muestran el orden lógico del árbol: inorden, preorden y postorden.";
  }

  void dibujarReporteFinal() {
    dibujarFondo("fondos/fondo_reporte.png", color(22, 22, 26));
    dibujarPanelMarco(sx(78), sy(58), width - sx(156), height - sy(116), true);

    if (reporteFinalVisible == null || trim(reporteFinalVisible).length() == 0) {
      generarReporteFinal();
    }
    if (reporteFinalVisible == null || trim(reporteFinalVisible).length() == 0) {
      reporteFinalVisible = construirResumenVisibleReporte(obtenerCasosParaReporte());
    }

    fill(colorTexto()); textAlign(CENTER, TOP); textSize(tx(36));
    text("REPORTE FINAL DEL CASO", width/2, sy(108));

    float leftX = sx(118); float topY = sy(195);
    float leftW = sx(420); float rightX = sx(565);
    float rightW = sx(630); float cardsH = sy(430);

    dibujarBloqueResumenReporte(leftX, topY, leftW, sy(185));
    dibujarBloqueTextoReporte(rightX, topY, rightW, cardsH);
    dibujarSelloReporte("CASO RESUELTO", sx(1005), sy(152), sx(210), sy(74));

    
    dibujarAlex(sx(160), sy(430), ss(95), false);
    dibujarValeriaCodigo(sx(250), sy(430), ss(88), false, false);

    dibujarBarraInferiorReporte();
    subtituloActual = "Reporte final con síntesis completa del caso.";
  }

  void dibujarManual() {
    dibujarFondo("fondos/fondo_juego_base.png", color(16, 18, 24));
    dibujarPanelMarco(sx(90), sy(90), width - sx(180), height - sy(180), false);

    fill(colorTexto()); textAlign(CENTER, TOP); textSize(tx(34));
    text("MANUAL DEL DETECTIVE", width/2, sy(130));

    textAlign(LEFT, TOP); textSize(tx(20));
    String texto =
      "INJURIA: Ataque al buen nombre mediante ofensas o expresiones degradantes.\n\n" +
      "CALUMNIA: Imputar falsamente a alguien un hecho punible.\n\n" +
      "SUPLANTACIÓN: Uso de identidad, imagen o datos de otra persona sin autorización.\n\n" +
      "GRAVEDAD: Se calcula con base por nivel ajustada según aciertos, errores y clasificación.\n\n" +
      "ÁRBOL AVL: Cada caso entra según su gravedad. Si se desbalancea, rota automáticamente.\n\n" +
      "RECORRIDOS: Inorden = menor a mayor. Preorden = desde raíz. Postorden = desde hojas.\n\n" +
      "ACCESIBILIDAD: Tecla T = subtítulos. Tecla C = alto contraste. H/P = pista contextual.";
    text(texto, sx(170), sy(210), width - sx(340), sy(450));

    
    dibujarAlex(width - sx(200), sy(350), ss(95), false);

    btnVolver.dibujar(assets);
    subtituloActual = "Manual del detective: clasificación de delitos y funcionamiento del árbol.";
  }

  void dibujarContexto() {
    dibujarFondo("fondos/fondo_juego_base.png", color(18, 24, 34));
    dibujarPanelMarco(sx(90), sy(90), width - sx(180), height - sy(180), false);

    fill(colorTexto()); textAlign(CENTER, TOP); textSize(tx(36));
    text("CONTEXTO E HISTORIA", width/2, sy(130));

    textAlign(LEFT, TOP); textSize(tx(21));
    String contextoTexto =
      "En la ciudad digital NetCity, los casos de ciberacoso han aumentado.\n\n" +
      "Valeria es una estudiante que recibe mensajes ofensivos, burlas públicas y ataques constantes.\n" +
      "Lo que empezó como una broma ha escalado a una situación grave de ciberacoso.\n\n" +
      "Alex, Detective Digital, usa un Árbol AVL para investigar: cada incidente se convierte en un\n" +
      "NODO del árbol. Según la gravedad del delito, el árbol crece, se reorganiza y se equilibra.\n\n" +
      "Tu objetivo: reconstruir el árbol de pruebas, clasificar cada delito y dar con el agresor.";
    text(contextoTexto, sx(180), sy(215), width - sx(600), sy(440));

    // Personajes a la derecha
    dibujarAlex(sx(660), sy(640), ss(155), false);
    dibujarValeriaCodigo(sx(890), sy(640), ss(152), true, false);

    dibujarBarraInferiorDoble("VOLVER", "CONTINUAR");
    subtituloActual = "El detective no investiga de forma lineal; usa el Árbol AVL para deducir hechos.";
  }

  // ─── BARRAS DE NAVEGACIÓN ─────────────────────────────────────────────────
  void dibujarBarraSuperior() {
    // Fondo con gradiente simulado
    noStroke(); fill(6, 10, 20, 210);
    rect(0, 0, width, sy(92));
    noStroke(); fill(0, 130, 200, 18);
    rect(0, sy(82), width, sy(10));

    // Texto info
    fill(180, 210, 240); textAlign(LEFT, CENTER); textSize(tx(18));
    text("Nivel: " + nivelActual, sx(26), sy(46));
    text("Puntaje: " + puntaje, sx(160), sy(46));

    // Indicador multijugador en barra
    if (multi.activo) {
      fill(100, 220, 255, 220);
      textSize(tx(15));
      text(multi.etiquetaTurno(), sx(340), sy(46));
      fill(170, 215, 255, 235);
      textSize(tx(13));
      text(multi.j1.nombre + ": " + multi.j1.puntaje + "   |   " + multi.j2.nombre + ": " + multi.j2.puntaje, sx(520), sy(22));
    }

    // Indicador subtítulos
    fill(altoContraste ? color(255,255,0) : color(160,190,210));
    textSize(tx(13));
    text("Subtítulos: " + (mostrarSubtitulos ? "ON" : "OFF") + " (T)", sx(750), sy(46));

    btnConfig.texto = "AUDIO";
    btnConfig.dibujar(assets);
    btnManual.dibujar(assets);
    btnAltoContraste.texto = altoContraste ? "CONTRASTE ON" : "CONTRASTE OFF";
    btnAltoContraste.dibujar(assets);
  }


  void dibujarConfigAudio() {
    dibujarFondo("fondos/fondo_juego_base.png", color(10, 14, 26));
    float pw = sx(760), ph = sy(430);
    float px = width/2 - pw/2, py = height/2 - ph/2;
    dibujarPanelMarco(px, py, pw, ph, true);

    fill(colorTexto());
    textAlign(CENTER, TOP);
    textSize(tx(34));
    text("CONFIGURACIÓN DE AUDIO", width/2, py + sy(28));
    fill(180, 210, 255);
    textSize(tx(16));
    text("Ajusta la música de fondo y los efectos de clic sin afectar la partida.", width/2, py + sy(76));

    dibujarControlVolumen(px + sx(70), py + sy(150), pw - sx(140), sy(70), 
      "Música", sonidoGlobal != null ? sonidoGlobal.getVolumenMusica() : 0.0);
    dibujarControlVolumen(px + sx(70), py + sy(255), pw - sx(140), sy(70), 
      "Clicks", sonidoGlobal != null ? sonidoGlobal.getVolumenClicks() : 0.0);

    configurarBoton(btnVolver, width/2 - sx(105), py + ph - sy(86), sx(210), sy(62), "VOLVER");
    btnVolver.dibujar(assets);
    subtituloActual = "Usa los botones – y + para regular el volumen de música y clics.";
  }

  void dibujarControlVolumen(float x, float y, float w, float h, String etiqueta, float valor) {
    fill(colorTexto());
    textAlign(LEFT, CENTER);
    textSize(tx(20));
    text(etiqueta, x, y - sy(20));

    float btnW = sx(52);
    float barraX = x + btnW + sx(22);
    float barraW = w - btnW*2 - sx(44);
    float barraY = y + h/2 - sy(8);
    float barraH = sy(16);

    dibujarBotonAjuste(x, y, btnW, h, "−");
    dibujarBotonAjuste(x + w - btnW, y, btnW, h, "+");

    noStroke();
    fill(20, 30, 52, 220);
    rect(barraX, barraY, barraW, barraH, 10);
    fill(getColor(2));
    rect(barraX, barraY, barraW * constrain(valor, 0, 1), barraH, 10);

    fill(220, 232, 245);
    textAlign(RIGHT, CENTER);
    textSize(tx(18));
    text(round(valor * 100) + "%", x + w, y - sy(20));
  }

  void dibujarBotonAjuste(float x, float y, float w, float h, String txt) {
    boolean hover = mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
    noStroke();
    fill(0, 60); rect(x + 3, y + 4, w, h, 12);
    fill(hover ? color(18, 32, 56, 245) : color(14, 22, 40, 228));
    stroke(getColor(2)); strokeWeight(hover ? ss(2.3) : ss(1.6));
    rect(x, y, w, h, 12);
    noStroke(); fill(colorTexto()); textAlign(CENTER, CENTER); textSize(tx(28));
    text(txt, x + w/2, y + h/2 - ss(2));
  }

  void dibujarSubtitulo(String texto) {
    float h = sy(40);
    boolean pantallaConBotonesAbajo = pantallaActual == PANTALLA_COMO_JUGAR ||
      pantallaActual == PANTALLA_CONTEXTO || pantallaActual == PANTALLA_MANUAL ||
      pantallaActual == PANTALLA_ARBOL   || pantallaActual == PANTALLA_RECORRIDOS ||
      pantallaActual == PANTALLA_REPORTE;
    float y = pantallaConBotonesAbajo ? height - sy(115) : height - h - sy(10);
    noStroke(); fill(4, 8, 18, 195);
    rect(sx(140), y, width - sx(280), h, 14);
    fill(220, 232, 245); textAlign(CENTER, CENTER); textSize(tx(16));
    text(texto, width/2, y + h/2);
  }

  void dibujarIndicadorMulti() {
    if (!multi.activo) return;
    float pw = sx(360); float ph = sy(38);
    float px = width/2 - pw/2; float py = sy(10);
    noStroke(); fill(10, 30, 60, 200); rect(px, py, pw, ph, 10);
    fill(100, 220, 255); textAlign(CENTER, CENTER); textSize(tx(15));
    text(multi.jugadorActual().nombre + " — turno actual", px + pw/2, py + ph/2);
  }

  void dibujarBarraInferiorDoble(String textoIzq, String textoDer) {
    float y = height - sy(92); float h = sy(66); float w = sx(210);
    configurarBoton(btnVolver,   sx(80),                 y, w, h, textoIzq);
    configurarBoton(btnContinuar, width - sx(80) - w,   y, w, h, textoDer);
    btnVolver.dibujar(assets); btnContinuar.dibujar(assets);
  }

  void dibujarBarraInferiorArbol() {
    float y = height - sy(92); float h = sy(66); float w = sx(250);
    configurarBoton(btnSiguiente, width/2 - w/2, y, w, h, "RECORRIDOS");
    btnSiguiente.dibujar(assets);
  }

  void dibujarBarraInferiorRecorridos() {
    float y = height - sy(92); float h = sy(66);
    float gap = sx(34); float w = sx(210);
    float total = w * 5 + gap * 4;
    float startX = (width - total) / 2.0;
    configurarBoton(btnVolver,    startX,             y, w, h, "VOLVER");
    configurarBoton(btnInorden,   startX+(w+gap),     y, w, h, "INORDEN");
    configurarBoton(btnPreorden,  startX+(w+gap)*2,   y, w, h, "PREORDEN");
    configurarBoton(btnPostorden, startX+(w+gap)*3,   y, w, h, "POSTORDEN");
    configurarBoton(btnReporte,   startX+(w+gap)*4,   y, w, h, "REPORTE");
    btnVolver.dibujar(assets); btnInorden.dibujar(assets);
    btnPreorden.dibujar(assets); btnPostorden.dibujar(assets); btnReporte.dibujar(assets);
  }

  void dibujarBarraInferiorReporte() {
    float y = height - sy(58); float h = sy(66);
    if (multi.activo) {
      float w1 = sx(220); float w2 = sx(320); float gap = sx(90);
      float total = w1 + w2 + gap;
      float startX = (width - total) / 2.0;
      configurarBoton(btnVolver,   startX,             y, w1, h, "VOLVER");
      configurarBoton(btnSiguiente, startX+w1+gap,     y, w2, h,
        multi.turnoActual == 0 ? "PASAR A JUGADOR 2" : "VER RESULTADOS");
    } else {
      float w = sx(230); float gap = sx(120); float total = w*2 + gap;
      float startX = (width - total) / 2.0;
      configurarBoton(btnVolver,   startX,         y, w, h, "VOLVER");
      configurarBoton(btnSiguiente, startX+w+gap,  y, w, h, "REINICIAR");
    }
    btnVolver.dibujar(assets);
    btnSiguiente.dibujar(assets);
    btnSiguiente.texto = "SIGUIENTE";
  }

  // ─── UTILIDADES DE DIBUJO ────────────────────────────────────────────────
  void configurarBoton(BotonImagen boton, float x, float y, float w, float h, String texto) {
    boton.x = x; boton.y = y; boton.w = w; boton.h = h;
    if (texto != null) boton.texto = texto;
  }

  void normalizarBotonesBase() {
    btnContinuar.x = sx(1040); btnContinuar.y = sy(760); btnContinuar.w = sx(270); btnContinuar.h = sy(72);
    btnVolver.x = sx(80);      btnVolver.y = sy(760);    btnVolver.w = sx(210);    btnVolver.h = sy(72);
    btnInjuria.x = sx(130);    btnInjuria.y = sy(750);
    btnCalumnia.x = sx(410);   btnCalumnia.y = sy(750);
    btnSuplantacion.x = sx(690); btnSuplantacion.y = sy(750);
    btnConfirmar.x = sx(1080); btnConfirmar.y = sy(750);
    btnSiguiente.x = sx(1110); btnSiguiente.y = sy(780); btnSiguiente.w = sx(250); btnSiguiente.h = sy(72);
    btnConfig.x = sx(925);      btnConfig.y = sy(14);      btnConfig.w = sx(105);      btnConfig.h = sy(60);
    btnInsertarCaso.x = sx(1060); btnInsertarCaso.y = sy(760);
    btnReporte.x = sx(1170);   btnReporte.y = sy(760);   btnReporte.w = sx(180);   btnReporte.h = sy(60);
  }

  void dibujarFondo(String ruta, int colorFallback) {
    PImage img = assets.get(ruta);
    if (img != null && !assets.esPlaceholder(ruta)) {
      image(img, 0, 0, width, height);
    } else {
      background(colorFallback);
      // Grid decorativo de puntos
      for (int i = 0; i < 80; i++) {
        noStroke(); fill(255, 12);
        ellipse((i * 83) % width, (i * 47) % height, ss(3), ss(3));
      }
    }
  }

  int colorTexto() { return altoContraste ? color(255, 255, 0) : color(245); }

  void dibujarPanelMarco(float x, float y, float w, float h, boolean fuerte) {
    float r = min(w, h) * 0.06;
    noStroke(); fill(0, 0, 0, fuerte ? 110 : 80);
    rect(x + ss(6), y + ss(8), w, h, r);
    fill(altoContraste ? color(16,16,16,248) : color(16,22,36, fuerte ? 228 : 210));
    stroke(altoContraste ? color(255,255,0) : color(fuerte ? 96 : 110, fuerte ? 190 : 160, 255, 170));
    strokeWeight(ss(fuerte ? 2.4 : 2.0));
    rect(x, y, w, h, r);
    noStroke();
    fill(altoContraste ? color(255,255,0,28) : color(110,190,255, fuerte ? 20 : 12));
    rect(x+ss(4), y+ss(4), w-ss(8), h*0.22, r*0.75);
  }

  void dibujarEncabezadoNivel(int nivel, String titulo, String descripcion) {
    float x = sx(70); float y = sy(95);
    float w = width - sx(140); float h = sy(78); float r = ss(18);
    noStroke(); fill(0,0,0,95); rect(x+ss(5), y+ss(6), w, h, r);
    fill(altoContraste ? color(15,15,15,245) : color(14,20,34,228));
    stroke(altoContraste ? color(255,255,0) : color(100,190,255,165));
    strokeWeight(ss(2.2)); rect(x, y, w, h, r);
    noStroke(); fill(altoContraste ? color(255,255,0,70) : color(70,180,255,42));
    rect(x+ss(6), y+ss(6), w-ss(12), h*0.34, ss(14));
    fill(altoContraste ? color(255,255,0) : color(84,221,189));
    rect(x+ss(22), y+ss(15), ss(8), h-ss(30), ss(6));
    fill(colorTexto()); textAlign(LEFT, TOP); textSize(tx(28));
    text("Nivel " + nivel + " - " + titulo, x+ss(44), y+ss(12));
    textSize(tx(18)); fill(altoContraste ? color(255) : color(220,232,248));
    text(descripcion, x+ss(44), y+ss(43));
  }

  void dibujarCelularDetective(float x, float y, float w, float h) {
    float r = ss(26);
    noStroke(); fill(0,0,0,100); rect(x+ss(10), y+ss(12), w, h, r);
    fill(altoContraste ? color(18,18,18) : color(22,28,38));
    stroke(altoContraste ? color(255,255,0) : color(95,150,255));
    strokeWeight(ss(2.4)); rect(x, y, w, h, r);
    noStroke(); fill(altoContraste ? color(0) : color(8,12,20));
    rect(x+ss(14), y+ss(18), w-ss(28), h-ss(36), ss(20));
    fill(altoContraste ? color(255,255,0) : color(110,210,255,28));
    rect(x+ss(20), y+ss(26), w-ss(40), (h-ss(52))*0.18, ss(14));
    fill(altoContraste ? color(255,255,0) : color(42,56,82));
    rect(x+w/2-ss(34), y+ss(8), ss(68), ss(7), ss(5));
    rect(x+w/2-ss(10), y+h-ss(14), ss(20), ss(4), ss(3));
    fill(altoContraste ? color(255) : color(175,230,255));
    textAlign(LEFT, TOP); textSize(tx(14));
    text("Chat monitoreado", x+ss(28), y+ss(34));
    dibujarBurbujaCelular(x+ss(28), y+ss(86),  w-ss(118), ss(64), false, "¿Nos vemos mañana para estudiar?");
    dibujarBurbujaCelular(x+ss(88), y+ss(166), w-ss(170), ss(82), true,  "Nadie te soporta aquí. Das pena.");
    dibujarBurbujaCelular(x+ss(28), y+ss(268), w-ss(126), ss(66), false, "¿Me pasas el taller cuando puedas?");
    dibujarBurbujaCelular(x+ss(74), y+ss(352), w-ss(160), ss(88), true,  "Te voy a seguir escribiendo hasta que te vayas.");
    noFill(); stroke(altoContraste ? color(255,255,0,90) : color(100,190,255,55));
    strokeWeight(ss(1.4)); rect(x+ss(14), y+ss(18), w-ss(28), h-ss(36), ss(20));
  }

  void dibujarBurbujaCelular(float x, float y, float w, float h, boolean ofensiva, String etiqueta) {
    noStroke();
    fill(ofensiva ? (altoContraste ? color(255,255,0,180) : color(255,92,122,165))
                  : (altoContraste ? color(255,255,255,160) : color(90,118,160,125)));
    rect(x, y, w, h, ss(18));
    fill(ofensiva ? color(34) : color(240));
    textAlign(LEFT, CENTER);
    textSize(tx(13));
    textLeading(tx(16));
    text(etiqueta, x+ss(14), y+ss(8), w-ss(28), h-ss(16));
  }

  void dibujarTarjetaPerfilFalso(float x, float y, float w, float h) {
    dibujarPanelMarco(x, y, w, h, true);
    fill(colorTexto()); textAlign(LEFT, TOP); textSize(tx(18));
    text("@valeria_real_oficial", x+ss(228), y+ss(70));
    textSize(tx(14)); fill(altoContraste ? color(255) : color(210,224,240));
    text("Cuenta creada hace 4 días", x+ss(228), y+ss(103));
    text("Publicaciones: 2  |  Seguidores: 13", x+ss(228), y+ss(130));
    text("Indicadores sospechosos", x+ss(42), y+ss(235));
    dibujarTagPerfil(x+ss(42),  y+ss(275), ss(205), ss(44), "Foto clonada");
    dibujarTagPerfil(x+ss(265), y+ss(275), ss(210), ss(44), "Alias no verificado");
    dibujarTagPerfil(x+ss(42),  y+ss(334), ss(220), ss(44), "Mensajes agresivos");
    dibujarTagPerfil(x+ss(282), y+ss(334), ss(190), ss(44), "Actividad súbita");
    noFill(); stroke(altoContraste ? color(255,255,0) : color(120,190,255,90));
    strokeWeight(ss(1.6)); rect(x+ss(34), y+ss(52), ss(160), ss(160), ss(22));
  }

  void dibujarTagPerfil(float x, float y, float w, float h, String txt) {
    noStroke(); fill(altoContraste ? color(255,255,0,55) : color(84,221,189,42));
    rect(x, y, w, h, ss(12));
    fill(colorTexto()); textAlign(CENTER, CENTER); textSize(tx(13));
    text(txt, x+w/2, y+h/2);
  }

  void dibujarPanelConexionCentral(float x, float y, float w, float h) {
    dibujarPanelMarco(x, y, w, h, false);
    fill(colorTexto()); textAlign(CENTER, TOP); textSize(tx(19));
    text("Patrón de conexión", x+w/2, y+ss(14));
    float cx = x+w/2; float cy = y+h*0.63;
    stroke(altoContraste ? color(255,255,0,85) : color(110,190,255,45));
    strokeWeight(ss(1.2)); line(cx-ss(85), cy, cx+ss(85), cy); noStroke();
    fill(altoContraste ? color(255,255,0,180) : color(255,96,128,160));
    ellipse(cx, cy, ss(78), ss(78));
    fill(24); textSize(tx(13)); textAlign(CENTER, CENTER);
    text("MISMO\nAGRESOR", cx, cy-ss(10));
  }

  void dibujarLineasConexionNivel4() {
    float panelH = sy(170); float cx = width/2; float cy = sy(288)+panelH*0.63;
    stroke(altoContraste ? color(255,255,0,150) : color(110,190,255,105));
    strokeWeight(ss(2.0));
    for (int i = 0; i < opcionesNivel4.length; i++) {
      OpcionInteractiva op = opcionesNivel4[i];
      float ox = op.x+op.w/2; float oy = op.y+op.h/2;
      float midX = (ox < cx) ? cx-sx(120) : cx+sx(120);
      noFill(); beginShape();
      vertex(ox, oy); vertex(midX, oy); vertex(midX, cy); vertex(cx, cy);
      endShape();
    }
    noStroke();
  }

  void dibujarSelloResultado(String resultado, float x, float y, float w, float h) {
    int borde = color(255,196,88); String titulo = "RESULTADO PARCIAL";
    if (resultado.indexOf("CORRECTA") >= 0 && resultado.indexOf("PARCIAL") < 0)
      { borde = color(84,221,189); titulo = "ACIERTO TOTAL"; }
    else if (resultado.indexOf("INCORRECTA") >= 0)
      { borde = color(255,102,122); titulo = "ERROR DETECTADO"; }
    pushStyle(); noFill(); stroke(borde); strokeWeight(ss(3)); rect(x, y, w, h, ss(18));
    fill(red(borde), green(borde), blue(borde), 26); noStroke();
    rect(x+ss(4), y+ss(4), w-ss(8), h-ss(8), ss(16));
    fill(borde); textAlign(CENTER, CENTER); textSize(tx(24));
    text(titulo, x+w/2, y+h/2); popStyle();
  }

  void dibujarSelloReporte(String textoSello, float x, float y, float w, float h) {
    pushMatrix(); pushStyle();
    translate(x+w/2, y+h/2); rotate(radians(-8));
    noFill(); stroke(255,110,125,185); strokeWeight(ss(3)); rect(-w/2, -h/2, w, h, ss(12));
    fill(255,110,125,24); noStroke(); rect(-w/2+ss(4), -h/2+ss(4), w-ss(8), h-ss(8), ss(10));
    fill(255,110,125,220); textAlign(CENTER, CENTER); textSize(tx(18));
    text(textoSello, 0, 0); popStyle(); popMatrix();
  }

  void dibujarBloqueTextoReporte(float x, float y, float w, float h) {
    dibujarPanelMarco(x, y, w, h, false);
    fill(colorTexto()); textAlign(LEFT, TOP); textSize(tx(20));
    text("Síntesis ejecutiva", x+ss(20), y+ss(18));
    String textoVisible = reporteVisibleEnPantalla();
    if (textoVisible == null || trim(textoVisible).length() == 0) textoVisible = "Reporte en preparación...";
    fill(altoContraste ? color(0) : color(10,18,30,160)); noStroke();
    rect(x+ss(18), y+ss(50), w-ss(36), h-ss(68), ss(16));
    fill(altoContraste ? color(255,255,0) : color(245));
    textSize(tx(15.5)); textLeading(tx(21));
    text(textoVisible, x+ss(30), y+ss(68), w-ss(60), h-ss(96));
  }

  void dibujarBloqueResumenReporte(float x, float y, float w, float h) {
    dibujarPanelMarco(x, y, w, h, false);
    ArrayList<Caso> casosReporte = obtenerCasosParaReporte();
    fill(colorTexto()); textAlign(LEFT, TOP); textSize(tx(20));
    text("Resumen del caso", x+ss(20), y+ss(18));
    textSize(tx(16));
    String resumen =
      "Casos registrados: " + casosReporte.size() + "\n" +
      "Agresor identificado: " + valorOPlaceholder(agresorIdentificado) + "\n" +
      "Gravedad total: " + gravedadTotal + "\n" +
      "Puntaje final: " + puntaje + "\n" +
      "Recorrido sugerido: inorden muestra\nla escalada de menor a mayor gravedad.";
    text(resumen, x+ss(20), y+ss(54), w-ss(40), h-ss(70));
  }


  void abrirConfigAudio() {
    pantallaPrevConfig = pantallaActual;
    irAPantalla(PANTALLA_CONFIG_AUDIO);
  }

  void ajustarVolumenDesdeUI(boolean musica, float delta) {
    if (sonidoGlobal == null) return;
    if (musica) sonidoGlobal.ajustarVolumenMusica(sonidoGlobal.getVolumenMusica() + delta);
    else sonidoGlobal.ajustarVolumenClicks(sonidoGlobal.getVolumenClicks() + delta);
    reproducirSonido("click");
  }

  boolean clicRect(float x, float y, float w, float h) {
    return mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
  }

  void manejarClicksConfigAudio() {
    float pw = sx(760), ph = sy(430);
    float px = width/2 - pw/2, py = height/2 - ph/2;
    float x = px + sx(70), w = pw - sx(140), h = sy(70);
    float btnW = sx(52);

    float y1 = py + sy(150);
    float y2 = py + sy(255);
    if (clicRect(x, y1, btnW, h)) { ajustarVolumenDesdeUI(true, -0.1); return; }
    if (clicRect(x + w - btnW, y1, btnW, h)) { ajustarVolumenDesdeUI(true, 0.1); return; }
    if (clicRect(x, y2, btnW, h)) { ajustarVolumenDesdeUI(false, -0.1); return; }
    if (clicRect(x + w - btnW, y2, btnW, h)) { ajustarVolumenDesdeUI(false, 0.1); return; }
    if (btnVolver.estaSobre()) { reproducirSonido("click"); irAPantalla(pantallaPrevConfig); }
  }

  // ─── MOUSE PRESSED ────────────────────────────────────────────────────────
  void mousePressed() {
    // Si hay diálogo activo, avanzar con clic
    if (dialogoMostrandose) { dialogo.avanzar(); return; }

    // Pantalla inicio
    if (pantallaActual == PANTALLA_INICIO) {
      if (btnConfig.estaSobre()) {
        reproducirSonido("click"); abrirConfigAudio();
      } else if (btnIniciar.estaSobre()) {
        reproducirSonido("click");
        reiniciarPartida();
        multi.activo = false;
        irAPantallaConDialogo(PANTALLA_CONTEXTO, getDialogoContexto());
      } else if (btnComoJugar.estaSobre()) {
        reproducirSonido("click"); irAPantalla(PANTALLA_COMO_JUGAR);
      } else if (btnMultijugador.estaSobre()) {
        reproducirSonido("click"); irAPantalla(PANTALLA_MULTI_CONFIG);
      } else if (btnSkins.estaSobre()) {
        reproducirSonido("click"); irAPantalla(PANTALLA_CONFIG_SKINS);
      } else if (btnSalir.estaSobre()) {
        reproducirSonido("click"); exit();
      }
      return;
    }

    // Configuración multijugador
    if (pantallaActual == PANTALLA_MULTI_CONFIG) {
      manejarClicksMultiConfig(); return;
    }

    if (pantallaActual == PANTALLA_CONFIG_AUDIO) {
      manejarClicksConfigAudio(); return;
    }
    if (pantallaActual == PANTALLA_CONFIG_SKINS) {
      manejarClicksConfigSkins(); return;
    }

    // Marcador final multijugador
    if (pantallaActual == PANTALLA_MULTI_FIN) {
      // Botón nuevo juego
      float bw = sx(240); float bh = sy(58);
      if (mouseX >= width/2-bw/2 && mouseX <= width/2+bw/2 &&
          mouseY >= sy(640) && mouseY <= sy(640)+bh) {
        multi.detener(); reiniciarPartida(); irAPantalla(PANTALLA_INICIO);
      }
      return;
    }

    // Botones globales
    if (btnConfig.estaSobre() && pantallaActual != PANTALLA_CONFIG_AUDIO) {
      reproducirSonido("click"); abrirConfigAudio(); return;
    }
    if (btnManual.estaSobre() && pantallaActual != PANTALLA_MANUAL) {
      reproducirSonido("click"); irAPantalla(PANTALLA_MANUAL); return;
    }
    if (btnAltoContraste.estaSobre()) {
      reproducirSonido("click"); altoContraste = !altoContraste; return;
    }

    // Navegación por pantalla
    switch(pantallaActual) {
      case PANTALLA_MANUAL:
        if (btnVolver.estaSobre()) irAPantalla(nivelAPantalla(nivelActual)); break;
      case PANTALLA_COMO_JUGAR:
        if (btnVolver.estaSobre()) irAPantalla(PANTALLA_INICIO);
        if (btnContinuar.estaSobre()) { reiniciarPartida(); irAPantallaConDialogo(PANTALLA_CONTEXTO, getDialogoContexto()); }
        break;
      case PANTALLA_CONTEXTO:
        if (btnVolver.estaSobre()) irAPantalla(PANTALLA_INICIO);
        if (btnContinuar.estaSobre()) {
          if (multi.activo) detectiveActivo = multi.jugadorActual().nombre;
          irAPantallaConDialogo(PANTALLA_NIVEL_1, getDialogoNivel1());
        }
        break;
      case PANTALLA_NIVEL_1:      manejarClicksNivel1();         break;
      case PANTALLA_RESULTADO_1:  manejarClickResultadoNivel(1); break;
      case PANTALLA_NIVEL_2:      manejarClicksNivel2();         break;
      case PANTALLA_RESULTADO_2:  manejarClickResultadoNivel(2); break;
      case PANTALLA_NIVEL_3:      manejarClicksNivel3();         break;
      case PANTALLA_RESULTADO_3:  manejarClickResultadoNivel(3); break;
      case PANTALLA_NIVEL_4:      manejarClicksNivel4();         break;
      case PANTALLA_RESULTADO_4:  manejarClickResultadoNivel(4); break;
      case PANTALLA_ARBOL:        manejarClicksArbol();          break;
      case PANTALLA_RECORRIDOS:   manejarClicksRecorridos();     break;
      case PANTALLA_REPORTE:      manejarClicksReporte();        break;
      case PANTALLA_CAMBIO_TURNO:  manejarClicksCambioTurno();    break;
    }
  }

  // ─── KEY PRESSED ──────────────────────────────────────────────────────────
  void keyPressed(char k, int kc) {
    // Diálogo: espacio o enter avanza
    if (dialogoMostrandose && (k == ' ' || kc == ENTER || kc == RETURN)) {
      dialogo.avanzar(); return;
    }

    // Input de nombres en multijugador
    if (pantallaActual == PANTALLA_MULTI_CONFIG) {
      manejarTeclaMultiConfig(k, kc); return;
    }

    if (k == 'm' || k == 'M') irAPantalla(PANTALLA_MANUAL);
    if (k == 'c' || k == 'C') altoContraste = !altoContraste;
    if (k == 'r' || k == 'R') { reiniciarPartida(); multi.detener(); }
    if (k == 't' || k == 'T') {
      mostrarSubtitulos = !mostrarSubtitulos;
    }
    if (k == 'h' || k == 'H' || k == 'p' || k == 'P') mostrarPistaActual();
  }

  // ─── MULTIJUGADOR CONFIG ─────────────────────────────────────────────────
  void manejarClicksMultiConfig() {
    float pw = sx(780); float ph = sy(520);
    float px = width/2 - pw/2; float py = height/2 - ph/2;

    if (multi.clicCampoJ1(this, px, py, pw)) { multi.editandoJ1 = true;  return; }
    if (multi.clicCampoJ2(this, px, py, pw)) { multi.editandoJ1 = false; return; }
    if (multi.clicIniciar(this, px, py, pw, ph)) {
      reproducirSonido("click");
      reiniciarPartida();
      multi.iniciar();
      irAPantallaConDialogo(PANTALLA_CONTEXTO, getDialogoMultijugador());
    }
    if (multi.clicVolver(this, px, py, pw, ph)) {
      reproducirSonido("click"); irAPantalla(PANTALLA_INICIO);
    }
  }

  void manejarClicksConfigSkins() {
    if (btnSkinDetective.estaSobre()) {
      reproducirSonido("click");
      skinDetective = 1 - skinDetective;
      return;
    }
    if (btnSkinValeria.estaSobre()) {
      reproducirSonido("click");
      skinValeria = 1 - skinValeria;
      return;
    }
    if (btnVolver.estaSobre()) {
      reproducirSonido("click");
      irAPantalla(PANTALLA_INICIO);
    }
  }

  void manejarTeclaMultiConfig(char k, int kc) {
    String campo = multi.editandoJ1 ? multi.inputNombreJ1 : multi.inputNombreJ2;
    if (kc == BACKSPACE) {
      if (campo.length() > 0) campo = campo.substring(0, campo.length()-1);
    } else if (kc == TAB) {
      multi.editandoJ1 = !multi.editandoJ1; return;
    } else if (kc == ENTER || kc == RETURN) {
      // Avanzar al siguiente campo o confirmar
      if (multi.editandoJ1) multi.editandoJ1 = false;
    } else if (k != CODED && campo.length() < 20) {
      campo += k;
    }
    if (multi.editandoJ1) multi.inputNombreJ1 = campo;
    else                  multi.inputNombreJ2 = campo;
  }

  // ─── LÓGICA DE NIVELES (INTACTA) ─────────────────────────────────────────
  void manejarClicksNivel1() {
    for (int i = 0; i < opcionesNivel1.length; i++) {
      if (opcionesNivel1[i].estaSobre()) { indiceSeleccionadoNivel1 = i; reproducirSonido("click"); }
    }
    if (btnInjuria.estaSobre())      { clasificacionElegidaNivel1 = "Injuria";     reproducirSonido("click"); }
    if (btnCalumnia.estaSobre())     { clasificacionElegidaNivel1 = "Calumnia";    reproducirSonido("click"); }
    if (btnSuplantacion.estaSobre()) { clasificacionElegidaNivel1 = "Suplantación"; reproducirSonido("click"); }
    if (btnConfirmar.estaSobre() && indiceSeleccionadoNivel1 != -1 && clasificacionElegidaNivel1.length() > 0) {
      boolean ec = opcionesNivel1[indiceSeleccionadoNivel1].esCorrecta;
      boolean cc = clasificacionElegidaNivel1.equals("Injuria");
      int aciertos = (ec?1:0)+(cc?1:0); int errores = 2-aciertos;
      gravedadNivel1 = calcularGravedadPercibida(48, aciertos, errores, cc, 18);
      int pts = (ec?70:20) + (cc?40:10);
      puntaje += pts;
      if (multi.activo) multi.jugadorActual().puntaje += pts;
      resultadoNivel1 = construirResultado(ec, cc, "Injuria");
      explicacionNivel1 = construirExplicacionNivel1(ec, cc);
      resolverNivelConSonido("Nivel 1 resuelto", ec&&cc, ec||cc);
      irAPantalla(PANTALLA_RESULTADO_1);
    }
  }

  void manejarClicksNivel2() {
    for (int i = 0; i < opcionesNivel2.length; i++) {
      if (opcionesNivel2[i].estaSobre()) { indiceSeleccionadoNivel2 = i; reproducirSonido("click"); }
    }
    if (btnInjuria.estaSobre())      { clasificacionElegidaNivel2 = "Injuria";     reproducirSonido("click"); }
    if (btnCalumnia.estaSobre())     { clasificacionElegidaNivel2 = "Calumnia";    reproducirSonido("click"); }
    if (btnSuplantacion.estaSobre()) { clasificacionElegidaNivel2 = "Suplantación"; reproducirSonido("click"); }
    if (btnConfirmar.estaSobre() && indiceSeleccionadoNivel2 != -1 && clasificacionElegidaNivel2.length() > 0) {
      boolean ec = opcionesNivel2[indiceSeleccionadoNivel2].esCorrecta;
      boolean cc = clasificacionElegidaNivel2.equals("Calumnia");
      int aciertos = (ec?1:0)+(cc?1:0); int errores = 2-aciertos;
      gravedadNivel2 = calcularGravedadPercibida(58, aciertos, errores, cc, 20);
      int pts = (ec?80:25)+(cc?45:10);
      puntaje += pts;
      if (multi.activo) multi.jugadorActual().puntaje += pts;
      resultadoNivel2 = construirResultado(ec, cc, "Calumnia");
      explicacionNivel2 = construirExplicacionNivel2(ec, cc);
      resolverNivelConSonido("Nivel 2 resuelto", ec&&cc, ec||cc);
      irAPantalla(PANTALLA_RESULTADO_2);
    }
  }

  void manejarClicksNivel3() {
    for (int i = 0; i < opcionesNivel3.length; i++) {
      if (opcionesNivel3[i].estaSobre()) { seleccionPerfil[i] = !seleccionPerfil[i]; reproducirSonido("click"); }
    }
    if (btnInjuria.estaSobre())      { clasificacionElegidaNivel3 = "Injuria";     reproducirSonido("click"); }
    if (btnCalumnia.estaSobre())     { clasificacionElegidaNivel3 = "Calumnia";    reproducirSonido("click"); }
    if (btnSuplantacion.estaSobre()) { clasificacionElegidaNivel3 = "Suplantación"; reproducirSonido("click"); }
    if (btnConfirmar.estaSobre() && clasificacionElegidaNivel3.length() > 0) {
      int aciertos = contarSeleccionesCorrectas(seleccionPerfil, opcionesNivel3);
      int errores  = contarSeleccionesIncorrectas(seleccionPerfil, opcionesNivel3);
      int totalC   = contarOpcionesCorrectas(opcionesNivel3);
      boolean cc   = clasificacionElegidaNivel3.equals("Suplantación");
      boolean logro = (totalC>0 && aciertos==totalC && errores==0 && cc);
      boolean parcial = (!logro) && (aciertos>0 || cc);
      gravedadNivel3 = calcularGravedadPercibida(68, aciertos, errores, cc, 24);
      int pts = aciertos*30 - errores*5 + (cc?50:10);
      puntaje = max(0, puntaje + pts);
      if (multi.activo) multi.jugadorActual().puntaje = max(0, multi.jugadorActual().puntaje + pts);
      resultadoNivel3 = logro ? "EVIDENCIA CORRECTA Y CLASIFICACIÓN CORRECTA"
                        : parcial ? "RESULTADO PARCIAL" : "EVIDENCIA INCORRECTA O INSUFICIENTE";
      explicacionNivel3 = construirExplicacionNivel3(aciertos, errores, cc);
      resolverNivelConSonido("Nivel 3 resuelto", logro, parcial);
      irAPantalla(PANTALLA_RESULTADO_3);
    }
  }

  void manejarClicksNivel4() {
    for (int i = 0; i < opcionesNivel4.length; i++) {
      if (opcionesNivel4[i].estaSobre()) { seleccionCuentas[i] = !seleccionCuentas[i]; reproducirSonido("click"); }
    }
    if (btnInjuria.estaSobre())      { clasificacionElegidaNivel4 = "Injuria";             reproducirSonido("click"); }
    if (btnCalumnia.estaSobre())     { clasificacionElegidaNivel4 = "Calumnia";             reproducirSonido("click"); }
    if (btnSuplantacion.estaSobre()) { clasificacionElegidaNivel4 = "Hostigamiento digital"; reproducirSonido("click"); }
    if (btnConfirmar.estaSobre() && clasificacionElegidaNivel4.length() > 0) {
      int relaciones = contarSeleccionesCorrectas(seleccionCuentas, opcionesNivel4);
      int errores    = contarSeleccionesIncorrectas(seleccionCuentas, opcionesNivel4);
      int totalC     = contarOpcionesCorrectas(opcionesNivel4);
      boolean cc     = clasificacionElegidaNivel4.equals("Hostigamiento digital");
      boolean logro  = (totalC>0 && relaciones==totalC && errores==0 && cc);
      boolean parcial = (!logro) && (relaciones>0 || cc);
      gravedadNivel4 = calcularGravedadPercibida(82, relaciones, errores, cc, 26);
      int pts = relaciones*28 - errores*8 + (cc?55:10);
      puntaje = max(0, puntaje + pts);
      if (multi.activo) multi.jugadorActual().puntaje = max(0, multi.jugadorActual().puntaje + pts);
      agresorIdentificado = logro ? "Red coordinada identificada" : (relaciones>=1 ? "Identificación parcial" : "Pendiente");
      resultadoNivel4 = logro ? "EVIDENCIA CORRECTA Y CLASIFICACIÓN CORRECTA"
                        : parcial ? "RESULTADO PARCIAL" : "EVIDENCIA INCORRECTA O INSUFICIENTE";
      explicacionNivel4 = construirExplicacionNivel4(relaciones, errores, cc);
      resolverNivelConSonido("Nivel 4 resuelto", logro, parcial);
      irAPantalla(PANTALLA_RESULTADO_4);
    }
  }

  void manejarClickResultadoNivel(int nivel) {
    if (btnVolver.estaSobre()) { irAPantalla(nivelAPantalla(nivel)); return; }
    if (btnInsertarCaso.estaSobre()) {
      if (casoInsertado[nivel]) {
        mostrarFeedback("Ese caso ya fue insertado en el árbol", getColor(4));
        reproducirSonido("hover"); irAPantalla(PANTALLA_ARBOL); return;
      }
      reproducirSonido("insertar");
      Caso c = crearCasoDelNivel(nivel);
      arbol.insertar(c);
      arbol.calcularPosiciones(arbol.raiz, width/2.0, sy(260), width/5.0);
      casosRegistrados.add(c);
      casoInsertado[nivel] = true;
      casosResueltos = min(4, casosResueltos+1);
      gravedadTotal += c.gravedad;
      generarReporteFinal();

      // Registrar avance en multijugador sin cambiar de jugador.
      if (multi.activo) {
        boolean acierto = resultadoDelNivel(nivel).indexOf("CORRECTA") >= 0
                       && resultadoDelNivel(nivel).indexOf("PARCIAL") < 0;
        int gravN = gravedadDelNivel(nivel);
        multi.jugadorActual().gravedad += gravN;
        multi.jugadorActual().niveles++;
        if (acierto) multi.jugadorActual().aciertos++;
        multi.nivelMulti = min(4, nivel + 1);
      }

      if (nivel == 4) {
        sospechosoPrincipal = identificarSospechosoPrincipal();
        agresorIdentificado = sospechosoPrincipal;
      }
      mostrarFeedback("Caso insertado en el árbol AVL", getColor(2));

      irAPantallaConDialogo(PANTALLA_ARBOL, getDialogoArbol());
    }
  }

  String resultadoDelNivel(int nivel) {
    if (nivel==1) return resultadoNivel1; if (nivel==2) return resultadoNivel2;
    if (nivel==3) return resultadoNivel3; return resultadoNivel4;
  }
  int gravedadDelNivel(int nivel) {
    if (nivel==1) return gravedadNivel1; if (nivel==2) return gravedadNivel2;
    if (nivel==3) return gravedadNivel3; return gravedadNivel4;
  }

  void manejarClicksArbol() {
    if (arbol.buscarNodoClick(arbol.raiz, mouseX, mouseY) != null) {
      arbol.seleccionarNodo(mouseX, mouseY); return;
    }
    if (casosResueltos < 4) {
      if (btnSiguiente.estaSobre()) {
        reproducirSonido("nivel"); arbol.limpiarSeleccion();
        nivelActual = casosResueltos+1;
        // Mostrar diálogo introductorio del siguiente nivel
        ArrayList<LineaDialogo> dlg = null;
        if (nivelActual==2) dlg = getDialogoNivel2();
        else if (nivelActual==3) dlg = getDialogoNivel3();
        else if (nivelActual==4) dlg = getDialogoNivel4();
        if (dlg != null) irAPantallaConDialogo(nivelAPantalla(nivelActual), dlg);
        else irAPantalla(nivelAPantalla(nivelActual));
      }
    } else {
      if (btnSiguiente.estaSobre()) {
        reproducirSonido("nivel"); tipoRecorridoActual="Inorden"; recorridoMostrado=arbol.inordenTexto();
        irAPantalla(PANTALLA_RECORRIDOS);
      }
    }
  }

  void manejarClicksRecorridos() {
    if (btnVolver.estaSobre())    { arbol.limpiarSeleccion(); irAPantalla(PANTALLA_ARBOL); }
    if (btnInorden.estaSobre())   { tipoRecorridoActual="Inorden";   recorridoMostrado=arbol.inordenTexto(); }
    if (btnPreorden.estaSobre())  { tipoRecorridoActual="Preorden";  recorridoMostrado=arbol.preordenTexto(); }
    if (btnPostorden.estaSobre()) { tipoRecorridoActual="Postorden"; recorridoMostrado=arbol.postordenTexto(); }
    if (btnReporte.estaSobre())   { reproducirSonido("reporte"); ingresarPantallaReporte(); }
  }

  void manejarClicksReporte() {
    if (btnVolver.estaSobre())   { irAPantalla(PANTALLA_RECORRIDOS); return; }
    if (btnSiguiente.estaSobre()) {
      if (multi.activo) {
        boolean terminado = multi.finalizarTurnoActual();
        if (terminado) {
          irAPantalla(PANTALLA_MULTI_FIN);
        } else {
          multi.prepararSiguienteJugador();
          irAPantalla(PANTALLA_CAMBIO_TURNO);
        }
      } else {
        reiniciarPartida();
      }
    }
  }

  void dibujarPantallaCambioTurno() {
    dibujarFondo("fondos/fondo_juego_base.png", color(10, 14, 24));

    float pw = sx(820), ph = sy(470);
    float px = width/2 - pw/2, py = height/2 - ph/2;
    dibujarPanelMarco(px, py, pw, ph, true);

    int alpha = min(255, 120 + frameCount % 135);
    int colAcento = altoContraste ? color(255, 255, 0) : color(84, 221, 189);
    int colSec = altoContraste ? color(255) : color(180, 220, 255);
    String nombreSiguiente = multi.jugadorActual().nombre;

    fill(altoContraste ? color(255) : color(255, 110, 140));
    textAlign(CENTER, CENTER);
    textSize(tx(46));
    text("¡Turno completado!", width/2, py + sy(82));

    fill(colAcento);
    textSize(tx(26));
    text("Ahora le toca a:", width/2, py + sy(170));

    fill(colorTexto());
    textSize(tx(44));
    text(nombreSiguiente, width/2, py + sy(240));

    fill(colSec);
    textSize(tx(19));
    text("Entrega el control y deja que el siguiente detective se prepare.", width/2, py + sy(300));

    String dots = ".";
    int paso = (frameCount / 20) % 3;
    if (paso == 1) dots = "..";
    else if (paso == 2) dots = "...";
    fill(colAcento);
    textSize(tx(24));
    text("Cargando evidencias" + dots, width/2, py + sy(350));

    float bw = sx(500), bh = ss(18);
    float bx = width/2 - bw/2, by = py + sy(335);
    noStroke();
    fill(26, 40, 70, 210);
    rect(bx, by + sy(35), bw, bh, bh/2);
    float progreso = 0.68f + 0.22f * sin(frameCount * 0.05f);
    fill(colAcento, 220);
    rect(bx, by + sy(35), bw * progreso, bh, bh/2);
    fill(255, 70);
    ellipse(bx + bw * progreso, by + sy(44), ss(12), ss(12));

    float anilloY = py + sy(122);
    noFill();
    stroke(colAcento, 130);
    strokeWeight(ss(3));
    arc(width/2, anilloY, ss(78), ss(78), frameCount * 0.06f, frameCount * 0.06f + PI + QUARTER_PI);
    stroke(255, 90);
    arc(width/2, anilloY, ss(54), ss(54), -frameCount * 0.08f, -frameCount * 0.08f + PI/1.8f);
    noStroke();

    float bwBtn = sx(340), bhBtn = sy(66);
    configurarBoton(btnContinuar, width/2 - bwBtn/2, py + ph - sy(172), bwBtn, bhBtn, "COMENZAR TURNO");
    btnContinuar.dibujar(assets);

    subtituloActual = "Cambio de turno listo. Cuando el siguiente jugador esté preparado, comienza su investigación.";
  }

  void manejarClicksCambioTurno() {
    if (btnContinuar.estaSobre()) {
      reiniciarPartida();
      detectiveActivo = multi.jugadorActual().nombre;
      irAPantallaConDialogo(PANTALLA_CONTEXTO, getDialogoContexto());
    }
  }

  // ─── AUXILIARES DE LÓGICA (INTACTOS) ────────────────────────────────────
  int nivelAPantalla(int nivel) {
    if (nivel==1) return PANTALLA_NIVEL_1; if (nivel==2) return PANTALLA_NIVEL_2;
    if (nivel==3) return PANTALLA_NIVEL_3; if (nivel==4) return PANTALLA_NIVEL_4;
    return PANTALLA_INICIO;
  }

  Caso crearCasoDelNivel(int nivel) {
    if (nivel==1) return new Caso(1,1,"Mensajes ofensivos reiterados","Injuria",        construirEvidenciasNivel1(),"Art. 220 Código Penal Colombiano","Multa o sanción por afectar el buen nombre",gravedadNivel1);
    if (nivel==2) return new Caso(2,2,"Rumor falso viralizado","Calumnia",              construirEvidenciasNivel2(),"Art. 221 Código Penal Colombiano","Sanción por imputación falsa de hecho punible",gravedadNivel2);
    if (nivel==3) return new Caso(3,3,"Perfil falso usando imagen de Valeria","Suplantación",construirEvidenciasNivel3(),"Ley 1273 de 2009","Sanciones por delito informático y suplantación",gravedadNivel3);
    return new Caso(4,4,"Ataque coordinado desde varias cuentas","Hostigamiento digital",construirEvidenciasNivel4(),"Hostigamiento reiterado + evidencia digital","Sanciones agravadas por coordinación, amenazas y repetición",gravedadNivel4);
  }

  String identificarSospechosoPrincipal() {
    int mejores = -1; String sospechoso = "Agresor principal inferido por patrones repetidos";
    for (int i = 0; i < min(seleccionCuentas.length, opcionesNivel4.length); i++) {
      if (seleccionCuentas[i] && opcionesNivel4[i].esCorrecta) {
        mejores++; sospechoso = "Nodo coordinador: " + opcionesNivel4[i].texto.split("\n")[0];
      }
    }
    return sospechoso;
  }

  String construirResultado(boolean ec, boolean cc, String esperada) {
    if (ec && cc) return "EVIDENCIA CORRECTA Y CLASIFICACIÓN CORRECTA";
    if (ec || cc) return "RESULTADO PARCIAL. La clasificación esperada era " + esperada;
    return "EVIDENCIA INCORRECTA O INSUFICIENTE. La correcta era " + esperada;
  }

  int calcularGravedadPercibida(int base, int aciertos, int errores, boolean cc, int bonoMax) {
    int ajuste = aciertos*5 - errores*4 + (cc?8:-6);
    ajuste = constrain(ajuste, -12, bonoMax);
    return max(25, base+ajuste);
  }

  void resolverNivelConSonido(String mensaje, boolean logro, boolean parcial) {
    mostrarFeedback(mensaje, logro ? getColor(6) : (parcial ? getColor(4) : getColor(7)));
    reproducirSonido(logro ? "correcto" : (parcial ? "parcial" : "incorrecto"));
  }

  int contarSeleccionesCorrectas(boolean[] sel, OpcionInteractiva[] ops) {
    int t=0; for(int i=0;i<min(sel.length,ops.length);i++) if(sel[i]&&ops[i].esCorrecta) t++; return t;
  }
  int contarSeleccionesIncorrectas(boolean[] sel, OpcionInteractiva[] ops) {
    int t=0; for(int i=0;i<min(sel.length,ops.length);i++) if(sel[i]&&!ops[i].esCorrecta) t++; return t;
  }
  int contarOpcionesCorrectas(OpcionInteractiva[] ops) {
    int t=0; if(ops==null) return 0; for(int i=0;i<ops.length;i++) if(ops[i]!=null&&ops[i].esCorrecta) t++; return t;
  }

  // ─── PISTAS ──────────────────────────────────────────────────────────────
  void mostrarPistaActual() {
    String pista = "";
    if (pantallaActual==PANTALLA_NIVEL_1) pista = pistaNivel1;
    else if (pantallaActual==PANTALLA_NIVEL_2) pista = pistaNivel2;
    else if (pantallaActual==PANTALLA_NIVEL_3) pista = pistaNivel3;
    else if (pantallaActual==PANTALLA_NIVEL_4) pista = pistaNivel4;
    if (pista.length() > 0) {
      if (pistaVisible && pista.equals(pistaMostrada)) {
        pistaVisible = false;
      } else {
        pistaMostrada = pista; pistaVisible = true;
      }
      reproducirSonido("hover");
    }
  }

  boolean esPantallaDeNivel() {
    return pantallaActual==PANTALLA_NIVEL_1||pantallaActual==PANTALLA_NIVEL_2||
           pantallaActual==PANTALLA_NIVEL_3||pantallaActual==PANTALLA_NIVEL_4;
  }

  void dibujarPanelPista(String textoPista) {
    float w=sx(520); float h=sy(98); float x=width/2-w/2; float y=height-sy(165);
    pushStyle();
    noStroke(); fill(0,170); rect(x+5,y+7,w,h,ss(16));
    stroke(altoContraste ? color(255,255,0) : getColor(2)); strokeWeight(ss(2));
    fill(altoContraste ? color(0,220) : color(15,24,38,235)); rect(x,y,w,h,ss(16));
    noStroke(); fill(altoContraste ? color(255,255,0,55) : color(84,221,189,34));
    rect(x+ss(14),y+ss(14),ss(78),h-ss(28),ss(12));
    fill(altoContraste ? color(0) : color(240)); textSize(tx(17)); textAlign(CENTER,CENTER);
    text("PISTA",x+ss(53),y+h*0.5-ss(2));
    fill(colorTexto()); textAlign(LEFT,TOP); textSize(tx(16));
    text(textoPista,x+ss(108),y+ss(20),w-ss(132),h-ss(40));
    popStyle();
  }

  // ─── REPORTE (INTACTO) ────────────────────────────────────────────────────
  void generarReporteFinal() {
    ArrayList<Caso> cr = obtenerCasosParaReporte();
    if ((cr==null||cr.size()==0) && arbol.raiz!=null) cr = obtenerCasosDesdeArbol();
    if (cr==null) cr = new ArrayList<Caso>();
    StringBuilder sb = new StringBuilder();
    sb.append("Detective: ").append(valorOPlaceholder(detectiveActivo)).append("\n");
    sb.append("Responsable: ").append(valorOPlaceholder(agresorIdentificado)).append("\n");
    sb.append("Casos integrados: ").append(cr.size()).append("\n");
    sb.append("Gravedad acumulada: ").append(gravedadTotal).append("\n\n");
    if (cr.size()==0) {
      sb.append("No hay casos suficientes. Resuelve niveles e inserta nodos.\n");
      if (resultadoNivel1.length()>0) sb.append("• N1: ").append(resultadoNivel1).append("\n");
      if (resultadoNivel2.length()>0) sb.append("• N2: ").append(resultadoNivel2).append("\n");
      if (resultadoNivel3.length()>0) sb.append("• N3: ").append(resultadoNivel3).append("\n");
      if (resultadoNivel4.length()>0) sb.append("• N4: ").append(resultadoNivel4).append("\n");
    } else {
      sb.append("Delitos y cierre jurídico:\n");
      for (int i=0;i<cr.size();i++) {
        Caso c=cr.get(i);
        sb.append(i+1).append(". ").append(valorOPlaceholder(c.tipoDelito))
          .append(" | gravedad ").append(c.gravedad)
          .append("\nLey: ").append(valorOPlaceholder(c.ley))
          .append("\nPena: ").append(valorOPlaceholder(c.pena))
          .append("\nEvidencia: ").append(extraerResumenEvidencia(c.evidencias)).append("\n\n");
      }
      sb.append("Conclusión: el árbol AVL demuestra la escalada del acoso. El recorrido inorden reconstruye la progresión de menor a mayor gravedad.");
    }
    String nuevoGen = sb.toString();
    String nuevoVis = construirResumenVisibleReporte(cr);
    boolean cambios = !nuevoGen.equals(reporteFinalGenerado)||!nuevoVis.equals(reporteFinalVisible);
    reporteFinalGenerado = nuevoGen; reporteFinalVisible = nuevoVis;
    if (cambios) {
      try { saveStrings("reportes/reporte_final_generado.txt", split(reporteFinalGenerado,"\n")); }
      catch(Exception e) { println("No se pudo guardar reporte: "+e.getMessage()); }
    }
  }

  void ingresarPantallaReporte() {
    generarReporteFinal();
    if (reporteFinalVisible==null||trim(reporteFinalVisible).length()==0)
      reporteFinalVisible = construirResumenVisibleReporte(obtenerCasosParaReporte());
    irAPantallaConDialogo(PANTALLA_REPORTE, getDialogoReporte());
  }

  String reporteVisibleEnPantalla() {
    if (reporteFinalVisible!=null&&trim(reporteFinalVisible).length()>0) return reporteFinalVisible;
    if (reporteFinalGenerado!=null&&trim(reporteFinalGenerado).length()>0) return reporteFinalGenerado;
    return "Reporte en preparación...";
  }

  String construirResumenVisibleReporte(ArrayList<Caso> cr) {
    StringBuilder v = new StringBuilder();
    v.append("Detective: ").append(valorOPlaceholder(detectiveActivo)).append("\n");
    v.append("Responsable: ").append(valorOPlaceholder(agresorIdentificado)).append("\n");
    v.append("Casos registrados: ").append(cr.size()).append("\n");
    v.append("Gravedad total: ").append(gravedadTotal).append("\n\n");
    if (cr.size()==0) { v.append("Aún no hay casos integrados. Inserta los casos en el árbol AVL."); return v.toString(); }
    for (int i=0;i<cr.size();i++) {
      Caso c=cr.get(i);
      v.append(i+1).append(") ").append(valorOPlaceholder(c.tipoDelito))
       .append(" | gravedad ").append(c.gravedad)
       .append("\nLey: ").append(valorOPlaceholder(c.ley))
       .append("\nPena: ").append(valorOPlaceholder(c.pena));
      if (i<cr.size()-1) v.append("\n\n");
    }
    v.append("\n\nConclusión: el árbol AVL evidencia la escalada progresiva del acoso.");
    return v.toString();
  }

  String extraerResumenEvidencia(String ev) {
    if (ev==null||ev.length()==0) return "Sin evidencia";
    String l = ev.replace("\n"," | ");
    return l.length()>120 ? l.substring(0,117)+"..." : l;
  }

  ArrayList<Caso> obtenerCasosParaReporte() {
    ArrayList<Caso> lista = new ArrayList<Caso>();
    if (casosRegistrados!=null&&casosRegistrados.size()>0) lista.addAll(casosRegistrados);
    else if (arbol!=null&&arbol.raiz!=null) lista.addAll(obtenerCasosDesdeArbol());
    else {
      if(gravedadNivel1>0) lista.add(crearCasoFallback(1,gravedadNivel1,resultadoNivel1,explicacionNivel1,clasificacionElegidaNivel1,"Injuria"));
      if(gravedadNivel2>0) lista.add(crearCasoFallback(2,gravedadNivel2,resultadoNivel2,explicacionNivel2,clasificacionElegidaNivel2,"Calumnia"));
      if(gravedadNivel3>0) lista.add(crearCasoFallback(3,gravedadNivel3,resultadoNivel3,explicacionNivel3,clasificacionElegidaNivel3,"Suplantación"));
      if(gravedadNivel4>0) lista.add(crearCasoFallback(4,gravedadNivel4,resultadoNivel4,explicacionNivel4,clasificacionElegidaNivel4,"Hostigamiento digital"));
    }
    gravedadTotal = 0; for (Caso c : lista) gravedadTotal += c.gravedad;
    return lista;
  }

  ArrayList<Caso> obtenerCasosDesdeArbol() {
    ArrayList<Caso> l=new ArrayList<Caso>(); recolectarInorden(arbol.raiz,l); return l;
  }
  void recolectarInorden(NodoAVL n, ArrayList<Caso> l) {
    if(n==null) return; recolectarInorden(n.izq,l); l.add(n.caso); recolectarInorden(n.der,l);
  }

  Caso crearCasoFallback(int nivel, int grav, String res, String expl, String clas, String base) {
    String delito = valorOPlaceholder(clas); if(delito.equals("Sin clasificar")) delito=base;
    String ley="Pendiente"; String pena="Pendiente";
    if(delito.equals("Injuria")){ley="Art. 220 CP";pena="Multa/sanción buen nombre";}
    else if(delito.equals("Calumnia")){ley="Art. 221 CP";pena="Sanción imputación falsa";}
    else if(delito.contains("Suplantaci")){delito="Suplantación";ley="Ley 1273 de 2009";pena="Sanción delito informático";}
    else if(delito.equals("Hostigamiento digital")){ley="Hostigamiento reiterado";pena="Sanciones agravadas";}
    return new Caso(nivel,nivel,"Caso reconstruido",delito,valorOPlaceholder(res)+"\n"+valorOPlaceholder(expl),ley,pena,grav);
  }

  String valorOPlaceholder(String v) { return (v==null||v.length()==0) ? "Sin clasificar" : v; }

  // ─── CONSTRUCCIÓN DE EVIDENCIAS (INTACTO) ────────────────────────────────
  String construirEvidenciasNivel1() {
    StringBuilder sb=new StringBuilder(); sb.append(resultadoNivel1);
    if(indiceSeleccionadoNivel1>=0&&indiceSeleccionadoNivel1<opcionesNivel1.length)
      sb.append("\n- Mensaje: ").append(opcionesNivel1[indiceSeleccionadoNivel1].texto);
    sb.append("\n- Clasificación: ").append(valorOPlaceholder(clasificacionElegidaNivel1));
    sb.append("\n- Explicación: ").append(explicacionNivel1); return sb.toString();
  }
  String construirEvidenciasNivel2() {
    StringBuilder sb=new StringBuilder(); sb.append(resultadoNivel2);
    if(indiceSeleccionadoNivel2>=0&&indiceSeleccionadoNivel2<opcionesNivel2.length)
      sb.append("\n- Publicación: ").append(opcionesNivel2[indiceSeleccionadoNivel2].texto.replace("\n"," | "));
    sb.append("\n- Clasificación: ").append(valorOPlaceholder(clasificacionElegidaNivel2));
    sb.append("\n- Explicación: ").append(explicacionNivel2); return sb.toString();
  }
  String construirEvidenciasNivel3() {
    StringBuilder sb=new StringBuilder(); sb.append(resultadoNivel3);
    sb.append("\n- Evidencias: ");
    boolean alguna=false;
    for(int i=0;i<min(seleccionPerfil.length,opcionesNivel3.length);i++) {
      if(seleccionPerfil[i]){if(alguna)sb.append(" ; ");sb.append(opcionesNivel3[i].texto);alguna=true;}
    }
    if(!alguna) sb.append("Ninguna");
    sb.append("\n- Clasificación: ").append(valorOPlaceholder(clasificacionElegidaNivel3));
    sb.append("\n- Explicación: ").append(explicacionNivel3); return sb.toString();
  }
  String construirEvidenciasNivel4() {
    StringBuilder sb=new StringBuilder(); sb.append(resultadoNivel4);
    sb.append("\n- Cuentas: ");
    boolean alguna=false;
    for(int i=0;i<min(seleccionCuentas.length,opcionesNivel4.length);i++) {
      if(seleccionCuentas[i]){if(alguna)sb.append(" ; ");sb.append(opcionesNivel4[i].texto.replace("\n"," | "));alguna=true;}
    }
    if(!alguna) sb.append("Ninguna");
    sb.append("\n- Clasificación: ").append(valorOPlaceholder(clasificacionElegidaNivel4));
    sb.append("\n- Explicación: ").append(explicacionNivel4); return sb.toString();
  }

  // ─── EXPLICACIONES (INTACTAS) ─────────────────────────────────────────────
  String construirExplicacionNivel1(boolean ec, boolean cc) {
    if(ec&&cc) return "Level up: detectaste un insulto reiterado y lo clasificaste como injuria.";
    if(ec) return "Detectaste el mensaje ofensivo, pero fallaste la tipificación. Insultos directos = injuria.";
    if(cc) return "Entendiste la figura jurídica, pero no elegiste la evidencia más fuerte.";
    return "Fallaste evidencia y clasificación. Busca el insulto o humillación directa.";
  }
  String construirExplicacionNivel2(boolean ec, boolean cc) {
    if(ec&&cc) return "Level up: rastreaste la publicación inicial y la clasificaste como calumnia.";
    if(ec) return "Encontraste el origen, pero la categoría es calumnia: acusar falsamente de un delito.";
    if(cc) return "Elegiste bien la figura penal, pero no la publicación inicial. El origen pesa más.";
    return "Fallaste la trazabilidad. Identifica la publicación que inventa el hecho falso.";
  }
  String construirExplicacionNivel3(int a, int e, boolean cc) {
    if(a>=2&&e==0&&cc) return "Level up: demostraste la suplantación con evidencias sólidas.";
    if(cc) return "La categoría legal está bien, pero la prueba es mejorable.";
    return "La suplantación requiere probar identidad duplicada, alias imitador o datos copiados.";
  }
  String construirExplicacionNivel4(int r, int e, boolean cc) {
    if(r>=3&&e==0&&cc) return "Level up: conectaste la red coordinada y cerraste el caso correctamente.";
    if(cc) return "La figura es correcta, pero faltó conectar mejor las cuentas coordinadas.";
    return "Debes demostrar conducta reiterada y coordinada: red, patrón y responsable principal.";
  }

  // ─── PREPARACIÓN DE NIVELES (INTACTA) ────────────────────────────────────
  String[] seleccionarMezclaControlada(String[] correctas, String[] incorrectas, int numC, int total) {
    String[] corr = seleccionarTextosAleatorios(correctas, min(numC, correctas.length));
    String[] inc  = seleccionarTextosAleatorios(incorrectas, min(max(0, total-corr.length), incorrectas.length));
    String[] mezcla = new String[corr.length+inc.length];
    int k=0;
    for(String s:corr) mezcla[k++]=s;
    for(String s:inc)  mezcla[k++]=s;
    return barajar(mezcla);
  }

  void prepararNivel1() {
    pistaVisible=false; pistaMostrada=""; indiceCorrectoNivel1=-1;
    String[] correctas = {"Te voy a arruinar la reputación.","Eres ridícula y das vergüenza.","Todo el mundo se ríe de ti.","Nadie te soporta aquí."};
    String[] incorrectas = {"Nos vemos mañana para estudiar.","Qué presentación tan buena hiciste.","Pásame el taller cuando puedas.","Trae el cuaderno en la tarde."};
    String[] sel = seleccionarMezclaControlada(correctas, incorrectas, 1, 4);
    opcionesNivel1 = new OpcionInteractiva[sel.length];
    for (int i=0;i<sel.length;i++) {
      boolean c=false; for(String s:correctas) if(sel[i].equals(s)) c=true;
      opcionesNivel1[i] = new OpcionInteractiva(sx(675), sy(255+i*90), sx(570), sy(72), sel[i], c);
      if(c) indiceCorrectoNivel1=i;
    }
    indiceSeleccionadoNivel1=-1; clasificacionElegidaNivel1="";
    pistaNivel1 = "Busca el mensaje con insulto o humillación directa. Compáralo con los mensajes neutrales.";
  }

  void prepararNivel2() {
    pistaVisible=false; pistaMostrada=""; indiceCorrectoNivel2=-1;
    String[] correctas = {"Publicación A: Valeria hackeó el sistema de la universidad.","Publicación D: Dicen que la expulsarán por fraude."};
    String[] incorrectas = {"Publicación B: Solo vi que muchos comentaron la historia.","Publicación C: Todavía nadie ha publicado una acusación concreta.","Publicación E: El grupo estaba activo, pero sin autor identificado.","Publicación F: Hay rumores, pero aquí no se formula una acusación falsa."};
    String[] sel = seleccionarMezclaControlada(correctas, incorrectas, 1, 4);
    opcionesNivel2 = new OpcionInteractiva[sel.length];
    for (int i=0;i<sel.length;i++) {
      boolean c=false; for(String s:correctas) if(sel[i].equals(s)) c=true;
      opcionesNivel2[i] = new OpcionInteractiva(sx(130+i*300), sy(300), sx(260), sy(240), sel[i], c);
      if(c) indiceCorrectoNivel2=i;
    }
    indiceSeleccionadoNivel2=-1; clasificacionElegidaNivel2="";
    pistaNivel2 = "La publicación original afirma un hecho falso grave; las otras solo comentan, dudan o reenvían.";
  }

  void prepararNivel3() {
    pistaVisible=false; pistaMostrada="";
    String[] correctas = {"Foto de perfil idéntica a la de Valeria|true","Alias muy parecido: valeria.oficial_02|true","Biografía copiando datos personales de Valeria|true"};
    String[] incorrectas = {"Correo irrelevante sin relación|false","Tema visual distinto pero sin datos comprometidos|false"};
    String[] sel = seleccionarMezclaControlada(correctas, incorrectas, 2, 3);
    opcionesNivel3 = new OpcionInteractiva[3];
    for (int i=0;i<3;i++) {
      String[] partes = split(sel[i], "|");
      opcionesNivel3[i] = new OpcionInteractiva(sx(710), sy(305+i*95), sx(500), sy(80), partes[0], partes[1].equals("true"));
    }
    for (int i=0;i<seleccionPerfil.length;i++) seleccionPerfil[i]=false;
    clasificacionElegidaNivel3="";
    pistaNivel3 = "Revisa con precaucion. Hay dos evidencias válidas aquí.";
  }

  void prepararNivel4() {
    pistaVisible=false; pistaMostrada="";
    String[] correctas = {"Cuenta A Misma frase ofensiva Misma hora|true","Cuenta B Mismo patrón Misma red|true","Cuenta D Amenazas directas Mismo horario|true","Cuenta F Repite insultos exactos Ataque en grupo|true"};
    String[] incorrectas = {"Cuenta C Usuario normal Sin relación|false","Cuenta E Comparte memes viejos Sin conexión|false"};
    String[] sel = seleccionarMezclaControlada(correctas, incorrectas, 3, 4);
    opcionesNivel4 = new OpcionInteractiva[4];
    float[] xs = {sx(145), sx(145), width-sx(145)-sx(250), width-sx(145)-sx(250)};
    float[] ys = {sy(300), sy(435), sy(300), sy(435)};
    for (int i=0;i<4;i++) {
      String[] partes = split(sel[i],"|");
      opcionesNivel4[i] = new OpcionInteractiva(xs[i], ys[i], sx(250), sy(112), partes[0], partes[1].equals("true"));
    }
    for (int i=0;i<seleccionCuentas.length;i++) seleccionCuentas[i]=false;
    clasificacionElegidaNivel4="";
    pistaNivel4 = "Marca las tres cuentas que repiten insultos, comparten horario o muestran la misma red de origen.";
    agresorIdentificado = "Pendiente de correlación de cuentas";
  }
}
