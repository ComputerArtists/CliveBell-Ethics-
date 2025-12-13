int fractalType = 1;  // 1 = Sierpinski, 2 = Koch, 3 = Baum, 4 = Farn
float growthTimer = 0;
float growthInterval = 3000;

// Separate Listen
ArrayList<Triangle> sierpinskis = new ArrayList<Triangle>();
ArrayList<KochLine> kochs = new ArrayList<KochLine>();
ArrayList<Branch> trees = new ArrayList<Branch>();
ArrayList<BarnsleyPoint> farns = new ArrayList<BarnsleyPoint>();

// Für den Farbverlauf-Hintergrund
color startColor, endColor;

void setup() {
  size(1200, 800);
  colorMode(HSB, 360, 100, 100, 100);
  setGradientBackground();
  generateFractal();
}

void draw() {
  // Kein Fade mehr – Hintergrund bleibt!
  // Nur das Fraktal wird gezeichnet

  if (millis() - growthTimer > growthInterval) {
    growFractal();
    growthTimer = millis();
  }

  if (fractalType == 1) {
    for (Triangle t : sierpinskis) t.display();
  } else if (fractalType == 2) {
    for (KochLine kl : kochs) kl.display();
  } else if (fractalType == 3) {
    for (Branch b : trees) b.display();
  } else if (fractalType == 4) {
    for (BarnsleyPoint p : farns) p.display();
  }

  fill(0, 0, 100, 80);
  textAlign(CENTER, BOTTOM);
  textSize(18);
  text("Fraktales Gutes – Typ " + fractalType, width/2, height - 80);

  textSize(16);
  text("Klicke → wachsen | 1-4 = Typ wechseln | 'n' = neu (neuer Hintergrund) | 's' = speichern", width/2, height - 55);
}

void setGradientBackground() {
  // Zufällige, harmonische Start- und Endfarbe
  float hue1 = random(0, 360);
  float hue2 = (hue1 + random(60, 180)) % 360;  // Harmonisch versetzt
  float sat = random(20, 60);
  float bright = random(85, 100);

  startColor = color(hue1, sat, bright);
  endColor = color(hue2, sat, bright);

  loadPixels();
  for (int y = 0; y < height; y++) {
    float inter = map(y, 0, height, 0, 1);
    color c = lerpColor(startColor, endColor, inter);
    for (int x = 0; x < width; x++) {
      pixels[y * width + x] = c;
    }
  }
  updatePixels();
}

void generateFractal() {
  sierpinskis.clear();
  kochs.clear();
  trees.clear();
  farns.clear();
  growthTimer = millis();

  if (fractalType == 1) {
    PVector a = new PVector(width/2, 100);
    PVector b = new PVector(width/2 - 300, height - 100);
    PVector c = new PVector(width/2 + 300, height - 100);
    sierpinskis.add(new Triangle(a, b, c, 0));
  } else if (fractalType == 2) {
    PVector start = new PVector(200, height/2);
    PVector end = new PVector(width - 200, height/2);
    kochs.add(new KochLine(start, end));
  } else if (fractalType == 3) {
    PVector root = new PVector(width/2, height - 100);
    trees.add(new Branch(root, -PI/2, 100, 0));
  } else if (fractalType == 4) {
    for (int i = 0; i < 5000; i++) {
      farns.add(new BarnsleyPoint());
    }
  }
}

void growFractal() {
  if (fractalType == 1) growSierpinski();
  else if (fractalType == 2) growKoch();
  else if (fractalType == 3) growTree();
  else if (fractalType == 4) growFarn();
}

void keyPressed() {
  if (key >= '1' && key <= '4') {
    fractalType = key - '0';
    setGradientBackground();  // Neuer Hintergrund beim Typwechsel
    generateFractal();
  }
  if (key == 'n' || key == 'N') {
    setGradientBackground();
    generateFractal();
  }
  if (key == 's' || key == 'S') {
    save("fraktales_gutes_typ" + fractalType + "_" + nf(frameCount, 5) + ".png");
    println("Gespeichert!");
  }
}

// === Die Klassen Triangle, KochLine, Branch, BarnsleyPoint und die grow-Funktionen bleiben exakt wie in meiner letzten Nachricht ===
// (Kopiere sie aus der vorherigen Version – sie sind unverändert)


// ==================== Sierpinski ====================
class Triangle {
  PVector a, b, c;
  int depth;

  Triangle(PVector a, PVector b, PVector c, int d) {
    this.a = a;
    this.b = b;
    this.c = c;
    depth = d;
  }

  void display() {
    float hue = map(depth, 0, 8, 200, 60);
    float sat = map(depth, 0, 8, 30, 80);
    float bright = map(depth, 0, 8, 70, 100);
    float alpha = map(depth, 0, 8, 120, 255);

    noStroke();
    fill(hue, sat, bright, alpha);
    triangle(a.x, a.y, b.x, b.y, c.x, c.y);
  }
}

void growSierpinski() {
  ArrayList<Triangle> newTriangles = new ArrayList<Triangle>();
  for (Triangle t : sierpinskis) {
    PVector midAB = PVector.lerp(t.a, t.b, 0.5);
    PVector midBC = PVector.lerp(t.b, t.c, 0.5);
    PVector midCA = PVector.lerp(t.c, t.a, 0.5);

    newTriangles.add(new Triangle(t.a, midAB, midCA, t.depth + 1));
    newTriangles.add(new Triangle(midAB, t.b, midBC, t.depth + 1));
    newTriangles.add(new Triangle(midCA, midBC, t.c, t.depth + 1));
  }
  sierpinskis = newTriangles;
}

// ==================== Koch-Schneeflocke ====================
class KochLine {
  PVector start, end;

  KochLine(PVector s, PVector e) {
    start = s.copy();
    end = e.copy();
  }

  void display() {
    stroke(60, 60, 100, 200);
    strokeWeight(2);
    line(start.x, start.y, end.x, end.y);
  }
}

void growKoch() {
  ArrayList<KochLine> newLines = new ArrayList<KochLine>();
  for (KochLine kl : kochs) {
    PVector a = kl.start;
    PVector e = kl.end;

    PVector v = PVector.sub(e, a);
    v.div(3);

    PVector b = PVector.add(a, v);
    PVector d = PVector.add(b, v);

    v.rotate(-PI/3);
    PVector c = PVector.add(b, v);

    newLines.add(new KochLine(a, b));
    newLines.add(new KochLine(b, c));
    newLines.add(new KochLine(c, d));
    newLines.add(new KochLine(d, e));
  }
  kochs = newLines;
}

// ==================== Fraktaler Baum ====================
class Branch {
  PVector pos;
  float angle;
  float len;
  int depth;

  Branch(PVector p, float a, float l, int d) {
    pos = p.copy();
    angle = a;
    len = l;
    depth = d;
  }

  void display() {
    float hue = map(depth, 0, 8, 100, 140);
    stroke(hue, 70, map(depth, 0, 8, 40, 90));
    strokeWeight(map(depth, 0, 8, 8, 1));
    PVector end = new PVector(pos.x + cos(angle) * len, pos.y + sin(angle) * len);
    line(pos.x, pos.y, end.x, end.y);
  }
}

void growTree() {
  ArrayList<Branch> newBranches = new ArrayList<Branch>();
  for (Branch b : trees) {
    newBranches.add(b);
    if (b.depth < 8) {
      PVector end = new PVector(b.pos.x + cos(b.angle) * b.len, b.pos.y + sin(b.angle) * b.len);
      float newLen = b.len * random(0.7, 0.85);
      newBranches.add(new Branch(end, b.angle + random(-0.4, 0.4), newLen, b.depth + 1));
      newBranches.add(new Branch(end, b.angle - random(-0.4, 0.4), newLen, b.depth + 1));
    }
  }
  trees = newBranches;
}

// ==================== Barnsley-Farn ====================
class BarnsleyPoint {
  float x = 0;
  float y = 0;

  BarnsleyPoint() {
    for (int i = 0; i < 100; i++) updatePoint();  // Stabilisieren
  }

  void updatePoint() {
    float nx, ny;
    float r = random(1);

    if (r < 0.01) {
      nx = 0;
      ny = 0.16 * y;
    } else if (r < 0.86) {
      nx = 0.85 * x + 0.04 * y;
      ny = -0.04 * x + 0.85 * y + 1.6;
    } else if (r < 0.93) {
      nx = 0.2 * x - 0.26 * y;
      ny = 0.23 * x + 0.22 * y + 1.6;
    } else {
      nx = -0.15 * x + 0.28 * y;
      ny = 0.26 * x + 0.24 * y + 0.44;
    }
    x = nx;
    y = ny;
  }

  void display() {
    float px = map(x, -3, 3, 0, width);
    float py = map(y, 0, 10, height, 0);
    noStroke();
    fill(120, 70, 80, 100);
    ellipse(px, py, 2, 2);
  }
}

void growFarn() {
  for (int i = 0; i < 1000; i++) {
    farns.add(new BarnsleyPoint());
  }
}
