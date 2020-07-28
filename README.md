# Detection and Tracking of A Football

## Project Summary

We study the process of detection and tracking of a football in a series of images. Using image pre-processing techniques and image segmentation, an initial image is prepared in an HSV format and converted to a  binary image based on Hue thresholds that help identify the ball. Using Hough Transforms to find circles, the ball is detected in a specific region and highlighted. Utilising the initial reference point, subsequent sequence of images are passed through a similar process and the ball is searched for in a region around where the ball was detected in the previous image. One sample data source is used for our experiment, converting the video into its frames and performing ball detection on each frame. Centers of ball detected in each frame are plotted on the image in a series to highlight the path traversed by the ball. The final processed images are converted to a video for better visualisation. 

Note: This is a very basic implementation and we will highlight the considerations one must keep in mind to further refine the program and factor in aspects that pose a challenge to effective classification by reviewing some other methods for ball detection and tracking. 

## Data Source

For our Project, we will select a short clip of 5 to 10 seconds long of freely available footage created by people for our purposes where we can identify the football. 

A video playing at 30 Frames per second would give us anywhere between 150 to 300 Images to work with (30 Frames per Second x 10 Seconds = 300 Images). We save each of these frames as separate images in order to process them one by one. Once the images are processed, we can stitch them all back together at a specified frame rate and play it as a video for better visualisation. 

**Name:** Group Of Boys Plays Soccer In A Soccer Field

**Source (click on link):** <https://bit.ly/2WY09HH>

**Time Stamp:** 0:00 to 0:05

**Extracted Frames:** 160

**Planned Playback Frame Rate:** 20 FPS

**Owner:** [Kelly Lacy](https://www.pexels.com/@kelly-lacy-1179532)

The video can be downloaded from the source website specified above. Additionally, the MATLAB code does not include provisions for converting the Video into its respective frames, and converting the output frames into a video. These actions can be done using any free converter online/open-source software.


## Output Video

<span>We stitch all the images together in form of a video and render it as a video at 20 Frames per second. The output video can be viewed at this link : <https://youtu.be/QLIsoOHTw6A> </span>


## Drawbacks of Current Implementation

1.  Ball occlusion by other moving objects and players
2.  High speed motion of the ball making it appear blurry and a long line
3.  Due to the movement of camera, the size of the ball may vary which would effect the accuracy of detection due to changing perspective as it potentially changes color, shape, size properties
4.  Varying external factors such as shadows, light intensity etc. in the video

