// WurzelnDesLichts – WAHRHAFT FINALE VERSION
// Volle Verzweigung, stabile Blüten, nah am Ast, Skalierung

String axiom = "F";
String ruleF = "FF+[+F-F-F]-[-F+F+F]";

String current;

int generations = 5;
float baseAngle = radians(25);
float baseLength = 140;

long renderStartTime;
float renderTime = 0;

float angleVar;
float lengthVar;

float treeScale = 1.0;

ArrayList<TurtleCommand> treeCommands = new ArrayList<TurtleCommand>();

class TurtleCommand {
  char type;      // 'F', '+', '-', '[', ']', 'B'
  float length;   // Für 'F'
  float rot, dist, offsetY, size;
  int flowerType; // 0 = Blüte, 1 = Frucht
  
  TurtleCommand(char t, float l) {
    type = t;
    length = l;
  }
  
  TurtleCommand(char t) {
    type = t;
  }
  
  TurtleCommand(float r, float d, float oy, float s, int ft) {
    type = 'B';
    rot = r;
    dist = d;
    offsetY = oy;
    size = s;
    flowerType = ft;
  }
}

void setup() {
  size(1200, 800);
  colorMode(HSB, 360, 100, 100, 100);
  generateTree();
}

void draw() {
  background(210, 30, 10);
  
  drawStoredTree();
  
  fill(0, 0, 100, 80);
  textAlign(CENTER, BOTTOM);
  textSize(18);
  text("WurzelnDesLichts – Baum des Lebens", width/2, height - 80);
  
  textSize(16);
  text("Render-Zeit: " + nfp(renderTime / 1000, 1, 2) + " s  |  Generationen: " + generations, width/2, height - 55);
  text("'n' = neuer Baum  ·  ↑↓ = Generationen  ·  + / - = Skalierung (" + nf(treeScale*100, 1, 0) + "%)  ·  's' = speichern", width/2, height - 30);
}

void generateTree() {
  renderTime = 0;
  renderStartTime = millis();
  
  angleVar = random(0.8, 1.35);
  lengthVar = random(0.8, 0.999);
  
  current = axiom;
  
  for (int g = 0; g < generations; g++) {
    StringBuilder next = new StringBuilder();
    for (char c : current.toCharArray()) {
      if (c == 'F') next.append(ruleF);
      else next.append(c);
    }
    current = next.toString();
  }
  
  treeCommands.clear();
  
  float currentLength = baseLength;
  
  for (int i = 0; i < current.length(); i++) {
    char c = current.charAt(i);
    
    if (c == 'F') {
      treeCommands.add(new TurtleCommand('F', currentLength));
      
      boolean isTrueEnd = (i + 1 >= current.length()) || (current.charAt(i + 1) != 'F');
      if (isTrueEnd && currentLength > 3) {
        int count = 1 + int(random(0, 6));
        for (int j = 0; j < count; j++) {
          float rot = random(-PI/4, PI/4);
          float dist = random(0, currentLength * 0.3);
          float offsetY = random(-currentLength * 0.2, currentLength * 0.2);
          float size = random(12, 22);
          int type = random(1) < 0.4 ? 1 : 0;
          treeCommands.add(new TurtleCommand(rot, dist, offsetY, size, type));
        }
      }
      
      currentLength *= lengthVar;
    } else {
      treeCommands.add(new TurtleCommand(c));
    }
  }
  
  renderTime = millis() - renderStartTime;
  println("Neuer Baum generiert – Render-Zeit: " + renderTime + " ms");
}

void drawStoredTree() {
  pushMatrix();
  
  translate(width/2, height);
  scale(treeScale);
  translate(-width/2, -height);
  
  translate(width/2, height - 80);
  rotate(radians(-90));
  
  float posX = 0;
  float posY = 0;
  float dir = 0;
  
  float currentAngle = baseAngle * angleVar;
  
  ArrayList<Float> savedPosX = new ArrayList<Float>();
  ArrayList<Float> savedPosY = new ArrayList<Float>();
  ArrayList<Float> savedDir = new ArrayList<Float>();
  
  for (TurtleCommand cmd : treeCommands) {
    if (cmd.type == 'F') {
      if (cmd.length > 0.4) {
        float weight = map(cmd.length, baseLength, 5, 10, 1);
        strokeWeight(max(weight, 1.0));
        
        float h = map(cmd.length, baseLength, 5, 90, 140);
        float s = map(cmd.length, baseLength, 5, 70, 90);
        float b = map(cmd.length, baseLength, 5, 50, 90);
        stroke(h, s, b);
        
        float nx = posX + cos(dir) * cmd.length;
        float ny = posY + sin(dir) * cmd.length;
        line(posX, posY, nx, ny);
        posX = nx;
        posY = ny;
      } else {
        posX += cos(dir) * cmd.length;
        posY += sin(dir) * cmd.length;
      }
    }
    else if (cmd.type == 'B') {
      pushMatrix();
      translate(posX, posY);
      rotate(cmd.rot);
      translate(cmd.dist, cmd.offsetY);
      
      float size = cmd.size;
      
      if (cmd.flowerType == 1) {
        // Frucht
        float hue = 45;
        for (int g = 2; g > 0; g--) {
          fill(hue, 80, 100, 55 / g);
          noStroke();
          ellipse(0, 0, size * 1.9 * g, size * 1.9 * g);
        }
        fill(hue, 90, 90);
        ellipse(0, 0, size * 1.3, size * 1.3);
        fill(0, 0, 100, 220);
        ellipse(-size * 0.25, -size * 0.25, size * 0.45, size * 0.45);
      } else {
        // Blüte
        float petalHue = 320;
        int petals = 7;
        fill(petalHue, 45, 100, 35);
        noStroke();
        ellipse(0, 0, size * 5.5, size * 5.5);
        
        for (int p = 0; p < petals; p++) {
          pushMatrix();
          rotate(TWO_PI / petals * p);
          fill(petalHue, 70, 100, 210);
          ellipse(0, -size * 0.85, size * 0.85, size * 2.0);
          popMatrix();
        }
        fill(55, 90, 100);
        ellipse(0, 0, size * 0.9, size * 0.9);
      }
      popMatrix();
    }
    else if (cmd.type == '+') dir += currentAngle;
    else if (cmd.type == '-') dir -= currentAngle;
    else if (cmd.type == '[') {
      savedPosX.add(posX);
      savedPosY.add(posY);
      savedDir.add(dir);
    }
    else if (cmd.type == ']') {
      posX = savedPosX.remove(savedPosX.size() - 1);
      posY = savedPosY.remove(savedPosY.size() - 1);
      dir = savedDir.remove(savedDir.size() - 1);
    }
  }
  
  popMatrix();
}

void keyPressed() {
  if (key == 'n' || key == 'N') {
    generateTree();
  }
  if (key == 's' || key == 'S') {
    save("wurzeln_des_lichts_" + nf(frameCount, 5) + ".png");
    println("Gespeichert!");
  }
  if (keyCode == UP && generations < 8) {
    generations++;
    generateTree();
  }
  if (keyCode == DOWN && generations > 3) {
    generations--;
    generateTree();
  }
  if (key == '+' || key == '=') {
    treeScale = constrain(treeScale + 0.1, 0.2, 2.5);
  }
  if (key == '-' || key == '_') {
    treeScale = constrain(treeScale - 0.1, 0.2, 2.5);
  }
}
