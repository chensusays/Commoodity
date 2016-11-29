
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