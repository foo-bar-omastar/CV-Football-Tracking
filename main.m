%-------------------------------------------------------------------------
%*****************Detection and Tracking of Football**********************
%-------------------------------------------------------------------------

% This program is divided into two sections. It is highly recommended to 
% run each of these sections one-by-one separately :
%   1.  Initial image analysis and preparation - Here only a single run with
%       the first frame as reference is performed. This ensures that the
%       program is calibrated to detected the ball and track it for this image
%       and video source.
%   2.  Final Detection and Tracking - Based on section 1, this section
%       will loop through all the files available in the current directory
%       and perform the image analysis and tracking of the football. All
%       the output images will be saved in teh same current directory.

% NOTE: Before running the program, please ensure that your version of
% MATLAB has the Image Processing Toolbax, Deep learning toolbox, Computer
% Vision toolbox installed. Some of the functions used below require those
% toolboxes to run.


%% Section 1: Initial Image Analysis and Preparation
%---------------------------------------------------

clc; % Clear command window.
clearvars; % Get rid of variables from prior run of this m-file.

% Using the first frame to Display the HSV Image and perform initialization
% steps that can be then used for later in the program.
Filename = "video-00001.png"; % Replace with your video file

% Read the input image
Img = imread(Filename);
imshow(Img);
title('Original Image');

% Convert the image to double values and then convert it from RGB to its
% corresponding HSV scale with the below command
img = im2double(imread(Filename));
imgHSV = rgb2hsv(img);

% Apply a median filter of 3x6 dimension for smoothing of the image. This
% dimension was chosen by trial and error method as this yielded the most
% complete binary image upon segmentation based on threshold values in the
% subsequent sections.
imgHSV(:,:,1) = medfilt2(imgHSV(:,:,1),[3 6]);
imgHSV(:,:,2) = medfilt2(imgHSV(:,:,2),[3 6]);
imgHSV(:,:,3) = medfilt2(imgHSV(:,:,3),[3 6]);

% Display the HSV Image with axis and colorbars
figure(1)
imshow(imgHSV(:,:,1))
h = gca;
h.Visible = 'On';
colormap('hsv')
colorbar;

% Display the binary image after thresholding based on the below values as
% observed in the H-channel of the image from the above figure
figure(2)
BW = imgHSV(:,:,1) < 0.12 & imgHSV(:,:,1) > .06;

% Fill up the holes in the images. This helps in completing the shapes in
% the image enabling better accuracy in identifying the object of interest
BW = imfill(BW, 'holes');

% Apply another median filter for further smoothing of the image
BW = medfilt2(BW);

% Get the indivdual dimensions of the image
[m , n] = size(BW);

% Identify circular objects in the image using circular hough transform
% with a radius range between 15 and 100. These dimensions have been
% calibrated based on trial and error method over multiple iterations
[centers, radii, metric] = imfindcircles(BW,[15 100]);

% Loop through the detected circle centers and only select the circle that
% has been identified in the range area of the image as specified below.
for i = 1:length(centers)

    if ((centers(i,1) > 800) & (centers(i,2) > 650))
        ball = centers(i,:);
        ball_radius = radii(i);
    end
    
    
end

% Display original RGB image superimposed with the circle detected above
% with a point marked at its center as well
figure(3)
imshow(img);
h = gca;
h.Visible = 'On';
hold on;
viscircles(ball, ball_radius,'EdgeColor','b');
scatter(ball(:,1),ball(:,2),'*','m')
hold off;

% Display the binary image with the circle superimposed
figure(4)
imgHSV(:,:,1) = medfilt2(imgHSV(:,:,1));
imgHSV(:,:,2) = medfilt2(imgHSV(:,:,2));
imgHSV(:,:,3) = medfilt2(imgHSV(:,:,3));
imshow(BW);
h = gca;
h.Visible = 'On';
hold on;
viscircles(ball, ball_radius,'EdgeColor','b');
scatter(ball(:,1),ball(:,2),'*','m')
hold off;



%--------------------------------------------
%% Section 2: Football Detection and Tracking
%--------------------------------------------

clc; % Clear command window.
clearvars; % Get rid of variables from prior run of this m-file.


% Specify the total frames for which the analysis needs to be done. Here
% for the sake of submission, I have specified 3 frames. However, the
% project has been performed on 160 frames. Changing the value of
% total_frames below can be done to accomodate more frames.
total_frames = 2;
ball_path = zeros(total_frames,3);

% Specifying the Minimum and Maximum Dimensions of the image within which
% the initial position of the ball needs to be searched for. Based on this
% the subsequent positions will be looked for. The threshold variable
% basically specifies the number of pixels to the left, right, top and
% bottom of the centre of the football that will now form a window for
% within which the ball needs to be detected in the next frame and so on.
x_max = 1920;
x_min = 800;
y_max = 1080;
y_min = 600;
threshold = 75;

% Loop to perform all the operations performed in Section 1, but over
% multiple images.
for i = 1:total_frames

    % Variable to check if the ball was found in this frame or not
    ball_found = 0;

    % Convert the image to double values and then convert it from RGB to its
    % corresponding HSV scale with the below command
    img = im2double(imread(strcat("video-",sprintf( '%05d', i ),".png")));
    imgHSV = rgb2hsv(img);
    
    % Apply a median filter of 3x6 dimension for smoothing of the image.
    imgHSV(:,:,1) = medfilt2(imgHSV(:,:,1),[3 6]);
    imgHSV(:,:,2) = medfilt2(imgHSV(:,:,2),[3 6]);
    imgHSV(:,:,3) = medfilt2(imgHSV(:,:,3),[3 6]);

    % Display the binary image after thresholding based on the below values as
    % observed in the H-channel of the image from the above figure
    BW = imgHSV(:,:,1) < 0.12 & imgHSV(:,:,1) > .06;
    % Fill up the holes in the images. This helps in completing the shapes in
    % the image enabling better accuracy in identifying the object of interest
    BW = imfill(BW, 'holes');
    % Apply another median filter for further smoothing of the image
    BW = medfilt2(BW);

    % Get the dimensions of the image
    [m , n] = size(BW);

    % Loop through all ball candidated and select only the ball candidate
    % that if within the search window and assign it to this frame and
    % store the radius, centre in an array for tracking the location of the
    % ball across frames.
    [centers, radii, metric] = imfindcircles(BW,[15 100]);

    if length(centers(:,1)) > 1
        for j = 1:length(centers(:,1))
            if (((centers(j,1) > x_min) & (centers(j,1) < x_max)) & ((centers(j,2) > y_min) & (centers(j,2) < y_max)))
                ball_found = 1;
                ball = centers(j,:);
                ball_radius = radii(j);
            end
        end
    end

    % If the ball is not found in this frame, then assign it the position
    % and properties of the ball from the previous frame, since in this use
    % case the video is actually slow and there isnt significant
    % displacement of the ball per frame.
    if ball_found == 0
        ball = ball_path(i-1,1:2);
        ball_radius = ball_path(i-1,3);
    end

    % Store the ball centre and radius attributes in an array
    ball_path(i,1) = ball(:,1);
    ball_path(i,2) = ball(:,2);
    ball_path(i,3) = ball_radius;

    % Display the final output image with the RGB image superimposed with
    % the ball radius and the red line that tracks the path of teh ball
    % based on all the previous locations of the centres as stored in the
    % array variable on every run.
    figure(i)
    imshow(img);
    h = gca;
    h.Visible = 'On';
    hold on;
    viscircles(ball, ball_radius,'EdgeColor','b');
    scatter(ball(:,1),ball(:,2),'*','m');
    plot(ball_path(1:i,1),ball_path(1:i,2),'-r','LineWidth',2);
    hold off;
    
    % Save the image displayed above into the current directory 
    SaveName = ['Frame_',num2str(i),'.png'];
    saveas(gcf,SaveName);
    
    % Update the search window location based on the detection of ball in
    % current location and using the threshold variable. This prepared the
    % program for the next loop with updated values.
    x_max = ball(:,1) + threshold;
    x_min = ball(:,1) - threshold;
    y_max = ball(:,2) + threshold;
    y_min = ball(:,2) - threshold;

end
