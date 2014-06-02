%   Tao Du
%   taodu@stanford.edu
%   May 31, 2014

%   test the light model

%   load the light model
load('light_model.mat');

%%  test 1: qualitative test: render a video

normals = pixel_to_camera_2d(ones(height, width), ...
    fc_right, cc_right, kc_right, alpha_c_right);
%   assume we are moving to a wall
wall_normal = [1; 0; -0.2];
wall_normal = wall_normal / norm(wall_normal);
start_point = [0; 0; 600];
frame_num = 40;
speed = 20;
for frame = 1 : frame_num
    
end


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


