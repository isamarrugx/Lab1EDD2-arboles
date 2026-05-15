class ArbolAVL {
  NodoAVL raiz;
  NodoAVL nodoSeleccionado;

  int altura(NodoAVL n) { return n == null ? 0 : n.altura; }
  int getBalance(NodoAVL n) { return n == null ? 0 : altura(n.izq) - altura(n.der); }

  NodoAVL rotacionDerecha(NodoAVL y) {
    NodoAVL x  = y.izq;
    NodoAVL T2 = x.der;
    x.der = y;
    y.izq = T2;
    y.altura = max(altura(y.izq), altura(y.der)) + 1;
    x.altura = max(altura(x.izq), altura(x.der)) + 1;
    x.resaltar("ROT");
    y.resaltar("ROT");
    reproducirSonido("rotacion");
    return x;
  }

  NodoAVL rotacionIzquierda(NodoAVL x) {
    NodoAVL y  = x.der;
    NodoAVL T2 = y.izq;
    y.izq = x;
    x.der = T2;
    x.altura = max(altura(x.izq), altura(x.der)) + 1;
    y.altura = max(altura(y.izq), altura(y.der)) + 1;
    x.resaltar("ROT");
    y.resaltar("ROT");
    reproducirSonido("rotacion");
    return y;
  }

  void insertar(Caso caso) { raiz = insertarRec(raiz, caso); }

  NodoAVL insertarRec(NodoAVL nodo, Caso c) {
    if (nodo == null) {
      reproducirSonido("insertar");
      return new NodoAVL(c);
    }
    if (c.gravedad < nodo.caso.gravedad)      nodo.izq = insertarRec(nodo.izq, c);
    else if (c.gravedad > nodo.caso.gravedad) nodo.der = insertarRec(nodo.der, c);
    else { c.gravedad += 1; nodo.der = insertarRec(nodo.der, c); }

    nodo.altura = 1 + max(altura(nodo.izq), altura(nodo.der));
    int balance = getBalance(nodo);

    if (balance >  1 && c.gravedad < nodo.izq.caso.gravedad) return rotacionDerecha(nodo);
    if (balance < -1 && c.gravedad > nodo.der.caso.gravedad) return rotacionIzquierda(nodo);
    if (balance >  1 && c.gravedad > nodo.izq.caso.gravedad) { nodo.izq = rotacionIzquierda(nodo.izq); return rotacionDerecha(nodo); }
    if (balance < -1 && c.gravedad < nodo.der.caso.gravedad) { nodo.der = rotacionDerecha(nodo.der);   return rotacionIzquierda(nodo); }
    return nodo;
  }

  void calcularPosiciones(NodoAVL n, float x, float y, float sepX) {
    if (n == null) return;
    n.targetX = x; n.targetY = y;
    calcularPosiciones(n.izq, x - sepX, y + 130, sepX * 0.6);
    calcularPosiciones(n.der, x + sepX, y + 130, sepX * 0.6);
  }

  void actualizarAnimaciones(NodoAVL n) {
    if (n == null) return;
    n.x = lerp(n.x, n.targetX, 0.08);
    n.y = lerp(n.y, n.targetY, 0.08);
    if (n.brilloFrames > 0) n.brilloFrames--;
    actualizarAnimaciones(n.izq);
    actualizarAnimaciones(n.der);
  }

  void dibujarAnimado(NodoAVL n, boolean altoContraste, PApplet p) {
    if (n == null) return;
    p.stroke(getColor(2)); p.strokeWeight(2);
    if (n.izq != null) p.line(n.x, n.y + 35, n.izq.x, n.izq.y - 35);
    if (n.der != null) p.line(n.x, n.y + 35, n.der.x, n.der.y - 35);
    dibujarAnimado(n.izq, altoContraste, p);
    dibujarAnimado(n.der, altoContraste, p);

    boolean sel    = n == nodoSeleccionado;
    float diametro = sel ? 88 : 80;

    p.noStroke(); p.fill(0, 60); p.ellipse(n.x + 4, n.y + 6, diametro, diametro);
    if (n.brilloFrames > 0 || sel) {
      float pulso = sel ? 85 : map(n.brilloFrames, 0, 70, 0, 80);
      p.fill(sel ? getColor(6) : getColor(4), 70 + pulso * 0.5);
      p.ellipse(n.x, n.y, diametro + 28, diametro + 28);
    }
    p.fill(getColor(2), 30); p.ellipse(n.x, n.y, diametro + 10, diametro + 10);
    p.fill(altoContraste ? 0 : getColor(1));
    p.stroke(sel ? getColor(6) : getColor(2)); p.strokeWeight(sel ? 4 : 3);
    p.ellipse(n.x, n.y, diametro, diametro);
    p.noStroke();
    p.fill(sel ? getColor(6) : getColor(3)); p.ellipse(n.x, n.y - 40, 24, 24);
    p.fill(255); p.textAlign(p.CENTER, p.CENTER); p.textSize(22);
    p.text(n.caso.gravedad, n.x, n.y - 5);
    p.textSize(12); p.fill(altoContraste ? p.color(255,255,0) : getColor(8));
    p.text(n.caso.tipoDelito, n.x, n.y + 20);
    if ((n.brilloFrames > 0 || sel) && n.etiquetaAnimacion != null && n.etiquetaAnimacion.length() > 0) {
      p.fill(sel ? getColor(6) : getColor(4)); p.textSize(11);
      p.text(sel ? "INFO" : n.etiquetaAnimacion, n.x, n.y - 58);
    }
  }

  void seleccionarNodo(float mx, float my) {
    NodoAVL encontrado = buscarNodoClick(raiz, mx, my);
    nodoSeleccionado   = encontrado;
    if (encontrado != null) {
      encontrado.resaltar("INFO");
      reproducirSonido("click");
    }
  }

  NodoAVL buscarNodoClick(NodoAVL nodo, float mx, float my) {
    if (nodo == null) return null;
    if (nodo.contiene(mx, my)) return nodo;
    NodoAVL izq = buscarNodoClick(nodo.izq, mx, my);
    return izq != null ? izq : buscarNodoClick(nodo.der, mx, my);
  }

  void limpiarSeleccion() { nodoSeleccionado = null; }

  void dibujarInfoNodo(float x, float y, float w, float h, boolean altoContraste, PApplet p) {
    if (nodoSeleccionado == null) return;
    Caso c = nodoSeleccionado.caso;
    p.pushStyle();
    p.noStroke(); p.fill(0, 150); p.rect(x+6, y+8, w, h, 18);
    p.stroke(altoContraste ? p.color(255,255,0) : getColor(2)); p.strokeWeight(2);
    p.fill(altoContraste ? 0 : p.color(20,28,44,235)); p.rect(x, y, w, h, 18);
    p.noStroke(); p.fill(altoContraste ? p.color(255,255,0,50) : p.color(84,221,189,28));
    p.rect(x+14, y+14, w-28, 34, 12);
    p.fill(altoContraste ? p.color(255,255,0) : p.color(245));
    p.textAlign(p.LEFT, p.TOP); p.textSize(18);
    p.text("NODO SELECCIONADO", x+18, y+20);
    p.textSize(15);
    String bloque = "ID: "+c.id+"   Nivel: "+c.nivel+"   Gravedad: "+c.gravedad+"\n"+
                    "Delito: "+c.tipoDelito+"\nLey: "+c.ley+"\nPena: "+c.pena;
    p.text(bloque, x+18, y+58, w*0.46, h-80);
    p.fill(altoContraste ? p.color(255,255,0) : getColor(6)); p.textSize(15);
    p.text("EVIDENCIAS", x+w*0.50, y+58);
    p.fill(altoContraste ? p.color(255) : p.color(240)); p.textSize(14);
    p.text(c.evidencias, x+w*0.50, y+84, w*0.44, h-108);
    p.fill(altoContraste ? p.color(255,255,0) : getColor(8)); p.textSize(15);
    p.text("DESCRIPCIÓN", x+18, y+h-72);
    p.fill(altoContraste ? p.color(255) : p.color(232)); p.textSize(13);
    p.text(c.descripcion, x+18, y+h-48, w-36, 36);
    p.popStyle();
  }

  // ─── Recorridos ──────────────────────────────────────────────────────────
  String inordenTexto()   { ArrayList<String> l = new ArrayList<String>(); inorden(raiz,l);   return unir(l); }
  String preordenTexto()  { ArrayList<String> l = new ArrayList<String>(); preorden(raiz,l);  return unir(l); }
  String postordenTexto() { ArrayList<String> l = new ArrayList<String>(); postorden(raiz,l); return unir(l); }

  void inorden  (NodoAVL n, ArrayList<String> l) { if(n==null) return; inorden(n.izq,l);  l.add(n.caso.resumen()); inorden(n.der,l);  }
  void preorden (NodoAVL n, ArrayList<String> l) { if(n==null) return; l.add(n.caso.resumen()); preorden(n.izq,l);  preorden(n.der,l);  }
  void postorden(NodoAVL n, ArrayList<String> l) { if(n==null) return; postorden(n.izq,l); postorden(n.der,l); l.add(n.caso.resumen()); }

  String unir(ArrayList<String> lista) {
    if (lista.size() == 0) return "Árbol vacío.";
    StringBuilder sb = new StringBuilder();
    for (int i = 0; i < lista.size(); i++) sb.append(i+1).append(". ").append(lista.get(i)).append("\n");
    return sb.toString();
  }
}
