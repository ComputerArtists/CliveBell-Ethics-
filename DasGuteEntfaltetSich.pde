ArrayList<Wave> waves;
String[] messages = {
  "Ein Lächeln verändert den Tag",
  "Freundlichkeit kommt immer zurück",
  "Du bist genug, genau so wie du bist",
  "Kleine Gesten haben große Wirkung",
  "In dir ist so viel Licht",
  "Heute ist ein guter Tag zum Lieben",
  "Danke, dass es dich gibt",
  "Frieden beginnt mit einem Gedanken",
  "Du machst die Welt schöner",
  "Alles ist möglich mit offenem Herzen",
  "Atme tief – alles ist gut",
  "Deine Güte berührt andere Seelen"
};

void setup() {
  size(1200, 800);
  colorMode(HSB, 360, 100, 100, 100);
  background(210, 30, 15);  // Tiefes, ruhiges Nachtblau
  textAlign(CENTER, CENTER);
  textSize(18);
  
  waves = new ArrayList<Wave>();
}

void draw() {
  // Sanfter Fade für alte Spuren
  fill(210, 30, 15, 10);
  rect(0, 0, width, height);
  
  for (int i = waves.size() - 1; i >= 0; i--) {
    Wave w = waves.get(i);
    w.update();
    w.display();
    
    if (w.isDead()) {
      waves.remove(i);
    }
  }
  
  fill(0, 0, 100, 60);
  text("Klicke → Welle der Freundlichkeit | Bewege die Maus nah → sie wird stärker", width/2, height - 60);
  text("'n' = neu  ·  's' = speichern", width/2, height - 30);
}

void mousePressed() {
  waves.add(new Wave(mouseX, mouseY));
}

void keyPressed() {
  if (key == 'n' || key == 'N') {
    background(210, 30, 15);
    waves.clear();
  }
  if (key == 's' || key == 'S') {
    save("wellen_der_freundlichkeit_" + nf(frameCount, 5) + ".png");
    println("Gespeichert!");
  }
}

class Wave {
  float x, y;
  float radius = 0;
  float baseSpeed = random(2, 3.5);
  float speed;
  float maxRadius = 700;
  String message;
  float rotation = 0;
  
  Wave(float x, float y) {
    this.x = x;
    this.y = y;
    this.message = messages[int(random(messages.length))];
    this.speed = baseSpeed;
  }
  
  void update() {
    // Mausnähe berechnen (nur zum Zentrum der Welle)
    float d = dist(mouseX, mouseY, x, y);
    float proximity = map(d, 0, 200, 1, 0);
    proximity = constrain(proximity, 0, 1);
    
    // Je näher die Maus, desto langsamer + stärker
    speed = lerp(baseSpeed, 0.8, proximity);
    
    radius += speed;
    rotation += 0.0006 + proximity * 0.0007;  // Dreht sich etwas schneller bei Nähe
  }
  
  boolean isDead() {
    return radius > maxRadius;
  }
  
  void display() {
    // Farbverlauf: von Blau über Türkis zu warmem Rosa/Gold
    float hueNorm = map(radius, 0, maxRadius, 0, 1);
    float hue = lerp(random(360), random(360), hueNorm);  // Blau (200) → Rosa/Gold (20-60 Bereich)
    hue = (hue + 360) % 360;
    
    // Maus-Proximity für Boost
    float d = dist(mouseX, mouseY, x, y);
    float proximity = map(d, 0, 200, 1, 0);
    proximity = constrain(proximity, 0, 1);
    
    float alphaBase = map(radius, 0, maxRadius * 0.7, 100, 0);
    float alpha = alphaBase * (1 + proximity * 1.2);  // Stärker bei Nähe
    
    float thickness = map(radius, 0, maxRadius * 0.5, 14, 2);
    
    int rings = 4;
    for (int i = 1; i <= rings; i++) {
      float r = radius - i * 22;
      if (r <= 0) continue;
      
      noFill();
      strokeWeight(max(thickness / i, 0.8));
      stroke(hue, 70 + proximity * 30, 100, alpha / i);
      ellipse(x, y, r * 2, r * 2);
    }
    
    // Text mit hoher Lesbarkeit
    float wordRadius = radius * 0.65;
    if (wordRadius > 40) {
      float angle = rotation * 2.5;
      
      pushMatrix();
      translate(x + cos(angle) * wordRadius, y + sin(angle) * wordRadius);
      rotate(angle + HALF_PI);
      
      // Glow-Schichten
      for (int g = 3; g > 0; g--) {
        fill(0, 0, 100, alpha * 0.6 / g);
        textSize(map(radius, 60, maxRadius * 0.6, 18, 48) + g * 4);
        text(message, 2, 2);  // Leichter Versatz für Glow
      }
      
      // Kern-Text: Weiß mit schwarzem Outline
      strokeWeight(4 + proximity * 3);
      stroke(0, 0, 0, alpha * 1.2);
      fill(0, 0, 100, alpha * 1.8);
      textSize(map(radius, 60, maxRadius * 0.6, 18, 48));
      text(message, 0, 0);
      
      popMatrix();
    }
  }
}
