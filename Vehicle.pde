// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// Flow Field Following

class Vehicle {

  // The usual stuff
  PVector position;
  PVector velocity;
  PVector acceleration;
  PVector prevVel;
  float r;
  float origR;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  color c = color(0, 0, 0);
  float amp = 20;
  float sep = 20;
  float origmaxforce;
  PVector lookAt = new PVector(width/2, height/2);
  PVector randDir;
  Vehicle(PVector l, float ms, float mf, float r_) {
    position = l.get();
    r = r_;
    origR = r;
    maxspeed = ms;
    maxforce = r/100;
    origmaxforce = maxforce;
    acceleration = new PVector(0, 0);
    velocity = new PVector(0, 0);
    randDir = new PVector(random(-width, width), random(-height, height));
  }

  public void run(float updater, PVector m, int fc) {
    update(updater);
    borders();
    display(m, fc);
  }


  // Implementing Reynolds' flow field following algorithm
  // http://www.red3d.com/cwr/steer/FlowFollow.html
  void follow(FlowField flow) {
    // What is the vector at that spot in the flow field?
    PVector desired = flow.lookup(position);
    // Scale it up by maxspeed
    desired.mult(maxspeed);
    // Steering is desired minus velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    applyForce(steer);
  }

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }

  // Method to update position
  void update(float fluctuateForce) {
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    prevVel = velocity;
    position.add(velocity);
    maxforce = fluctuateForce*origmaxforce*5;
    // Reset accelertion to 0 each cycle
    acceleration.mult(0);
    // Scale Radius based on x and y location - smooth sine-based
    r = constrain((sin((float)position.x/50)*amp+origR)-(sin((float)position.y/50)+origR/2), 5, 100);
    //noise Alternative
    r += constrain((noise((float)position.x/50)*amp+origR)-(noise((float)position.y/50)+origR/2), 5, 100);
  }

  void display(PVector m, int fc) {
    // Draw a triangle rotated in the direction of velocity
    float theta = velocity.heading2D() + radians(90);
    //PVector moos;
    //if (wiggleCountdown >= 100)     moos = position.add(new PVector(random(-r, r), random(-r, r)));
    //moos = m;
    PVector dist ;
    if (wiggleCountdown >= 1000) { 
      lookAt = new PVector((noise(position.x +fc*20)), noise((position.y+fc*20))).add(randDir);
      dist = new PVector((noise(position.x +fc*20)), noise((position.y+fc*20))).add(randDir);
    } else { 
      lookAt = PVector.sub(m, position);
      dist = PVector.sub(m, position);
    }
    float distMag = (constrain(dist.mag(), -r*0.5/1.26/4, r*0.5/1.26/4));

    lookAt.normalize();

    //float pupilPos = constrain(lookAt.mag(), -r*200, r*200);
    lookAt.mult(distMag);

    //lookAt.mult(r*0.5/5.5);
    //lookAt = dist;
    //lookAt = constrain(lookAt, 0, r*0.5/5.5);
    fill(c);
    noStroke();
    pushMatrix();
    translate(position.x, position.y, 0);
    //rotate(theta);
    ellipse(0, 0, r*0.5, r*0.5);
    fill(255);
    ellipse(0, 0, r*0.5/1.26, r*0.5/1.26);
    translate(lookAt.x, lookAt.y);
    fill(0);
    ellipse(0, 0, r*0.5/2.55, r*0.5/2.55);
    fill(255);
    ellipse(-r/16.3, -r/49, r*0.5/11.5, r*0.5/11.5);

    //sphere(r*0.17);
    popMatrix();
  }

  // Wraparound
  void borders() {
    if (position.x < -origR) position.x = width+origR;
    if (position.y < -origR) position.y = height+origR;
    if (position.x > width+origR) position.x = -origR;
    if (position.y > height+origR) position.y = -origR;
  }

  void separate (ArrayList<Vehicle> vehicles) {
    // Note how the desired separation is based
    // on the Vehicle’s size.
    float desiredseparation = r*4.5; //[bold]
    PVector sum = new PVector();
    int count = 0;
    for (Vehicle other : vehicles) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d <= desiredseparation)) {
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        // What is the magnitude of the PVector
        // pointing away from the other vehicle?
        // The closer it is, the more we should flee.
        // The farther, the less. So we divide
        // by the distance to weight it appropriately.
        diff.div(d);  //[bold]
        sum.add(diff);
        count++;
      } 
      //if (d < desiredseparation) {
      //  c = color(255, 0, 0);
      //} else {
      //  c = color(0, 0, 0);
      //}
    }

    if (count > 0) {
      sum.div(count);
      sum.normalize();
      sum.mult(maxspeed*20);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
      applyForce(steer);
      //c = color(255, 0, 0);
    } else {
      //c = color(0, 0, 0);
    }
  }
}
