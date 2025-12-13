ArrayList<Heart> hearts;
ArrayList<Particle> particles;

void setup() {
  size(1200, 800);            // Oder fullScreen()
  colorMode(HSB, 360, 100, 100, 100);  // Für schöne warme Farben
  generateNewRain();
  
  // Hinweistext
  textAlign(CENTER);
  textSize(16);
}

void draw() {
  // Sanfter Hintergrund-Verlauf (Himmel)
  for (int i = 0; i <= height; i++) {
    float inter = map(i, 0, height, 0, 1);
    color c = lerpColor(color(200, 30, 95), color(180, 20, 100), inter); // Hellblau zu leicht rosa
    stroke(c);
    line(0, i, width, i);
  }
  
  // Herzen aktualisieren und zeichnen
  for (int i = hearts.size() - 1; i >= 0; i--) {
    Heart h = hearts.get(i);
    h.update();
    h.display();
    
    if (h.isDead()) {
      // Beim Aufprall Partikel erzeugen
      for (int j = 0; j < 20; j++) {
        particles.add(new Particle(h.x, h.y, h.hue));
      }
      hearts.remove(i);
    }
  }
  
  // Partikel aktualisieren und zeichnen
  for (int i = particles.size() - 1; i >= 0; i--) {
    Particle p = particles.get(i);
    p.update();
    p.display();
    if (p.isDead()) {
      particles.remove(i);
    }
  }
  
  // Neues Herz von oben nach unten spawnen
  if (frameCount % 15 == 0) {  // Alle 15 Frames ein neues Herz
    hearts.add(new Heart(random(width), -50));
  }
  
  // Bedienhinweise
  fill(0, 50);
  text("Herzen-Regen · Symbol für fallende Liebe und Güte", width/2, height - 40);
  text("'n' = neuer Regen  ·  's' = Bild speichern", width/2, height - 20);
}

void keyPressed() {
  if (key == 'n' || key == 'N') {
    generateNewRain();
  }
  if (key == 's' || key == 'S') {
    String filename = "herzen_regen_" + nf(frameCount, 5) + ".png";
    save(filename);
    println("Gespeichert: " + filename);
  }
}

void generateNewRain() {
  background(200, 20, 95);
  hearts = new ArrayList<Heart>();
  particles = new ArrayList<Particle>();
  
  // Start mit ein paar Herzen
  for (int i = 0; i < 20; i++) {
    hearts.add(new Heart(random(width), random(-200, -50)));
  }
}

class Heart {
  float x, y;
  float vy = random(1, 3);      // Fallgeschwindigkeit
  float size = random(20, 50);
  float hue = random(300, 360); // Rosa bis Rot
  float pulse = 0;
  
  Heart(float x, float y) {
    this.x = x;
    this.y = y;
  }
  
  void update() {
    y += vy;
    pulse += 0.05;
  }
  
  boolean isDead() {
    return y > height + size;
  }
  
  void display() {
    float pulsingSize = size + sin(pulse) * 8;
    
    pushMatrix();
    translate(x, y);
    scale(pulsingSize / 40);  // Skalierung auf Basis der Größe
    
    noStroke();
    fill(hue, 80, 100, 90);
    
    // Klassische Herzform aus zwei Kreisen + Dreieck
    beginShape();
    vertex(0, 15);
    bezierVertex(30, -10, 50, 10, 0, 40);
    bezierVertex(-50, 10, -30, -10, 0, 15);
    endShape(CLOSE);
    
    popMatrix();
  }
}

class Particle {
  float x, y;
  float vx, vy;
  float life = 100;
  float hue;
  
  Particle(float x, float y, float hue) {
    this.x = x;
    this.y = y;
    this.hue = hue;
    float angle = random(TWO_PI);
    float speed = random(1, 4);
    vx = cos(angle) * speed;
    vy = sin(angle) * speed - 2;  // Leicht nach oben
  }
  
  void update() {
    x += vx;
    y += vy;
    vy += 0.1;  // Schwerkraft
    life -= 2;
  }
  
  boolean isDead() {
    return life <= 0;
  }
  
  void display() {
    noStroke();
    fill(hue, 80, 100, life);
    ellipse(x, y, life/10, life/10);
  }
}
