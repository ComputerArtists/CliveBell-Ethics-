ArrayList<Heart> hearts;
ArrayList<Particle> particles;
String[] messages = {"Liebe", "Freude", "Danke", "Güte", "Frieden", "Hoffnung", "Lächeln", "Wärme", "Vertrauen", "Licht", "Harmonie", "Mitgefühl"};

void setup() {
  size(1200, 800);
  colorMode(HSB, 360, 100, 100, 100);
  textAlign(CENTER, CENTER);
  textSize(12);
  generateNewRain();
}

void draw() {
  background(330, 70, 15);  // Dunkles Pink-Lila für schönen Kontrast
  
  // Herzen
  for (int i = hearts.size() - 1; i >= 0; i--) {
    Heart h = hearts.get(i);
    h.update();
    h.display();
    
    if (h.isDead()) {
  for (int j = 0; j < 7; j++) {
    String msg = messages[int(random(messages.length))];  // Neu gewählt pro Partikel!
    particles.add(new Particle(h.x, h.y, h.hue, msg));
  }
  hearts.remove(i);
}
  }
  
  // Partikel
  for (int i = particles.size() - 1; i >= 0; i--) {
    Particle p = particles.get(i);
    p.update();
    p.display();
    if (p.isDead()) particles.remove(i);
  }
  
  // Mitteldichter Regen
  if (frameCount % 10 == 0) {
    hearts.add(new Heart(random(width), -50));
  }
  
  fill(0, 0, 100, 70);
  textSize(12);
  text("Herzen-Regen in mittlerer Größe · Maus für magisches Auffangen", width/2, height - 50);
  text("'n' = neuer Regen  ·  's' = speichern", width/2, height - 25);
}

void keyPressed() {
  if (key == 'n' || key == 'N') generateNewRain();
  if (key == 's' || key == 'S') {
    save("herzen_regen_mittel_" + nf(frameCount, 5) + ".png");
    println("Gespeichert!");
  }
}

void generateNewRain() {
  hearts = new ArrayList<Heart>();
  particles = new ArrayList<Particle>();
  for (int i = 0; i < 20; i++) {
    hearts.add(new Heart(random(width), random(-400, -50)));
  }
}

class Heart {
  float x, y;
  float baseVy = random(1.5, 3);
  float vy;
  float size = random(5, 12);  // Mittlere Größe – perfekt sichtbar
  float hue = random(320, 360);
  float pulse = 0;
  float rotation = 0;
  
  Heart(float x, float y) {
    this.x = x;
    this.y = y;
    this.vy = baseVy;
  }
  
  void update() {
    float d = dist(mouseX, mouseY, x, y);
    float influence = map(d, 0, 150, 1, 0);
    influence = constrain(influence, 0, 1);
    
    vy = lerp(baseVy, 0.5, 1 - influence);
    rotation += 0.015 * (1 - influence);
    
    pulse += 0.06;
    y += vy;
  }
  
  boolean isDead() {
    return y > height + size * 2;
  }
  
  void display() {
    float d = dist(mouseX, mouseY, x, y);
    float influence = map(d, 0, 150, 1, 0);
    influence = constrain(influence, 0, 1);
    
    float pulsingSize = size + sin(pulse) * 8;
    pulsingSize *= (1 + (1 - influence) * 1.2);
    
    pushMatrix();
    translate(x, y);
    rotate(rotation);
    
    // Sanfter Glow (2 Schichten)
    for (int g = 2; g > 0; g--) {
      float glowAlpha = 40 / g;
      float glowSize = pulsingSize * (1 + g * 0.3);
      scale(glowSize / 30);
      
      noStroke();
      fill(hue, 85, 100, glowAlpha);
      
      beginShape();
      vertex(0, 15);
      bezierVertex(30, -10, 50, 10, 0, 40);
      bezierVertex(-50, 10, -30, -10, 0, 15);
      endShape(CLOSE);
    }
    
    // Kern-Herz
    scale(pulsingSize / 30 / 2);
    fill(hue, 100, 100, 100);
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
  String message;
  
  Particle(float x, float y, float hue, String msg) {
    this.x = x;
    this.y = y;
    this.hue = hue;
    this.message = msg;
    float angle = random(TWO_PI);
    float speed = random(1, 4);
    vx = cos(angle) * speed;
    vy = sin(angle) * speed - 2;
  }
  
  void update() {
    x += vx;
    y += vy;
    vy += 0.09;
    life -= 1.8;
  }
  
  boolean isDead() {
    return life <= 0;
  }
  
  void display() {
    // Glow-Partikel
    fill(hue, 85, 100, life / 2);
    ellipse(x, y, life/6, life/6);
    
    if (life > 10) {
      fill(0, 0, 100, life);
      textSize(life);
      text(message, x, y);
    }
  }
}
