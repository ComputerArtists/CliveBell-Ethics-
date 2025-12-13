ArrayList<Idea> ideas;
float nextIdeaTime = 0;
float ideaInterval = 8000;

String[] kindnessActs = {
  "Lächeln jemandem zu, den du heute triffst",
  "Jemandem ein ehrliches Kompliment machen",
  "Einem Fremden die Tür aufhalten",
  "Eine nette Nachricht an einen Freund schicken",
  "Jemandem anonym eine kleine Freude bereiten",
  "Ein Dankeschön sagen, wo es keiner erwartet",
  "Jemandem zuhören, wirklich zuhören",
  "Eine kleine Hilfe anbieten, ohne zu fragen",
  "Etwas Positives in die Welt setzen",
  "Jemandem verzeihen, der es vielleicht nicht verdient",
  "Die Welt ein kleines bisschen besser machen",
  "Heute besonders freundlich sein"
};

// Passende Symbole (als Index – wir zeichnen sie selbst)
int[] symbols = {
  0, // Lächeln → Herz
  1, // Kompliment → Stern
  2, // Tür aufhalten → Tür-Symbol
  3, // Nachricht → Brief
  4, // Anonyme Freude → Geschenk
  5, // Dankeschön → Blumen
  6, // Zuhören → Ohr
  7, // Hilfe → Hand
  8, // Positives → Sonne
  9, // Verzeihen → Taube
  10, // Welt besser → Erde
  11  // Freundlich → Umarmung
};

void setup() {
  size(1200, 800);
  colorMode(HSB, 360, 100, 100, 100);
  background(220, 20, 10);
  textAlign(CENTER, CENTER);

  ideas = new ArrayList<Idea>();
  
  spawnIdea(width/2, height/2);
  nextIdeaTime = millis() + ideaInterval;
}

void draw() {
  fill(220, 20, 10, 15);
  rect(0, 0, width, height);

  if (millis() > nextIdeaTime) {
    spawnIdea(random(width * 0.2, width * 0.8), random(height * 0.3, height * 0.7));
    nextIdeaTime = millis() + ideaInterval;
  }

  for (int i = ideas.size() - 1; i >= 0; i--) {
    Idea idea = ideas.get(i);
    idea.update();
    idea.display();
    
    if (idea.isDead()) {
      ideas.remove(i);
    }
  }

  fill(0, 0, 100, 70);
  textAlign(CENTER, BOTTOM);
  textSize(18);
  text("Random Acts of Kindness Generator", width/2, height - 80);

  textSize(16);
  text("Klicke für eine neue Idee | Automatisch alle paar Sekunden", width/2, height - 55);
  text("'n' = alles neu  ·  's' = speichern", width/2, height - 35);
}

void mousePressed() {
  spawnIdea(mouseX, mouseY);
}

void spawnIdea(float x, float y) {
  int index = int(random(kindnessActs.length));
  ideas.add(new Idea(x, y, kindnessActs[index], symbols[index]));
}

void keyPressed() {
  if (key == 'n' || key == 'N') {
    background(220, 20, 10);
    ideas.clear();
    nextIdeaTime = millis() + ideaInterval;
  }
  if (key == 's' || key == 'S') {
    save("random_acts_of_kindness_" + nf(frameCount, 5) + ".png");
    println("Gespeichert!");
  }
}

class Idea {
  float x, y;
  String text;
  int symbolType;
  float life = 255;
  float hue = random(30, 90);
  ArrayList<Particle> particles = new ArrayList<Particle>();

  Idea(float x, float y, String t, int s) {
    this.x = x;
    this.y = y;
    text = t;
    symbolType = s;

    for (int i = 0; i < 40; i++) {
      particles.add(new Particle(x, y));
    }
  }

  void update() {
    life -= 0.8;

    for (int i = particles.size() - 1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.update();
      if (p.isDead()) particles.remove(i);
    }
  }

  boolean isDead() {
    return life <= 0;
  }

  void display() {
    float pulse = sin(frameCount * 0.05) * 0.2 + 1;
    textSize(36 * pulse);

    // Symbole links und rechts
    pushMatrix();
    translate(x, y);
    
    drawSymbol(symbolType, -200, 0, life);
    drawSymbol(symbolType, 200, 0, life);
    
    popMatrix();

    // Text mit Glow
    fill(0, life * 0.8);
    for (int dx = -3; dx <= 3; dx += 3) {
      for (int dy = -3; dy <= 3; dy += 3) {
        if (dx != 0 || dy != 0) text(text, x + dx, y + dy);
      }
    }

    fill(hue, 70, 100, life);
    text(text, x, y);

    // Partikel
    for (Particle p : particles) {
      p.display();
    }
  }

  void drawSymbol(int type, float offsetX, float offsetY, float alpha) {
    pushMatrix();
    translate(offsetX, offsetY);
    scale(sin(frameCount * 0.04 + offsetX) * 0.1 + 1);  // Leichtes Pulsieren

    noStroke();
    fill(hue, 80, 100, alpha * 0.8);

    switch (type) {
      case 0: // Herz
        beginShape();
        vertex(0, 15);
        bezierVertex(30, -10, 50, 10, 0, 40);
        bezierVertex(-50, 10, -30, -10, 0, 15);
        endShape(CLOSE);
        break;
      case 1: // Stern
        for (int s = 0; s < 5; s++) {
          rotate(TWO_PI / 5);
          line(0, 0, 0, 40);
        }
        break;
      case 2: // Tür
        rect(-20, -40, 40, 80);
        fill(hue, 60, 80, alpha);
        ellipse(15, 0, 10, 10); // Türklinke
        break;
      case 3: // Brief
        rect(-30, -20, 60, 40);
        line(-30, -20, 0, 10);
        line(30, -20, 0, 10);
        break;
      case 4: // Geschenk
        rect(-25, -30, 50, 60);
        rect(-35, -10, 70, 20);
        break;
      case 5: // Blumen
        for (int f = 0; f < 6; f++) {
          pushMatrix();
          rotate(TWO_PI / 6 * f);
          fill(hue + 30, 80, 100, alpha);
          ellipse(0, -30, 20, 40);
          popMatrix();
        }
        fill(60, 80, 100, alpha);
        ellipse(0, 0, 20, 20);
        break;
      case 6: // Ohr
        ellipse(0, 0, 50, 70);
        ellipse(0, 0, 20, 30);
        break;
      case 7: // Hand
        ellipse(0, 0, 60, 80);
        for (int f = 0; f < 4; f++) {
          rect(-25 + f * 12, -40, 10, 40);
        }
        break;
      case 8: // Sonne
        for (int r = 0; r < 12; r++) {
          rotate(TWO_PI / 12);
          line(0, 40, 0, 60);
        }
        fill(hue, 80, 100, alpha);
        ellipse(0, 0, 60, 60);
        break;
      case 9: // Taube
        ellipse(0, 0, 60, 40);
        ellipse(-20, -10, 30, 50);
        ellipse(20, -10, 30, 50);
        break;
      case 10: // Erde
        fill(hue, 70, 80, alpha);
        ellipse(0, 0, 70, 70);
        fill(200, 60, 80, alpha);
        arc(0, 0, 70, 70, -PI/3, PI/3);
        break;
      case 11: // Umarmung
        ellipse(-30, 0, 50, 80);
        ellipse(30, 0, 50, 80);
        break;
    }
    
    popMatrix();
  }
}

class Particle {
  float x, y;
  float vx, vy;
  float life = 255;
  float hue;

  Particle(float x, float y) {
    this.x = x + random(-30, 30);
    this.y = y + random(-30, 30);
    float angle = random(TWO_PI);
    float speed = random(0.5, 2);
    vx = cos(angle) * speed;
    vy = sin(angle) * speed - 1;
    hue = random(30, 90);
  }

  void update() {
    x += vx;
    y += vy;
    vy += 0.05;
    life -= 3;
  }

  boolean isDead() {
    return life <= 0;
  }

  void display() {
    noStroke();
    fill(hue, 80, 100, life);
    ellipse(x, y, life / 15, life / 15);
  }
}
