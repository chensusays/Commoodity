import processing.core.PApplet;
import processing.core.PVector;
import shiffman.box2d.Box2DProcessing;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;

import java.util.ArrayList;

public class Moonbounce extends PApplet {


    float maxd = 150;


    ArrayList<Lin> ls;

    int state = 0;
    boolean transition = false;
    float nx = 0;
    int currx = 0;
    int curry = 0;
    Box2DProcessing box2d;
    Moon m;
    Boundary b;
    HandBouncer  mouseBouncer;

    public void setup() {
        noCursor();

        background(0, 0, 70);
        ls = new ArrayList<Lin>();
        frameRate(60);
        box2d = new Box2DProcessing(this);
        box2d.createWorld();
        //b = new Boundary(0, -height, width, height*3);
        //box2d.listenForCollisions();
        //custom gravity;

        box2d.setGravity(0, -10);

    }

    public void draw() {
        //background(0);
        fill(15, 0, 35, 20);
        noStroke();
        rect(0, 0, width, height);
        if(state == 0){
            if(!transition){
                currx = (int) map(noise(nx), 0, 1, -100, width+100);
                curry = (int) map(noise(0, nx), 0, 1, -100, height+100);
            } else {
                currx = (int) lerp(currx, width/2, .05f);
                curry = (int) lerp(curry, height/2, .05f);
            }

            stroke(255);
            if( ls.size() < 50 && maxd > 10){
                for(int i = 0; i < 10; i++){
                    ls.add(new Lin(currx, curry));
                }
            }
            //Iterator<Lin> it = ls.iterator();

            for(int i = 0; i < ls.size();i++){
                Lin l = ls.get(i);
                l.display(currx, curry);
                for(int j = i+1; j < ls.size();j++){
                    Lin l2 = ls.get(j);
                    if(dist(l2.end.x, l2.end.y, l.end.x, l.end.y) < 25){
                        line(l2.end.x, l2.end.y, l.end.x, l.end.y);
                    }
                }

                if(l.tooFar(currx, curry) || maxd < 2){
                    ls.remove(l);
                }

            }
            if(transition){
                maxd-=.5;
                if(maxd < 0){
                    state = 1;
                    transition = false;
                }
            }
            nx+=.02;
        } else if(state == 1){

            fill(255, 255, 169);
            ellipse(width/2, height/2, maxd, maxd);
            maxd++;
            if(maxd > 100){
                m = new Moon(width/2, height/2, maxd/2, false);
                state = 2;
                mouseBouncer = new HandBouncer(mouseX, mouseY, 20, true);
            }
        } else if (state == 2) {
            box2d.step();
            mouseBouncer.killBody();
            mouseBouncer = new HandBouncer(mouseX, mouseY, 20, true);
            m.display();
            mouseBouncer.display();
            if(m.done()){
                m = new Moon(width/2, height/2, maxd/2, false);
            }


        }
    }


    public void mousePressed(){
        background(0);
    }

    public void keyPressed(){
        if(key == 'c'){
            transition = true;
        }
    }


    public void settings() {
        fullScreen();
        //size(800, 800);

    }




    public class Lin{
        PVector end;


        Lin(int x, int y){
            end = new PVector();
            end.x = random(x-maxd, x+maxd);
            end.y = random(y-maxd, y+maxd);

        }

        void display(int x, int y){
            stroke(255, 50);
            //line(x, y, end.x, end.y);
            ellipse(end.x, end.y, 3, 3);
        }

        boolean tooFar(int x, int y){
            float d = dist(x, y, end.x, end.y);
            boolean u = false;
            if(d <= maxd+50){
                u = false;

            }
            else if(d > maxd+50){
                u = true;

            }
            return(u);
        }
    }

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
            // Make the body's shape a circle
            CircleShape cs = new CircleShape();
            cs.m_radius = box2d.scalarPixelsToWorld(r);

            FixtureDef fd = new FixtureDef();
            fd.shape = cs;
            // Parameters that affect physics
            //fd.density = 1;
            fd.friction = 0.3f;
            fd.restitution = 1f;

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
            stroke(0);
            strokeWeight(1);
            ellipse(0,0,radius*2,radius*2);
            // Let's add a line so we can see the rotation
            line(0,0,radius,0);
            popMatrix();
        }

    }

    public class HandBouncer {
        Body body;
        float radius;

        //int col;

        HandBouncer(float x, float y, float r, boolean fixed) {
            radius = r;

            // Define a body
            BodyDef bd = new BodyDef();
            if (fixed) bd.type = BodyType.STATIC;
            else bd.type = BodyType.DYNAMIC;

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
            fd.restitution = 0.5f;

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
            stroke(0);
            strokeWeight(1);
            ellipse(0,0,radius*2,radius*2);
            // Let's add a line so we can see the rotation
            line(0,0,radius,0);
            popMatrix();
        }
    }

    public class Boundary{

        float x, y;
        float w,h;

        Body b;

        Boundary(float x_, float y_, float w_, float h_){
            x = x_;
            y = y_;
            w = w_;
            h = h_;


            BodyDef bd = new BodyDef();
            bd.position.set(box2d.coordPixelsToWorld(x,y));
            bd.type = BodyType.STATIC;
            b = box2d.createBody(bd);

            float box2dW = box2d.scalarPixelsToWorld(w/2);
            float box2dH = box2d.scalarPixelsToWorld(h/2);

            PolygonShape ps = new PolygonShape();
            ps.setAsBox(box2dW, box2dH);

            b.createFixture(ps, 1);
            b.setUserData(this);
        }

        void display(){
            fill(0);
            stroke(0);
            rectMode(CENTER);
            rect(x, y , w, h);
        }
    }


    public class TrackingCursor{
        float depth;
        int numArcs;
        float[] startingAngles;
        float[] angleRates;
        float[] arcRadii;
        float maxradius;
        float minradius;
        float radius;
        PVector loc;
        int col;
        float nx;

        public TrackingCursor(){// initialized ot the center of the screen
            numArcs = 15;
            loc = new PVector(width/2, height/2);
            maxradius = 100;
            minradius = 10;
            nx = random(100);
            depth = 0;
            col = color(random(255), random(255), random(255), 60);
            startingAngles = new float[numArcs];
            angleRates = new float[numArcs];
            arcRadii = new float[numArcs];
            for(int i = 0; i < numArcs; i++){
                startingAngles[i] = random(0, 4*PI);
                angleRates[i] = random(-.2f, .2f);
                arcRadii[i] = random(minradius, maxradius);
            }
        }

        public void display(int x, int y, float d){
            loc.x = x;
            loc.y = y;

            depth = d;
            radius = map(d, 0, 30, maxradius, minradius);
            drawArcs();
            fill(col);
            ellipse(x, y, radius, radius);
        }
        public void drawArcs(){
            //noFill();
            fill(255, 30);
            stroke(255);

            pushMatrix();
            translate(loc.x, loc.y);
            for(int i = 0; i < numArcs; i++){
                float arcRad = map(arcRadii[i], minradius, maxradius, minradius, radius);
                strokeWeight(map(arcRad, minradius, radius, 1, 4));
                arc(0, 0, arcRad, arcRad, startingAngles[i], startingAngles[i]+PI*noise(nx + i*20));
                startingAngles[i] += angleRates[i];
            }
            nx+=.01;
            popMatrix();
            noStroke();
            strokeWeight(1);
        }


    }




    static public void main(String[] passedArgs) {
        String[] appletArgs = new String[]{"--window-color=#666666", "--stop-color=#cccccc", "Moonbounce"};
        if (passedArgs != null) {
            PApplet.main(concat(appletArgs, passedArgs));
        } else {
            PApplet.main(appletArgs);
        }
    }
}