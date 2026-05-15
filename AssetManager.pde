class AssetManager {
  PApplet p;
  HashMap<String, PImage> cache;
  HashSet<String> placeholders;

  AssetManager(PApplet p) {
    this.p     = p;
    cache      = new HashMap<String, PImage>();
    placeholders = new HashSet<String>();
  }

  PImage get(String ruta) {
    if (cache.containsKey(ruta)) return cache.get(ruta);
    PImage img = null;
    try { img = p.loadImage(ruta); } catch(Exception e) { img = null; }
    if (img == null || img.width <= 0) {
      img = crearPlaceholder(ruta);
      placeholders.add(ruta);
    }
    cache.put(ruta, img);
    return img;
  }

  boolean esPlaceholder(String ruta) { return placeholders.contains(ruta); }

  PImage crearPlaceholder(String nombre) {
    PGraphics pg = createGraphics(420, 220);
    pg.beginDraw();
    pg.background(28, 36, 54);
    pg.stroke(80, 140, 200, 120);
    pg.noFill();
    pg.rect(8, 8, pg.width-16, pg.height-16, 18);
    pg.fill(180, 200, 230);
    pg.textAlign(CENTER, CENTER);
    pg.textSize(16);
    pg.text(nombre, pg.width/2, pg.height/2);
    pg.endDraw();
    return pg.get();
  }
}
