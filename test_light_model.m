%   Tao Du
%   taodu@stanford.edu
%   May 31, 2014

%   test the light model

%   load the light model
load('light_model.mat');

%%  test 1: qualitative test: render a video
%   nx and ny is from init
%   nx = 4928, ny = 3264

normals = pixel_to_camera_2d(ones(ny, nx), ...
    fc_right, cc_right, kc_right, alpha_c_right);
%   assume we are moving to a wall
wall_normal = [1; 0; -0.2];
wall_normal = wall_normal / norm(wall_normal);
start_point = [0; 0; 600];
frame_num = 40;
speed = [0; 0; 20];

%   open up a video object
video_obj = VideoWriter('light_model.avi');
open(video_obj);

video_height = 480;
video_width = 640;
for frame_id = 1 : frame_num
    %   compute each single frame
    point = start_point + frame_id * speed;
    %   the plane equation
    %   wall_normal * (x - point) = 0;
    %   n = wall_normal, d = wall_normal * -point;
    d = -wall_normal' * point;
    [angle, z_dist, radiance] = calib_light_radiance_geometry(...
        ones(ny, nx, 3), wall_normal, d, light_model.light_pos, ...
        light_model.light_dir, normals);
    %   compute the cosine factor
    cosine = 1 ./ radiance;
    %   get the light radiance
    radiance = interp_light_radiance(light_model, angle(:), z_dist(:));
    frame = reshape(radiance', height, width, 3);
    %   resize the frame
    frame = imresize(frame, [video_height, video_width]);
    frame = uint8(frame * 255);
    writeVideo(video_obj, frame);
end
% Close the file.
close(video_obj);

%%  test 2: quantitative test: compute the albedo of the calibration board

bayer_type = 'rggb';
%   use depth_0001.png to test
%   read the depth image
depth = imread('Radiance\depth_0001.png');
%   fit the plane equation
[n, d] = select_plane(depth, ...
    fc_left, cc_left, kc_left, alpha_c_left);
%   transform the plane equation to the DSLR camera space
%   consider a point in that plane
p = [0; 0; -d / n(3)];  
p = R * p + T;  %   transform this point to the new frame
n = R * n;  %   transform the normal of the plane
d = -n' * p;    %   the new plane: n' * (X - p) = 0, or n * X - n' * p = 0;
%   plane equation: n * x + d = 0
%   n * x + d = 0

%   read the dng image
image = read_dng('Radiance\color_0001.dng', bayer_type);
[height, width, ~] = size(image);
normals = pixel_to_camera_2d(ones(height, width), ...
    fc_right, cc_right, kc_right, alpha_c_right);

[ angle, z_dist, radiance_ref ] ...
    = calib_light_radiance_geometry( image, n, d, ...
    light_model.light_pos, light_model.light_dir, normals );
%   the 'true' light
imtool(radiance_ref);

%   now, compute the light from light_model
radiance = interp_light_radiance(light_model, angle(:), z_dist(:));
radiance = reshape(radiance', height, width, 3);
imtool(radiance);
%   compute the difference
imtool(abs(radiance_ref - radiance));
%   compute the 'albedo' of the gray board
%   in the best case, it should be exactly 1
rho = radiance_ref ./ radiance;
imtool(rho);


