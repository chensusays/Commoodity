import processing.core.PApplet;

import toxi.geom.*;
import toxi.geom.mesh2d.Voronoi;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;
import toxi.processing.ToxiclibsSupport;
import toxi.util.datatypes.BiasedFloatRange;
import toxi.util.datatypes.FloatRange;

import java.util.ArrayList;


public class papp extends PApplet {


//Sam Nosenzo
//Nature of Code -- Section 5.17
//This program show how particles can be controlled using the mouse





    public static float len1  = 100;
    public static float len2 = 200;
    public static float strength = 0.0001f;

    public static VerletSpring2D spring1;
    public static VerletSpring2D spring2;
    public static Particle p1, p2, p3;
    public static ArrayList<BreakCircle> circs;

    public static ArrayList <BreakCircle> circles = new ArrayList <BreakCircle> ();
    public static VerletPhysics2D physics;
    public static ToxiclibsSupport gfx;
    public static FloatRange radius;
    public static Vec2D origin, mouse;


    public static int maxCircles = 90; // maximum amount of circles on the screen
    public static int numPoints = 50;  // number of voronoi points / segments
    public static int minSpeed = 2;    // minimum speed of a voronoi segment
    public static int maxSpeed = 14;   // maximum speed of a voronoi segment
    public static int framecount = 0;

    public void setup(){

        smooth();
        noStroke();
        gfx = new ToxiclibsSupport(this);
        physics = new VerletPhysics2D();
        physics.setDrag(0.05f);
        //physics.addBehavior(new GravityBehavior(new Vec2D(0, .5f)));
        physics.setWorldBounds(new Rect(30,30,width-30,height-100));
        radius = new BiasedFloatRange(5, 20, 5, 0.6f);
        origin = new Vec2D(width/2,height/2);
        reset();
        //World Setup and additions


    }

    public void draw() {

        removeAddCircles();
        background(0);
        physics.update();

        mouse = new Vec2D(mouseX,mouseY);
        for (int i = 0; i < circles.size(); i++) {
            BreakCircle bc = circles.get(i);
            bc.run();

            stroke(255);
            for(int j = i+1; j < circles.size(); j++){
                BreakCircle bc2 = circles.get(j);
                float d = dist(bc.pos.x, bc.pos.y, bc2.pos.x, bc2.pos.y);
                if(d < 100 && !bc.broken && !bc2.broken){

                    line(bc.pos.x, bc.pos.y, bc2.pos.x, bc2.pos.y);
                }
            }
            noStroke();
        }


        framecount++;
    }

    public void removeAddCircles() {
        for (int i=circles.size()-1; i>=0; i--) {
            // if a circle is invisible, remove it...
            if (circles.get(i).transparency < 0) {
                circles.remove(i);
                // and add two new circles (if there are less than maxCircles)
                if (circles.size() < maxCircles) {
                    //circles.add(new BreakCircle(origin,radius.pickRandom()));
                    //circles.add(new BreakCircle(origin,radius.pickRandom()));
                }
            }
        }
    }
    public void mousePressed(){
        boolean breaking = false;
        for (int i = 0; i < circles.size(); i++) {
            BreakCircle bc = circles.get(i);
            if (bc.broken && mousePressed && mouse.isInCircle(bc.pos, bc.radiusc)) {
                breaking = true;
            }
        }
        if(!breaking && mousePressed && circles.size() < maxCircles){
            circles.add(new BreakCircle(new Vec2D(mouse.x, mouse.y - 30), radius.pickRandom()));
        }

    }

    public void keyPressed() {
        if(key == 's'){
            saveFrame("Circlebreak" + random(1000)+ ".png");
        }
        if (key == ' ') { reset(); }
    }

    public void reset() {
        // remove all physics elements
        for (BreakCircle bc : circles) {
            physics.removeParticle(bc.vp);
            physics.removeBehavior(bc.abh);
        }
        // remove all circles
        circles.clear();
        // add one circle of radiusc 200 at the origin
        circles.add(new BreakCircle(origin,200));
    }

    public void settings(){
        size(1280,720);
    }

    public class Particle extends VerletParticle2D {
        Particle(Vec2D loc){
            super(loc);
        }

        void display(){
            fill(0, 50);
            stroke(0);
            ellipse(x, y, 15, 15);
        }
    }

    class BreakCircle {
        ArrayList <Polygon2D> polygons = new ArrayList <Polygon2D> ();
        Voronoi voronoi;
        FloatRange xpos, ypos;
        PolygonClipper2D clip;
        float[] moveSpeeds;
        Vec2D pos, impact;
        float radiusc;
        int transparency;
        int start;
        VerletParticle2D vp;
        AttractionBehavior abh;
        boolean broken;

        BreakCircle(Vec2D pos, float radius) {
            this.pos = pos;
            this.radiusc = radius;
            vp = new VerletParticle2D(pos);
            abh = new AttractionBehavior(vp, radius*2 + max(0,30-radius), -1.5f, 0);
            physics.addParticle(vp);
            physics.addBehavior(abh);
        }

        void run() {
            // for regular (not broken) circles
            if (!broken) {
                moveVerlet();
                displayVerlet();
                checkBreak();
                // if the circle is broken
            } else {
                moveBreak();
                displayBreak();
            }
        }

        // set position based on the particle in the physics system
        void moveVerlet() {
            pos = vp;
        }

        // display circle
        void displayVerlet() {
            fill(255);
            gfx.circle(pos, radiusc *2);
        }

        // if the mouse is pressed on a circle, it will be broken
        void checkBreak() {
            if (mouse.isInCircle(pos, radiusc) && mousePressed) {
                // remove particle + behavior in the physics system
                physics.removeParticle(vp);
                physics.removeBehavior(abh);
                // point of impact is set to mouseX,mouseY
                impact = mouse;
                initiateBreak();
            }
        }

        void initiateBreak() {
            broken = true;
            transparency = 255;
            start = frameCount;
            // create a voronoi shape
            voronoi = new Voronoi();
            // set biased float ranges based on circle position, radiusc and point of impact
            xpos = new BiasedFloatRange(pos.x- radiusc, pos.x+ radiusc, impact.x, 0.333f);
            ypos = new BiasedFloatRange(pos.y- radiusc, pos.y+ radiusc, impact.y, 0.5f);
            // set clipping based on circle position and radiusc
            clip = new SutherlandHodgemanClipper(new Rect(pos.x- radiusc, pos.y- radiusc, radiusc *2, radiusc *2));
            addPolygons();
            addSpeeds();
        }

        void addPolygons() {
            // add random points (biased towards point of impact) to the voronoi
            for (int i=0; i< numPoints; i++) {
                voronoi.addPoint(new Vec2D(xpos.pickRandom(), ypos.pickRandom()));
            }
            // generate polygons from voronoi segments
            for (Polygon2D poly : voronoi.getRegions()) {
                // clip them based on the rectangular clipping
                poly = clip.clipPolygon(poly);
                for (Vec2D v : poly.vertices) {
                    // if a point is outside the circle
                    if (!v.isInCircle(pos, radiusc)) {
                        // scale it's distance from the center to the radiusc
                        clipPoint(v);
                    }
                }
                polygons.add(new Polygon2D(poly.vertices));
            }
        }

        void addSpeeds() {
            // generate random speeds for all polygons
            moveSpeeds = new float[polygons.size()];
            for (int i=0; i<moveSpeeds.length; i++) {
                moveSpeeds[i] = random(minSpeed,maxSpeed);
            }
        }

        // move polygons away from the point of impact at their respective speeds
        void moveBreak() {
            for (int i=0; i<polygons.size(); i++) {
                Polygon2D poly = polygons.get(i);
                Vec2D centroid = poly.getCentroid();
                Vec2D targetDir = centroid.sub(impact).normalize();
                targetDir.scaleSelf(moveSpeeds[i]);
                for (Vec2D v : poly.vertices) {
                    v.set(v.addSelf(targetDir));
                }
            }
        }

        // draw the polygons
        void displayBreak() {
            // after 12 frames, start decreasing the transparency
            if (frameCount-start > 12) { transparency -= 7; }
            fill(255,transparency);
            for (Polygon2D poly : polygons) {
                gfx.polygon2D(poly);
            }
        }

        void clipPoint(Vec2D v) {
            v.subSelf(pos);
            v.normalize();
            v.scaleSelf(radiusc);
            v.addSelf(pos);
        }
    }






    static public void main(String[] passedArgs) {
        String[] appletArgs = new String[]{"--window-color=#666666", "--stop-color=#cccccc", "papp"};
        if (passedArgs != null) {
            PApplet.main(concat(appletArgs, passedArgs));
        } else {
            PApplet.main(appletArgs);
        }
    }


}