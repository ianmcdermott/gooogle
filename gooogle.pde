// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// Flow Field Following
// Via Reynolds: http://www.red3d.com/cwr/steer/FlowFollow.html

// Using this variable to decide whether to draw all the stuff
boolean debug = false;

// Flowfield object
FlowField flowfield;
// An ArrayList of vehicles
ArrayList<Vehicle> vehicles;
PVector gravity = new PVector(0.0, 1.0);
int numVehicles = 850;
PVector pmouseV = new PVector(0, 0);
PVector mouseV = new PVector(0, 0);
int wiggleCountdown;

void setup() {
  //size(800, 800, P3D);
  fullScreen(P3D);
  // Make a new flow field with "resolution" of 16
  flowfield = new FlowField(25);
  vehicles = new ArrayList<Vehicle>();
  // Make a whole bunch of vehicles with random maxspeed and maxforce values
  for (int i = 0; i < numVehicles; i++) {
    vehicles.add(new Vehicle(new PVector(random(width), random(height)), 1, 0.5, random(20, 60)));
  }
}

void draw() {
  pmouseV.x = pmouseX;
  pmouseV.y = pmouseY;
  mouseV.x = mouseX;
  mouseV.y = mouseY;
  background(240, 180, 20);
  // Display the flowfield in "debug" mode
  if (debug) flowfield.display();
  // Tell all the vehicles to follow the flow field
  if (pmouseX == mouseX && pmouseY == mouseY) wiggleCountdown++;
  else wiggleCountdown  = 0;
  for (Vehicle v : vehicles) {
    v.follow(flowfield);
    v.separate(vehicles);
    v.run(constrain(cos(frameCount*0.005)*2, 0.8, 2), new PVector(mouseX, mouseY), frameCount);
    v.applyForce(gravity);
  }
  flowfield.update(float(frameCount)/10, .1, (TWO_PI*-0.5));
  flowfield.trace(pmouseV, mouseV);
  // Instructions
  fill(0, 255, 9);
  text(constrain(cos(frameCount*0.005)*2, 0.1, 2), 20, height-40);
}


void keyPressed() {
  if (key == ' ') {
    debug = !debug;
  }
}

// Make a new flowfield
void mousePressed() {
  flowfield.init();
}
