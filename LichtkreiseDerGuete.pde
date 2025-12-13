ArrayList<LightCircle> circles;
boolean glitterEnabled = true;

void setup() {
  size(1200, 800);
  colorMode(HSB, 360, 100, 100, 100);
  background(220, 20, 10);

  circles = new ArrayList<LightCircle>();

  circles.add(new LightCircle(width/2, height/2));
}

void draw() {
  fill(220, 20, 10, 12);
  rect(0, 0, width, height);

  for (LightCircle c : circles) {
    c.update();
    c.display();
  }

  fill(0, 0, 100, 70);
  textAlign(CENTER, BOTTOM);
  textSize(18);
  text("Lichtkreise der Güte", width/2, height - 80);

  textSize(16);
  text("Klicke → neuer Kreis | Glitzer: " + (glitterEnabled ? "AN" : "AUS") + " ('g')", width/2, height - 55);
  text("'n' = neu  ·  's' = speichern", width/2, height - 35);
}

void mousePressed() {
  circles.add(new LightCircle(mouseX, mouseY));
}

void keyPressed() {
  if (key == 'n' || key == 'N') {
    background(220, 20, 10);
    circles.clear();
    circles.add(new LightCircle(width/2, height/2));
  }
  if (key == 's' || key == 'S') {
    save("lichtkreise_der_guete_" + nf(frameCount, 5) + ".png");
    println("Gespeichert!");
  }
  if (key == 'g' || key == 'G') {
    glitterEnabled = !glitterEnabled;
  }
}

class LightCircle {
  float x, y;
  float baseRadius = 0;
  float radius;
  float maxRadius = 600;
  float speed = random(1.2, 2.2);
  float hue = random(30, 80);
  float hueSpeed = random(0.003, 0.008);
  boolean hueUp = true;

  String message = "";
  float messageAlpha = 0;

  ArrayList<GlitterParticle> glitter = new ArrayList<GlitterParticle>();

  LightCircle(float x, float y) {
    this.x = x;
    this.y = y;
    radius = 0;

    // Positive Worte
    String[] words = {"Güte", "Licht", "Harmonie", "Frieden", "Liebe", "Danke", "Hoffnung", "Wärme", "Vertrauen", "Lächeln"};
    message = words[int(random(words.length))];
    messageAlpha = 0;

    if (glitterEnabled) {
      for (int i = 0; i < 30; i++) {
        glitter.add(new GlitterParticle(x, y));
      }
    }
  }

  void update() {
    baseRadius += speed;

    // Pulsieren
    radius = baseRadius + sin(frameCount * 0.05 + x + y) * 20;

    // Sanfter Farbverlauf
    if (hueUp) {
      hue += hueSpeed;
      if (hue > 80) hueUp = false;
    } else {
      hue -= hueSpeed;
      if (hue < 30) hueUp = true;
    }

    // Wort erscheinen und verblassen
    if (baseRadius < 150) {
      messageAlpha = map(baseRadius, 0, 150, 0, 255);
    } else {
      messageAlpha = map(baseRadius, 150, maxRadius * 0.5, 255, 0);
    }

    // Glitzer updaten
    for (int i = glitter.size() - 1; i >= 0; i--) {
      GlitterParticle p = glitter.get(i);
      p.update();
      if (p.isDead()) glitter.remove(i);
    }
  }

  void display() {
    if (radius <= 0 || radius > maxRadius) return;

    // Mausnähe – wärmer und heller
    float d = dist(mouseX, mouseY, x, y);
    float proximity = map(d, 0, 200, 1, 0);
    proximity = constrain(proximity, 0, 1);
    float extraBrightness = proximity * 30;
    float hueShift = proximity * 30;  // Zu Gold bei Nähe

    float currentHue = (hue + hueShift) % 360;

    float alpha = map(radius, 0, maxRadius * 0.6, 80, 0);
    float thickness = map(radius, 0, maxRadius * 0.4, 20, 4);

    noFill();

    // Ringe mit goldener Überlagerung bei Nähe
    for (int i = 1; i <= 3; i++) {
      float r = radius + i * 20;
      if (r <= 0) continue;

      float a = alpha / i;
      float w = max(thickness / i, 0.5);

      strokeWeight(w);
      stroke(currentHue, 80 - proximity * 30, 100 + extraBrightness, a);
      ellipse(x, y, r * 2, r * 2);
    }

    // Innerer Kern – goldener Glanz bei Nähe
    float coreRadius = radius * 1.8;
    if (coreRadius > 0) {
      strokeWeight(max(thickness * 0.8, 0.5));
      stroke(currentHue - 20, 70, 100 + extraBrightness * 1.5, alpha * 1.5);
      ellipse(x, y, coreRadius * 2, coreRadius * 2);
    }

    // Positive Wort in der Mitte
    if (messageAlpha > 0) {
      fill(currentHue, 60, 100, messageAlpha);
      textAlign(CENTER, CENTER);
      textSize(map(radius, 0, 200, 14, 40));
      text(message, x, y);
    }

    // Glitzer
    for (GlitterParticle p : glitter) {
      p.display();
    }
  }
}

class GlitterParticle {
  float x, y;
  float vx, vy;
  float life = 100;
  float hue;

  GlitterParticle(float x, float y) {
    this.x = x + random(-20, 20);
    this.y = y + random(-20, 20);
    float angle = random(TWO_PI);
    float speed = random(1, 4);
    vx = cos(angle) * speed;
    vy = sin(angle) * speed - 2;
    hue = random(30, 80);
  }

  void update() {
    x += vx;
    y += vy;
    vy += 0.08;
    life -= 2;
  }

  boolean isDead() {
    return life <= 0;
  }

  void display() {
    noStroke();
    fill(hue, 80, 100, life);
    ellipse(x, y, life / 8, life / 8);
  }
}
