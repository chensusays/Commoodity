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