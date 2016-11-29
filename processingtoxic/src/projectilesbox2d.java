import processing.core.PApplet;

import java.util.ArrayList;
import java.util.Iterator;

import processing.core.PVector;
import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;




public class projectilesbox2d extends PApplet {

    public static Box2DProcessing box2d;
    public static ArrayList<Proj> ps;
    public static ArrayList<Box> bxs;
    public static ArrayList<Bit> bts;


    public void setup() {
        frameRate(60);
        background(255);
        box2d = new Box2DProcessing(this);
        box2d.createWorld();
        box2d.listenForCollisions();
        //custom gravity;
        box2d.setGravity(0, -10);
        ps = new ArrayList<Proj>();
        bxs = new ArrayList<Box>();
        bts = new ArrayList<Bit>();
    }


    public void draw(){
        background(255);
        box2d.step();

        for(int i = ps.size()-1; i >= 0; i--){
            Proj p = ps.get(i);
            p.display();
            //Particles that leave the screen we delete
            //need to be deleted from the list and the world
            if(p.done()){
                ps.remove(i);
            }
        }

        for(int i = bxs.size()-1; i >= 0; i--){
            Box bx = bxs.get(i);
            bx.display();
            if(bx.done() || bx.alive == false){
                Vec2 pos = box2d.getBodyPixelCoord(bx.body);
                float size = bx.sz;
                bxs.remove(i);

                for (int j = 0; j < 2*size; j++){
                    bts.add(new Bit(pos.x+random(-size, size), pos.y+random(-size, size)));
                }
            }
        }

        for(int i = bts.size()-1; i >= 0; i--){
            Bit bt = bts.get(i);
            bt.display();
            if(bt.done()){
                bts.remove(i);
            }
        }

        if(mousePressed){
            //ps.add(new Proj(mouseY));
            //bxs.add(new Box(mouseX, mouseY));
        }


    }



    public void mousePressed(){
        ps.add(new Proj(mouseY));
        bxs.add(new Box(mouseX, mouseY));

    }

    public void keyPressed(){
        if(key=='s'){
            saveFrame("bulletexplo"+random(3000)+".png");
        }
    }


    public void settings() {
        size(650, 350);

    }


    public void beginContact(Contact cp){
        //Get both fixtures
        Fixture f1 = cp.getFixtureA();
        Fixture f2 = cp.getFixtureB();
        //get both Bodies
        Body b1 = f1.getBody();
        Body b2 = f2.getBody();
        //Get our object that reference these bodies
        Object o1 = b1.getUserData();
        Object o2 = b2.getUserData();

        //If object 1 is a Projectile then Object 2 must be a box
        //note that we are ignoring particle on particle collisions
        if(o1.getClass() == Proj.class && o2.getClass() != Bit.class && o2.getClass() != Proj.class){
            Box b = (Box) o2;
            b.alive = false;




        }
        //If object 2 is a Projectile, then object 1 is a box
        else if(o2.getClass() == Proj.class && o1.getClass() != Bit.class && o1.getClass() != Proj.class){
            Box b = (Box) o1;

            b.alive = false;


            //Put particle shatter class here

            // println("This should be working for some reason");

        }
    }

    public void endContact(Contact cp){
    }


    class Proj{
        float y;
        float x1, y1, x2, y2, x3, y3;
        float mass;
        Body body;

        Proj(float y_){
            y = y_;
            mass = 1;
            x1 = 10*mass*cos(0);
            y1 = 10*mass *sin(0);
            x2 = 10 * mass * cos(PI-PI/8);
            y2 = 10 * mass * sin(PI-PI/8);
            x3 = 10 * mass * cos(PI+PI/8);
            y3 = 10 * mass * sin(PI+PI/8);

            makeBody(new Vec2(0, y));
            body.setUserData(this);

        }

        public void killBody(){
            box2d.destroyBody(body);
        }

        boolean done(){
            Vec2 pos = box2d.getBodyPixelCoord(body);
            if(pos.y> height || pos.x > width){
                killBody();
                return true;
            }
            return false;
        }


        boolean contains(float x, float y){
            Vec2 worldPoint = box2d.coordPixelsToWorld(x, y);
            Fixture f = body.getFixtureList();
            boolean inside = f.testPoint(worldPoint);
            return inside;
        }



        public void display(){
            Vec2 pos = box2d.getBodyPixelCoord(body);
            //get rotation
            float a = body.getAngle();

            Fixture f = body.getFixtureList();
            PolygonShape ps = (PolygonShape) f.getShape();

            rectMode(CENTER);
            stroke(0);
            fill(0);

            pushMatrix();
            translate(pos.x, pos.y);
            rotate(-a);
            beginShape();
            for(int i = 0; i < ps.getVertexCount(); i++){
                Vec2 v = box2d.vectorWorldToPixels(ps.getVertex(i));
                vertex(v.x, v.y);
            }
            endShape(CLOSE);
            popMatrix();
        }
        public void makeBody(Vec2 center){
            PolygonShape sd = new PolygonShape();

            Vec2[] vert = new Vec2[3];
            vert[0] = box2d.vectorPixelsToWorld(new Vec2(x1, y1));
            vert[1] = box2d.vectorPixelsToWorld(new Vec2(x2, y2));
            vert[2] = box2d.vectorPixelsToWorld(new Vec2(x3, y3));

            sd.set(vert, vert.length);

            FixtureDef fd = new FixtureDef();
            fd.shape = sd;
            //Parameters that affect physics
            fd.density = 1000;
            fd.friction = .3f;
            fd.restitution = .9f;



            //Define the body and make it fromt he shape
            BodyDef bd = new BodyDef();
            bd.type = BodyType.DYNAMIC;
            bd.position.set(box2d.coordPixelsToWorld(center));
            bd.setBullet(true);


            body = box2d.createBody(bd);
            body.createFixture(fd);

            //give random velocity
            body.setLinearVelocity(new Vec2(random(1000, 10000), 0));
            body.setAngularVelocity(0);


        }


    }


    //creates a box object on the screen
    class Box{

        Body body;
        float sz;
        boolean alive;
        Box(float x, float y){
            sz = random(10, 50);
            alive = true;
            makeBody(new Vec2(x, y), sz);
            body.setUserData(this);
        }

        public void killBody(){
            box2d.destroyBody(body);
        }
        //delete?
        boolean done(){
            //find position of particle
            Vec2 pos = box2d.getBodyPixelCoord(body);
            //Is it off the bottom of the screen?
            if(pos.y > height+sz*sz || alive == false){
                killBody();
                return true;
            }
            return false;
        }

        public void display(){
            // We look at each body and get its screen position
            Vec2 pos = box2d.getBodyPixelCoord(body);
            // Get its angle of rotation
            float a = body.getAngle();

            rectMode(CENTER);
            pushMatrix();
            translate(pos.x, pos.y);
            rotate(-a);
            fill(0);
            stroke(0);
            rect(0, 0,sz, sz);
            popMatrix();
        }


        public void makeBody(Vec2 center, float sz_){
            //Define a polygon (this is for square);
            PolygonShape sd = new PolygonShape();
            float box2dsz = box2d.scalarPixelsToWorld(sz/2);
            sd.setAsBox(box2dsz, box2dsz);

            //Define fixture
            FixtureDef fd = new FixtureDef();
            fd.shape = sd;
            //Parameters that affect physics
            fd.density = 1f;
            fd.friction = .3f;
            fd.restitution = 0.9f;

            //Define the body and make it from the shape
            BodyDef bd = new BodyDef();
            bd.type = BodyType.DYNAMIC;
            bd.position.set(box2d.coordPixelsToWorld(center));

            body = box2d.createBody(bd);
            body.createFixture(fd);

            //Give it some initial random velocity
            body.setLinearVelocity(new Vec2(random(-5, 5), random(-5, 5)));
            body.setAngularVelocity(random(-5, 5));
        }
    }




    class Bit{
        PVector location;
        float x1, y1, x2, y2, x3, y3;
        float mass;
        float angle =0 ;


        Body body;

        Bit(float x, float y){

            mass = random(.1f, .2f);
            //mass = constrain(mass, 1, 6);
            float a1, a2, a3;
    /* Random Angles
    a1 = random(TWO_PI/3);
    a3 = random(TWO_PI/3+.01, 2*TWO_PI/3-.01);
    a2 = random(2*TWO_PI/3, 3*TWO_PI/3);
    */
            a1 = 0;
            a3 = TWO_PI/3;
            a2 = -TWO_PI/3;

    /*
    a1 = 0;
    a2 = random(.01, PI-.1);
    a3 = random(PI+.1, TWO_PI-.1);
    */
            x1 = 10*mass*cos(a1);
            y1 = 10*mass *sin(a1);
            x2 = 10 * mass * cos(a2);
            y2 = 10 * mass * sin(a2);
            x3 = 10 * mass * cos(a3);
            y3 = 10 * mass * sin(a3);


            println("a1 = " + a1);
            println("a2 = " + a2);
            println("a3 = " + a3);

            makeBody(new Vec2(x, y));
            body.setUserData(this);

        }

        public void killBody(){
            box2d.destroyBody(body);
        }
        //particle ready for deletion?
        boolean done(){
            //screen position of particle
            Vec2 pos = box2d.getBodyPixelCoord(body);
            //is it off the bottom of the screen?
            if(pos.y > height){
                killBody();
                return true;
            }
            return false;
        }







        public void display(){

            Vec2 pos  = box2d.getBodyPixelCoord(body);
            //get its rotation
            float a = body.getAngle();

            Fixture f = body.getFixtureList();
            PolygonShape ps = (PolygonShape) f.getShape();


            rectMode(CENTER);
            stroke(0);
            fill(0);
            pushMatrix();
            translate(pos.x, pos.y);
            rotate(-a);
            beginShape();
            for(int i = 0; i < ps.getVertexCount(); i++){
                Vec2 v = box2d.vectorWorldToPixels(ps.getVertex(i));
                vertex(v.x,v.y);
            }
            endShape(CLOSE);
            popMatrix();
        }

        public void makeBody(Vec2 center){
            PolygonShape sd = new PolygonShape();

            Vec2[] vert = new Vec2[3];
            vert[0] = box2d.vectorPixelsToWorld(new Vec2(x1, y1));
            vert[1] = box2d.vectorPixelsToWorld(new Vec2(x2, y2));
            vert[2] = box2d.vectorPixelsToWorld(new Vec2(x3, y3));

            sd.set(vert, vert.length);

            //Define the body and make it fromt he shape
            BodyDef bd = new BodyDef();
            bd.type = BodyType.DYNAMIC;
            bd.position.set(box2d.coordPixelsToWorld(center));
            bd.setBullet(true);
            body = box2d.createBody(bd);
            body.createFixture(sd, 1.0f);

            //give random velocity
            body.setLinearVelocity(new Vec2(random(50, 100), random(-20, 20)));
            body.setAngularVelocity(random(-5, 5));


        }
    }



    static public void main(String[] passedArgs) {
        String[] appletArgs = new String[]{"--window-color=#666666", "--stop-color=#cccccc", "projectilesbox2d"};
        if (passedArgs != null) {
            PApplet.main(concat(appletArgs, passedArgs));
        } else {
            PApplet.main(appletArgs);
        }
    }


}