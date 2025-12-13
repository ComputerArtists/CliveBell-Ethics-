ArrayList<GratitudeParticle> particles;

String[] words = {
  "Danke", "Freude", "Liebe", "Licht", "Frieden", "Geschenk", 
  "Lächeln", "Wärme", "Moment", "Atem", "Hoffnung", "Vertrauen",
  "Harmonie", "Schönheit", "Stille", "Leben", "Glück", "Segen"
};

void setup() {
  size(1200, 800);
  colorMode(HSB, 360, 100, 100, 100);
  background(220, 20, 10);  // Tiefes, ruhiges Nachtblau

  particles = new ArrayList<GratitudeParticle>();
}

void draw() {
  // Sehr sanfter Fade für alte Spuren
  fill(220, 20, 10, 15);
  rect(0, 0, width, height);

  // Alle Partikel updaten und zeichnen
  for (int i = particles.size() - 1; i >= 0; i--) {
    GratitudeParticle p = particles.get(i);
    p.update();
    p.display();
    
    if (p.isDead()) {
      particles.remove(i);
    }
  }

  // Hinweise
  fill(0, 0, 100, 70);
  textAlign(CENTER, BOTTOM);
  textSize(18);
  text("Particle-System der Dankbarkeit", width/2, height - 80);

  textSize(16);
  text("Klicke irgendwo → eine Welle der Dankbarkeit entsteht", width/2, height - 55);
  text("'n' = alles neu  ·  's' = speichern", width/2, height - 35);
}

void mousePressed() {
  // Neue Dankbarkeits-Explosion
  for (int i = 0; i < 40; i++) {
    particles.add(new GratitudeParticle(mouseX, mouseY));
  }
}

void keyPressed() {
  if (key == 'n' || key == 'N') {
    background(220, 20, 10);
    particles.clear();
  }
  if (key == 's' || key == 'S') {
    save("dankbarkeit_partikel_" + nf(frameCount, 5) + ".png");
    println("Gespeichert!");
  }
}

class GratitudeParticle {
  float x, y;
  float vx, vy;
  float life = 255;
  float hue;
  String word;

  GratitudeParticle(float startX, float startY) {
    x = startX + random(-20, 20);
    y = startY + random(-20, 20);
    
    float angle = random(TWO_PI);
    float speed = random(0.5, 2.5);
    vx = cos(angle) * speed;
    vy = sin(angle) * speed - 2;  // Leicht nach oben
    
    hue = random(30, 90);  // Warme Gold- bis Rosatöne
    word = words[int(random(words.length))];
  }

  void update() {
    x += vx;
    y += vy;
    vy += 0.05;  // Sanfte Schwerkraft (langsames Fallen nach oben-Start)
    
    life -= 1.2;  // Langsam verblassen
  }

  boolean isDead() {
    return life <= 0;
  }

   void display() {
    // Leuchtender Kern
    noStroke();
    fill(hue, 80, 100, life);
    ellipse(x, y, life / 8, life / 8);
    
    // Sanfter Glow
    for (int g = 3; g > 0; g--) {
      fill(hue, 60, 100, life / g / 4);
      ellipse(x, y, life / 5 * g, life / 5 * g);
    }
    
    // Wort – jetzt viel besser lesbar
    if (life > 60) {  // Früher sichtbar
      // Schwarzer Outline für Kontrast
      fill(0, 0, 0, life * 0.8);  // Dunkler Rand
      textAlign(CENTER, CENTER);
      textSize(life / 8 + 8);  // Größer + fester Mindestwert
      text(word, x + 1, y + 1);
      text(word, x - 1, y + 1);
      text(word, x + 1, y - 1);
      text(word, x - 1, y - 1);
      
      // Heller Text oben drauf
      fill(hue, 40, 100, life);
      textSize(life / 8 + 8);
      text(word, x, y);
    }
  }}
