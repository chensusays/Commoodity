 public class HandBouncer {
    Body body;
    float radius;

    //int col;

    HandBouncer(float x, float y, float r) {
        radius = r;

        // Define a body
        BodyDef bd = new BodyDef();
        bd.type = BodyType.KINEMATIC;
        bd.setBullet(true);

        // Set its position
        bd.position = box2d.coordPixelsToWorld(x,y);
        body = box2d.world.createBody(bd);

        // Make the body's shape a circle
        // Make the body's shape a circle
        CircleShape cs = new CircleShape();
        cs.m_radius = box2d.scalarPixelsToWorld(r);

        FixtureDef fd = new FixtureDef();
        fd.shape = cs;
        // Parameters that affect physics
        fd.density = 1;
        fd.friction = 0.3f;
        fd.restitution = .1f;
        body.setLinearVelocity(new Vec2(0, 0));
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
    void display(float x, float y) {
        noStroke();
        Vec2 pos = body.getWorldCenter();
        Vec2 target = box2d.coordPixelsToWorld(x,y);
        //A vector pointing from the body position to the Mouse

        Vec2 v = target.sub(pos);

        v.mulLocal(5);
        /*if(dist(pos.x, pos.y, target.x, target.y) > 10){
            v.mulLocal();
        }*/
        body.setLinearVelocity(v);
        // We look at each body and get its screen position
        Vec2 posPix = box2d.getBodyPixelCoord(body);
        // Get its angle of rotation
        float a = body.getAngle();
        pushMatrix();
        translate(posPix.x,posPix.y);
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