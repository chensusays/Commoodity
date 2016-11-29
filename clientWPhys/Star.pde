 public class Star{
    Vec2 loc;
    Star(Vec2 l){
        loc = l;
    }

    void display(){
        pushMatrix();
        translate(loc.x, loc.y);
        stroke(255);
        noFill();
        ellipse(0, 0, 10, 10);
        popMatrix();
    }
}