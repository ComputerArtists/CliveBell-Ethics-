ArrayList<LightSource> lights;

void setup() {
  size(1200, 800);
  background(30);  // Dunkles Grau – wie poliertes Metall im Schatten

  lights = new ArrayList<LightSource>();

  // Ein erstes Licht in der Mitte – wie ein erster Reflex
  lights.add(new LightSource(width/2, height/2));
}

void draw() {
  // Sehr subtiler Fade – nur für Tiefe, kein Verblassen des Lichts
  fill(30, 8);
  rect(0, 0, width, height);

  for (LightSource l : lights) {
    l.update();
    l.display();
  }

  // Hinweise – dezent, fast unsichtbar
  fill(255, 80);
  textAlign(CENTER, BOTTOM);
  textSize(18);
  text("Licht im Dunkel – im Stil von Heinz Mack", width/2, height - 80);

  textSize(14);
  text("Klicke → neues Licht entsteht | 'n' = neu | 's' = speichern", width/2, height - 50);
}

void mousePressed() {
  lights.add(new LightSource(mouseX, mouseY));
}

void keyPressed() {
  if (key == 'n' || key == 'N') {
    background(30);
    lights.clear();
    lights.add(new LightSource(width/2, height/2));
  }
  if (key == 's' || key == 'S') {
    save("licht_im_dunkel_mack_" + nf(frameCount, 5) + ".png");
    println("Gespeichert!");
  }
}

class LightSource {
  float x, y;
  float radius = 0;
  float maxRadius = random(400, 700);
  float speed = random(1.0, 2.5);

  LightSource(float x, float y) {
    this.x = x;
    this.y = y;
  }

  void update() {
    radius += speed;
  }

  void display() {
    if (radius <= 0 || radius > maxRadius) return;

    noFill();

    // Heinz Mack-Stil: präzise, vibrierende Strukturringe
    // Nur Grau- und Weißtöne, keine Farbe
    for (int i = 1; i <= 6; i++) {
      float r = radius + i * 30;
      if (r <= 0) continue;

      float thickness = map(i, 1, 6, 6, 1);
      float alpha = map(i, 1, 6, 200, 40);
      float brightness = map(sin(frameCount * 0.03 + i * 0.5), -1, 1, 180, 255);

      strokeWeight(thickness);
      stroke(0, 0, brightness, alpha);
      ellipse(x, y, r * 2, r * 2);
    }

    // Innere Struktur – feine, vibrierende Linien
    pushMatrix();
    translate(x, y);
    for (int i = 0; i < 24; i++) {
      rotate(TWO_PI / 24);
      float len = radius * 0.6 + sin(frameCount * 0.04 + i) * 30;
      strokeWeight(1.5);
      stroke(0, 0, 255, 180);
      line(0, 0, len, 0);
    }
    popMatrix();

    // Zentraler Glanzpunkt – wie poliertes Aluminium
    fill(0, 0, 255, 220 + sin(frameCount * 0.1) * 35);
    noStroke();
    ellipse(x, y, 30, 30);
  }
}
