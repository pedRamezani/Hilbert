private String drawRule = "A";
private final int iteration = 7;
private final StringDict renameRules = new StringDict();
private final StringDict productionRules = new StringDict();
private PShape hilbert;
private float lerp = 0.0;
private final float lerpStep = 0.2;
private float strokeWidth;
private int currentVertex = 0;
private final PVector v = new PVector(), w = new PVector();
private boolean finished = false;
private PImage img;
private static final boolean onlyTopRightCorner = true;

void setup() {
  size(500, 500);
  background(255);
  surface.setTitle("Hilbert");
  surface.setResizable(true);
  int newSize = floor(min(displayWidth, displayHeight) * 0.8);
  surface.setSize(newSize, newSize);
  surface.setLocation((displayWidth - width)/2, (displayHeight - height)/2);
  
  renameRules.set("A","0");
  renameRules.set("B","1");
  productionRules.set("0","+BF-AFA-FB+");
  productionRules.set("1","-AF+BFB+FA-");
  
  for (int i = 1; i <= iteration; i++) {
    for (String key : renameRules.keys()) {
      drawRule = drawRule.replace(key, renameRules.get(key));
    }
    
    for (String key : productionRules.keys()) {
      drawRule = drawRule.replaceAll(key, productionRules.get(key));
    }
  }
  println(drawRule);
  
  float lineLength = width * pow(2, -iteration);
  strokeWidth = max(lineLength/2, 1);
  //strokeWeight(strokeWidth);
  
  PVector p = new PVector(lineLength/2, lineLength/2);
  PVector v = new PVector(lineLength,0);
  hilbert = createShape();
  hilbert.beginShape();
  hilbert.vertex(p.x,p.y);
  for (String c : drawRule.split("")) {
    switch (c) {
      case "+":
        v.rotate(HALF_PI);
        break;
      case "-":
        v.rotate(-HALF_PI);
        break;
      case "F":
        p.add(v);
        hilbert.vertex(p.x,p.y);  
        break;
    }
  }
  hilbert.endShape();
  
  img = loadImage("rick.jpg");
  img.resize(width, height);
  img.loadPixels();
  
  frameRate(15000);
}

void draw() {
  //shape(hilbert);
  if (lerp < lerpStep && currentVertex < hilbert.getVertexCount() - 1) {
    v.set(hilbert.getVertex(currentVertex));
    w.set(hilbert.getVertex(++currentVertex));
  } else if (lerp < lerpStep && currentVertex == hilbert.getVertexCount() - 1) {
    v.set(w); 
    finished = true;
  }

  PVector currentPos = PVector.lerp(v, w, lerp);
  noStroke();
  if (onlyTopRightCorner) {
    fill((currentPos.x > width/2 && currentPos.y <= height/2) ? img.pixels[floor(currentPos.x) * 2 + floor(currentPos.y) * 2 * width] : 0);
  }
  else fill(img.pixels[floor(currentPos.x) + floor(currentPos.y) * width]);
  circle(currentPos.x, currentPos.y, strokeWidth);
  
  lerp = (lerp + lerpStep) % 1.0;
  if (finished) noLoop();
}
