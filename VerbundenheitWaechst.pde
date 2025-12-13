ArrayList<Node> nodes;
ArrayList<Connection> connections;

float maxDistance = 200;  // Maximale Entfernung für Verbindung

void setup() {
  size(1200, 800);
  colorMode(HSB, 360, 100, 100, 100);
  background(220, 20, 10);  // Tiefes, ruhiges Blau

  nodes = new ArrayList<Node>();
  connections = new ArrayList<Connection>();

  // Start mit ein paar Knoten in der Mitte
  for (int i = 0; i < 5; i++) {
    nodes.add(new Node(width/2 + random(-100, 100), height/2 + random(-100, 100)));
  }
}

void draw() {
  // Sanfter Fade
  fill(220, 20, 10, 15);
  rect(0, 0, width, height);

  // Verbindungen updaten und zeichnen
  connections.clear();  // Neue berechnen
  for (int i = 0; i < nodes.size(); i++) {
    Node n1 = nodes.get(i);
    for (int j = i + 1; j < nodes.size(); j++) {
      Node n2 = nodes.get(j);
      float d = dist(n1.x, n1.y, n2.x, n2.y);
      if (d < maxDistance) {
        connections.add(new Connection(n1, n2, d));
      }
    }
  }

  // Verbindungen zeichnen
  for (Connection c : connections) {
    c.display();
  }

  // Knoten updaten und zeichnen
  for (Node n : nodes) {
    n.update();
    n.display();
  }

  // Hinweise
  fill(0, 0, 100, 70);
  textAlign(CENTER, BOTTOM);
  textSize(18);
  text("Wachsendes Netzwerk der Verbundenheit", width/2, height - 80);

  textSize(16);
  text("Klicke irgendwo → ein neuer Knoten entsteht", width/2, height - 55);
  text("Je mehr Verbindungen, desto heller leuchtet das Netzwerk", width/2, height - 35);
  text("'n' = alles neu  ·  's' = speichern", width/2, height - 15);
}

void mousePressed() {
  nodes.add(new Node(mouseX, mouseY));
}

void keyPressed() {
  if (key == 'n' || key == 'N') {
    background(220, 20, 10);
    nodes.clear();
    connections.clear();
    for (int i = 0; i < 5; i++) {
      nodes.add(new Node(width/2 + random(-100, 100), height/2 + random(-100, 100)));
    }
  }
  if (key == 's' || key == 'S') {
    save("netzwerk_der_verbundenheit_" + nf(frameCount, 5) + ".png");
    println("Gespeichert!");
  }
}

class Node {
  float x, y;
  float vx = random(-0.5, 0.5);
  float vy = random(-0.5, 0.5);
  int connectionsCount = 0;

  Node(float x, float y) {
    this.x = x;
    this.y = y;
  }

  void update() {
    // Sanfte Bewegung
    x += vx;
    y += vy;

    // Leichtes Abprallen an Rändern
    if (x < 50 || x > width - 50) vx *= -1;
    if (y < 50 || y > height - 50) vy *= -1;

    // Anzahl Verbindungen zählen (wird in draw() aktualisiert)
    connectionsCount = 0;
    for (Node other : nodes) {
      if (other != this && dist(x, y, other.x, other.y) < maxDistance) {
        connectionsCount++;
      }
    }
  }

  void display() {
    // Helligkeit und Wärme steigt mit Verbindungen
    float hue = map(connectionsCount, 0, 8, 200, 60);  // Blau → Gold/Rosa
    float brightness = map(connectionsCount, 0, 8, 60, 100);
    float alpha = map(connectionsCount, 0, 8, 100, 255);

    // Glow
    for (int g = 3; g > 0; g--) {
      fill(hue, 70, brightness, alpha / g / 3);
      noStroke();
      ellipse(x, y, 40 * g, 40 * g);
    }

    // Kern
    fill(hue, 80, 100, alpha);
    ellipse(x, y, 30, 30);
  }
}

class Connection {
  Node n1, n2;
  float distance;

  Connection(Node n1, Node n2, float d) {
    this.n1 = n1;
    this.n2 = n2;
    distance = d;
  }

  void display() {
    float alpha = map(distance, 0, maxDistance, 255, 50);
    float weight = map(distance, 0, maxDistance, 4, 1);

    strokeWeight(weight);
    stroke(60, 50, 100, alpha);  // Warmes Gold mit Transparenz
    line(n1.x, n1.y, n2.x, n2.y);
  }
}
