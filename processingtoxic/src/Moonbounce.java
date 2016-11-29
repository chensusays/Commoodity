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

    public void setup() {
        noCursor();

        background(0, 0, 70);
        ls = new ArrayList<Lin>();
        frameRate(60);
        box2d = new Box2DProcessing(this);
        box2d.createWorld();
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

            nx+=.02;
        }
        if(transition){
            maxd-=.5;
            if(maxd < 0){
                state = 1;
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




    static public void main(String[] passedArgs) {
        String[] appletArgs = new String[]{"--window-color=#666666", "--stop-color=#cccccc", "Moonbounce"};
        if (passedArgs != null) {
            PApplet.main(concat(appletArgs, passedArgs));
        } else {
            PApplet.main(appletArgs);
        }
    }
}