import kinect4WinSDK.*;

public class Skeleton extends SkeletonData {
  private HandBouncer leftHand;
  private HandBouncer rightHand;
  
  public Skeleton() {
    super();
    this.leftHand = new HandBouncer(width/2, height/2+200, 20);
    this.rightHand = new HandBouncer(width/2, height/2+200, 20);
  }
  
  public Skeleton(SkeletonData s) {
    this();
    this.skeletonPositions = s.skeletonPositions;
    this.dwTrackingID = s.dwTrackingID;
    this.skeletonPositionTrackingState = s.skeletonPositionTrackingState;
  }
  
  void drawHands() {
    if(this.skeletonPositionTrackingState.length > Kinect.NUI_SKELETON_POSITION_HAND_RIGHT &&
       this.skeletonPositionTrackingState[Kinect.NUI_SKELETON_POSITION_HAND_RIGHT] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED) {
      PVector rightHandPosition = this.skeletonPositions[Kinect.NUI_SKELETON_POSITION_HAND_RIGHT];
      this.rightHand.display(rightHandPosition.x * width, rightHandPosition.y * height);
    }
    if(this.skeletonPositionTrackingState.length > Kinect.NUI_SKELETON_POSITION_HAND_LEFT &&
       this.skeletonPositionTrackingState[Kinect.NUI_SKELETON_POSITION_HAND_LEFT] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED) {
      PVector leftHandPosition = this.skeletonPositions[Kinect.NUI_SKELETON_POSITION_HAND_LEFT];
      this.leftHand.display(leftHandPosition.x * width, leftHandPosition.y * height);
    }
  }
  
  void drawSkeleton(color c) {
    stroke(c);
    DrawBone(Kinect.NUI_SKELETON_POSITION_HEAD, 
    Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER);
    DrawBone(Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER, 
    Kinect.NUI_SKELETON_POSITION_SHOULDER_LEFT);
    DrawBone(Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER, 
    Kinect.NUI_SKELETON_POSITION_SHOULDER_RIGHT);
    DrawBone(Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER, 
    Kinect.NUI_SKELETON_POSITION_SPINE);
    DrawBone(Kinect.NUI_SKELETON_POSITION_SHOULDER_LEFT, 
    Kinect.NUI_SKELETON_POSITION_SPINE);
    DrawBone(Kinect.NUI_SKELETON_POSITION_SHOULDER_RIGHT, 
    Kinect.NUI_SKELETON_POSITION_SPINE);
    DrawBone(Kinect.NUI_SKELETON_POSITION_SPINE, 
    Kinect.NUI_SKELETON_POSITION_HIP_CENTER);
    DrawBone(Kinect.NUI_SKELETON_POSITION_HIP_CENTER, 
    Kinect.NUI_SKELETON_POSITION_HIP_LEFT);
    DrawBone(Kinect.NUI_SKELETON_POSITION_HIP_CENTER, 
    Kinect.NUI_SKELETON_POSITION_HIP_RIGHT);
    DrawBone(Kinect.NUI_SKELETON_POSITION_HIP_LEFT, 
    Kinect.NUI_SKELETON_POSITION_HIP_RIGHT);
  
    // Left Arm
    DrawBone(Kinect.NUI_SKELETON_POSITION_SHOULDER_LEFT, 
    Kinect.NUI_SKELETON_POSITION_ELBOW_LEFT);
    DrawBone(Kinect.NUI_SKELETON_POSITION_ELBOW_LEFT, 
    Kinect.NUI_SKELETON_POSITION_WRIST_LEFT);
    DrawBone(Kinect.NUI_SKELETON_POSITION_WRIST_LEFT, 
    Kinect.NUI_SKELETON_POSITION_HAND_LEFT);
  
    // Right Arm
    DrawBone(Kinect.NUI_SKELETON_POSITION_SHOULDER_RIGHT, 
    Kinect.NUI_SKELETON_POSITION_ELBOW_RIGHT);
    DrawBone(Kinect.NUI_SKELETON_POSITION_ELBOW_RIGHT, 
    Kinect.NUI_SKELETON_POSITION_WRIST_RIGHT);
    DrawBone(Kinect.NUI_SKELETON_POSITION_WRIST_RIGHT, 
    Kinect.NUI_SKELETON_POSITION_HAND_RIGHT);
  
    // Left Leg
    DrawBone(Kinect.NUI_SKELETON_POSITION_HIP_LEFT, 
    Kinect.NUI_SKELETON_POSITION_KNEE_LEFT);
    DrawBone(Kinect.NUI_SKELETON_POSITION_KNEE_LEFT, 
    Kinect.NUI_SKELETON_POSITION_ANKLE_LEFT);
    DrawBone(Kinect.NUI_SKELETON_POSITION_ANKLE_LEFT, 
    Kinect.NUI_SKELETON_POSITION_FOOT_LEFT);
  
    // Right Leg
    DrawBone(Kinect.NUI_SKELETON_POSITION_HIP_RIGHT, 
    Kinect.NUI_SKELETON_POSITION_KNEE_RIGHT);
    DrawBone(Kinect.NUI_SKELETON_POSITION_KNEE_RIGHT, 
    Kinect.NUI_SKELETON_POSITION_ANKLE_RIGHT);
    DrawBone(Kinect.NUI_SKELETON_POSITION_ANKLE_RIGHT, 
    Kinect.NUI_SKELETON_POSITION_FOOT_RIGHT);
    stroke(255, 255, 153);
  }
  
  private void DrawBone(int _j1, int _j2) 
  {
    if(_j1 >= this.skeletonPositions.length || _j2 >= this.skeletonPositions.length) {
      return;
    }
    noFill();
    if (this.skeletonPositionTrackingState[_j1] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED
        && this.skeletonPositionTrackingState[_j2] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED) {
      line(
        this.skeletonPositions[_j1].x*width, 
        this.skeletonPositions[_j1].y*height, 
        this.skeletonPositions[_j2].x*width, 
        this.skeletonPositions[_j2].y*height
      );
    }
  }
}