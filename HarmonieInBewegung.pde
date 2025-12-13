float rotation = 0;
int symmetry = 12;
float time = 0;

void setup() {
  size(1200, 800);
  colorMode(HSB, 360, 100, 100, 100);
  setHarmonicBackground();  // Bunten Hintergrund einmal setzen
  noStroke();
}

void draw() {
  // KEIN FADE MEHR – Hintergrund bleibt bunt!
  // (Kommentiert oder entfernt)
  // fill(220, 15, 8, 8);
  // rect(0, 0, width, height);
  
  translate(width/2, height/2);
  rotate(rotation);
  
  time += 0.003;
  rotation += 0.001;
  
  for (int i = 0; i < symmetry; i++) {
    rotate(TWO_PI / symmetry);
    
    pushMatrix();
    
    float corePulse = sin(time * 1.5 + i * 0.2) * 0.15 + 1;
    float coreSize = 100 * corePulse;
    fill((time * 15 + i * 8) % 360, 40, 95, 200);
    ellipse(0, 0, coreSize, coreSize);
    
    for (int j = 0; j < 6; j++) {
      float angle = j * TWO_PI / 6;
      float dist = 160 + sin(time * 0.8 + j) * 40;
      float size = 50 + sin(time * 1.2 + j) * 20;
      
      fill((time * 20 + j * 25 + 120) % 360, 50, 90, 180);
      pushMatrix();
      rotate(angle);
      translate(dist, 0);
      rotate(sin(time * 0.3 + j) * 0.3);
      ellipse(0, 0, size * 0.5, size * 1.6);
      popMatrix();
    }
    
    for (int k = 0; k < 8; k++) {
      float angle = k * TWO_PI / 8;
      float dist = 280 + sin(time * 0.6 + k * 0.5) * 60;
      float size = 40 + cos(time * 0.9 + k) * 15;
      
      fill((time * 18 + k * 30 + 240) % 360, 60, 85, 140);
      pushMatrix();
      rotate(angle);
      translate(dist, 0);
      rotate(sin(time * 0.4 + k) * 0.2);
      ellipse(0, 0, size * 0.7, size * 1.4);
      popMatrix();
    }
    
    popMatrix();
  }
  
  fill(60, 30, 100, 80 + sin(time * 2) * 40);
  ellipse(0, 0, 60, 60);
  
  // Hinweise
  pushMatrix();
  resetMatrix();
  fill(0, 0, 100, 70);
  textAlign(CENTER, BOTTOM);
  textSize(18);
  text("Generatives Mandala der Harmonie", width/2, height - 80);
  
  textSize(16);
  text("Jeder Start ('n') erzeugt ein neues Mandala mit neuem Hintergrund", width/2, height - 55);
  text("'n' = neu  ·  's' = speichern", width/2, height - 35);
  popMatrix();
}

void setHarmonicBackground() {
  float hue = random(0, 360);
  float saturation = random(20, 50);
  float brightness = random(90, 100);
  
  background(hue, saturation, brightness);
}

void keyPressed() {
  if (key == 'n' || key == 'N') {
    setHarmonicBackground();  // Neuer bunter Hintergrund
    symmetry = int(random(36));
    time = 0;
    rotation = random(TWO_PI);
  }
  if (key == 's' || key == 'S') {
    save("mandala_der_harmonie_" + nf(frameCount, 5) + ".png");
    println("Gespeichert!");
  }
}
