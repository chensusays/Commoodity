public class Moon { //based off of Dan Shiffman's Particle class in PBox2D tutorial
    // We need to keep track of a Body and a radius
    Body body;
    float radius;

    //int col;

    Moon(float x, float y, float r, boolean fixed) {
        radius = r;

        // Define a body
        BodyDef bd = new BodyDef();
        if (fixed) bd.type = BodyType.STATIC;
        else bd.type = BodyType.DYNAMIC;

        // Set its position
        bd.position = box2d.coordPixelsToWorld(x,y);
        body = box2d.world.createBody(bd);


        // Make the body's shape a circle
        CircleShape cs = new CircleShape();
        cs.m_radius = box2d.scalarPixelsToWorld(r);

        FixtureDef fd = new FixtureDef();
        fd.shape = cs;
        // Parameters that affect physics
        //fd.density = 1;
        fd.friction = 0.8f;
        fd.restitution = .5f;

        body.createFixture(fd);

        //col = color(175);
    }

    // This function removes the particle from the box2d world
    void killBody() {
        box2d.destroyBody(body);
    }

    // delete
    boolean done() {
        // Let's find the screen position of the particle
        Vec2 pos = box2d.getBodyPixelCoord(body);
        // Is it off the bottom of the screen?
        if (pos.y > height+radius*2) {
            killBody();
            return true;
        }
        return false;
    }

    //
    void display() {
        // We look at each body and get its screen position
        Vec2 pos = box2d.getBodyPixelCoord(body);
        // Get its angle of rotation
        float a = body.getAngle();
        pushMatrix();
        translate(pos.x,pos.y);
        rotate(a);
        //fill(col);
        fill(255, 255, 169);
        stroke(255, 255, 153);
        //stroke(0);
        strokeWeight(1);
        ellipse(0,0,radius*2,radius*2);
        // Let's add a line so we can see the rotation
        line(0,0,radius,0);
        popMatrix();
    }

}