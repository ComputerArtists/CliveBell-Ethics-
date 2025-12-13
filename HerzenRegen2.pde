ArrayList<Heart> hearts;
ArrayList<Particle> particles;
String[] messages = {"Liebe", "Freude", "Danke", "Güte", "Frieden", "Hoffnung", "Lächeln", "Wärme", "Vertrauen", "Licht", "Harmonie", "Mitgefühl"};

void setup() {
  size(1200, 800);
  colorMode(HSB, 360, 100, 100, 100);
  textAlign(CENTER, CENTER);
  textSize(14);
  generateNewRain();
}

void draw() {
  // Sanfter Himmel-Verlauf
  for (int i = 0; i <= height; i++) {
    float inter = map(i, 0, height, 0, 1);
    color c = lerpColor(color(200, 30, 95), color(180, 20, 100), inter);
    stroke(c);
    line(0, i, width, i);
  }
  
  // Herzen
  for (int i = hearts.size() - 1; i >= 0; i--) {
    Heart h = hearts.get(i);
    h.update();
    h.display();
    
    if (h.isDead()) {
      String msg = messages[int(random(messages.length))];
      for (int j = 0; j < 25; j++) {
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
  
  // Neue Herzen spawnen
  if (frameCount % 12 == 0) {
    hearts.add(new Heart(random(width), -50));
  }
  
  // Hinweise
  fill(0, 60);
  text("Bewege die Maus nah an ein Herz → es wird langsamer, größer und heller", width/2, height - 50);
  text("'n' = neuer Regen  ·  's' = speichern", width/2, height - 25);
}

void keyPressed() {
  if (key == 'n' || key == 'N') generateNewRain();
  if (key == 's' || key == 'S') {
    save("herzen_regen_liebe_" + nf(frameCount, 5) + ".png");
    println("Gespeichert!");
  }
}

void generateNewRain() {
  hearts = new ArrayList<Heart>();
  particles = new ArrayList<Particle>();
  for (int i = 0; i < 15; i++) {
    hearts.add(new Heart(random(width), random(-300, -50)));
  }
}

class Heart {
  float x, y;
  float baseVy = random(1, 3);
  float vy;
  float size = random(25, 55);
  float hue = random(300, 360);
  float pulse = 0;
  
  Heart(float x, float y) {
    this.x = x;
    this.y = y;
    this.vy = baseVy;
  }
  
  void update() {
    // Maus-Interaktion – Reichweite reduziert, Mindestgeschwindigkeit
    float d = dist(mouseX, mouseY, x, y);
    float influence = map(d, 0, 150, 1, 0);  // Stärker nur ganz nah
    influence = constrain(influence, 0, 1);
    
    vy = lerp(baseVy, 0.3, 1 - influence);  // Nie unter 0.3 (sanftes Weiterfallen)
    
    pulse += 0.05;
    y += vy;
  }
  
  boolean isDead() {
    return y > height + size * 2;
  }
  
  void display() {
    float d = dist(mouseX, mouseY, x, y);
    float influence = map(d, 0, 150, 1, 0);
    influence = constrain(influence, 0, 1);
    float brightnessBoost = (1 - influence) * 30;
    
    float pulsingSize = size + sin(pulse) * 10;
    pulsingSize *= (1 + (1 - influence) * 1.8);  // Wird schön groß bei Nähe
    
    pushMatrix();
    translate(x, y);
    scale(pulsingSize / 40);
    
    noStroke();
    fill(hue, 80, 100 + brightnessBoost, 90);
    
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
    vy += 0.08;
    life -= 1.8;
  }
  
  boolean isDead() {
    return life <= 0;
  }
  
  void display() {
    noStroke();
    fill(hue, 80, 100, life);
    ellipse(x, y, life/8, life/8);
    
    if (life > 30) {
      fill(hue, 60, 100, life);
      textSize(life / 5);
      text(message, x, y);
    }
  }
}
