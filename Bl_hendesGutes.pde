ArrayList<Flower> flowers;
int saveCount = 1;  // Für fortlaufende Dateinamen

void setup() {
  size(1200, 800);            // Oder fullScreen() für Vollbild
  generateNewMeadow();        // Erste Wiese erzeugen
}

void draw() {
  for (Flower f : flowers) {
    f.update();
    f.display();
  }
  
  // Hinweistext unten einblenden (sanft)
  fill(0, 100);
  textAlign(LEFT);
  textSize(14);
  text("Bewege die Maus näher → Blumen blühen auf  |  'n' = neue Wiese  |  's' = speichern", 20, height - 20);
}

void keyPressed() {
  if (key == 'n' || key == 'N') {
    generateNewMeadow();
  }
  if (key == 's' || key == 'S') {
    String filename = "bluhende_wiese_" + nf(saveCount, 3) + ".png";
    save(filename);
    println("Gespeichert als: " + filename);
    saveCount++;
  }
}

void generateNewMeadow() {
  background(135, 206, 235);    // Himmelblau
  
  // Grüne Wiese
  noStroke();
  fill(34, 139, 34);
  rect(0, height * 0.7, width, height * 0.3);
  
  flowers = new ArrayList<Flower>();
  
  // 30–50 Blumen mit mehr Variation
  int numFlowers = int(random(30, 50));
  for (int i = 0; i < numFlowers; i++) {
    float x = random(width);
    float y = height * 0.7 + random(-60, 60);
    flowers.add(new Flower(x, y));
  }
}

class Flower {
  float x, y;
  float stemHeight = 0;
  float maxStemHeight;
  float bloomSize = 0;
  float maxBloomSize;
  float growthSpeed;
  color blossomColor;
  int petalCount;          // Anzahl Blütenblätter: 5, 8, 12 oder viele (Gänseblümchen)
  String type;             // "buddha", "lotus", "daisy", "star"
  float sway = 0;
  boolean hasLeaves = false;
  
  Flower(float x, float y) {
    this.x = x;
    this.y = y;
    this.maxStemHeight = random(80, 200);
    this.maxBloomSize = random(40, 100);
    this.growthSpeed = random(0.4, 1.3);
    
    // Zufälliger Blütentyp
    float rnd = random(1);
    if (rnd < 0.3) {
      type = "buddha";     // 5 Blätter – wie Fußabdruck
      petalCount = 5;
    } else if (rnd < 0.55) {
      type = "lotus";      // Mehrschichtig
      petalCount = int(random(8, 13));
    } else if (rnd < 0.8) {
      type = "daisy";      // Viele schmale Blätter
      petalCount = int(random(15, 25));
    } else {
      type = "star";       // Sternförmig
      petalCount = int(random(6, 10));
    }
    
    // Farbschema variieren
    float colorRnd = random(1);
    if (colorRnd < 0.4) {
      // Pastell
      blossomColor = color(random(180, 255), random(180, 230), random(200, 255));
    } else if (colorRnd < 0.7) {
      // Warm-leuchtend
      blossomColor = color(random(200, 255), random(100, 200), random(100, 220));
    } else {
      // Sanfte Regenbogen-Nuance
      blossomColor = color(random(150, 255), random(100, 200), random(180, 255));
    }
    
    hasLeaves = random(1) < 0.6;  // 60% Chance auf Blätter am Stiel
  }
  
  void update() {
    float d = dist(mouseX, mouseY, x, y);
    float proximity = map(d, 0, 350, 1, 0);
    proximity = constrain(proximity, 0, 1);
    float speed = growthSpeed * proximity;
    
    if (stemHeight < maxStemHeight) {
      stemHeight += speed;
    } else {
      bloomSize += speed * 1.2;
      if (bloomSize > maxBloomSize) bloomSize = maxBloomSize;
    }
    
    sway = sin(frameCount * 0.02 + x) * 5;
  }
  
  void display() {
    pushMatrix();
    translate(x + sway, y);
    
    // Stiel (leicht gebogen für mehr Leben)
    stroke(34, 139, 34);
    strokeWeight(4);
    float curve = sin(frameCount * 0.01 + x) * 10;
    bezier(0, 0, curve*0.3, -stemHeight*0.3, curve*0.7, -stemHeight*0.7, 0, -stemHeight);
    
    // Blätter am Stiel (optional)
    if (hasLeaves && stemHeight > 40) {
      drawLeaves();
    }
    
    // Blüte
    if (stemHeight >= maxStemHeight - 5) {
      translate(0, -stemHeight);
      drawBloom();
    }
    
    popMatrix();
  }
  
  void drawLeaves() {
    fill(20, 100, 20);
    noStroke();
    for (int i = 0; i < 3; i++) {
      if (random(1) < 0.7) {  // Nicht immer alle Blätter
        pushMatrix();
        translate(0, -stemHeight * (0.3 + i*0.25));
        rotate(random(-0.5, 0.5));
        ellipse(15, 0, 30, 12);
        ellipse(-15, 0, 30, 12);
        popMatrix();
      }
    }
  }
  
  void drawBloom() {
    noStroke();
    
    if (type.equals("lotus")) {
      // Mehrschichtiger Lotus-Effekt
      for (int layer = 3; layer > 0; layer--) {
        fill(red(blossomColor), green(blossomColor), blue(blossomColor), 150 - layer*30);
        for (int i = 0; i < petalCount; i++) {
          pushMatrix();
          rotate(TWO_PI / petalCount * i + layer * 0.1);
          ellipse(0, -bloomSize / 2.5 * layer, bloomSize / 1.8, bloomSize * 1.2);
          popMatrix();
        }
      }
    } else {
      // Standard-Blütenblätter
      fill(blossomColor);
      float petalWidth = type.equals("daisy") ? bloomSize / 3 : bloomSize / 1.8;
      float petalLength = type.equals("daisy") ? bloomSize * 1.2 : bloomSize;
      for (int i = 0; i < petalCount; i++) {
        pushMatrix();
        rotate(TWO_PI / petalCount * i);
        if (type.equals("star")) {
          scale(1, 0.6);  // Spitze Sternform
        }
        ellipse(0, -petalLength / 3, petalWidth, petalLength);
        popMatrix();
      }
    }
    
    // Blütenmitte
    fill(255, 220, 50, 200);
    ellipse(0, 0, bloomSize / 2.2, bloomSize / 2.2);
    
    // Extra Glanz für Erleuchtungs-Feeling
    fill(255, 255, 255, 100);
    ellipse(-bloomSize/8, -bloomSize/8, bloomSize/6, bloomSize/6);
  }
}
