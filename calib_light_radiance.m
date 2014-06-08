%   Tao Du
%   taodu@stanford.edu
%   May 31, 2014

%   calibrate the radiance of our LED light
%   take depth/color/color images of a white, diffuse board, put them under
%   the folder /Radiance

%   the output of the script is a non-parametric light model, for each
%   point p in the space, we use two parameters to describe its position:
%       angle: the angle between light_dir and p - light_pos
%       z_dist: the projected length in light_dir, i.e., norm(p -
%       light_pos) * cos(angle);
%   the light model includes:
%       light_pos: the light position in the DSLR camera t
%       light_dir: a unit vector, the light direction in the DSLR camear
%       frame
%       min_angle/max_angle: the minimum/maximum angle in the light model
%       n_bin_angle: the number of bins in angle
%       angle_step: (max_angle - min_angle) / n_bin_angle
%       min_z_dist/max_z_dist: minimum/maximum z_dist in the light model
%       n_bin_z_dist: the number of bins in z_dist
%       z_dist_step: (max_z_dist - min_z_dist) / n_bin_z_dist
%       radiance: a n_bin_angle by n_bin_z_dist by 3 matrix.
%   given a 3d point p in the camera frame, we will compute its angle and
%   z_dist, then do bilinear interpolation in radiance. the function
%   comp_light_radiance wraps this procedure

%%  setting
%   bayer type
bayer_type = 'gbrg';
resize_ratio = 0.25;
%   configuration of the clampped bin in angle and theta
%   change them if necessary
min_angle = 0;
max_angle = pi / 16;
n_bin_angle = 30;
min_z_dist = 500;
max_z_dist = 1000;
n_bin_z_dist = 50;

%   build angle sample and z sample
angle_step = (max_angle - min_angle) / n_bin_angle;
z_dist_step = (max_z_dist - min_z_dist) / n_bin_z_dist;
angle_samples = min_angle + ((1 : n_bin_angle) - 0.5) * angle_step;
z_dist_samples = min_z_dist + ((1 : n_bin_z_dist) - 0.5) * z_dist_step;
radiance_samples = zeros(n_bin_angle, n_bin_z_dist, 3);
radiance_samples_count = zeros(n_bin_angle, n_bin_z_dist);

%%  extract the samples
%   get the number of the images
img_num = numel(dir('Radiance\*.png'));
%   get the height and the width of the dng image
image = read_dng('Radiance\color_0001.dng', bayer_type);
image = imresize(image, resize_ratio);
[height, width, ~] = size(image);
%   precompute the normal pixel vectors in DSLR camera frame
normals = pixel_to_camera_2d(ones(height, width), ...
    fc_right, cc_right, kc_right, alpha_c_right);

%   load light information
load('light_info.mat');

%   scan all the sample images
for i = 1 : img_num
    num_suffix = num2str(i, '%.4d');
    %   read the depth image
    depth = imread(['Radiance\depth_', num_suffix, '.png']);
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
    image = read_dng(['Radiance\color_', num_suffix, '.dng'], bayer_type);
    image = imresize(image, resize_ratio);
    imshow(image.^(1/2.2)); %   show the image
    pixels = ginput();  %   select the valid region of the image
    close all;
    pixels = [pixels; pixels(1, :)];
    [X, Y] = meshgrid(1:width, 1:height);
    XV = pixels(:,1);
    YV = pixels(:,2);
    mask = inpolygon(X, Y, XV, YV); %   get the mask
    %   filter out overexposure regions
    mask = mask & image(:,:,1) < 1 & image(:,:,2) < 1 & image(:,:,3) < 1;
    
    [ angle, z_dist, radiance ] = calib_light_radiance_geometry( image, n, d, ...
        light_pos, light_dir, normals );

    %   compute invalid_id
    %   mask the results
    z_dist = z_dist .* mask;
    z_dist = z_dist(:);
    angle = angle(:);
    %   remove the pixels out in the valid region
    %   also remove the pixels not in the valid range of angle and dist
    invalid_id = ...
        z_dist == 0 | angle <= min_angle | angle > max_angle...
        | z_dist <= min_z_dist | z_dist > max_z_dist;
    %   filter z_dist
    z_dist(invalid_id) = [];
    %   filter the angle
    angle(invalid_id) = [];
    %   filter the radiance
    radiance = reshape(radiance, height * width, 3);
    radiance(invalid_id, :) = [];
    %   now we have angle, z_dist, image_r, image_g, image_b
    angle_id = ceil((angle - min_angle) / angle_step);
    z_dist_id = ceil((z_dist - min_z_dist) / z_dist_step);
    %   linearize the index
    lin_id = sub2ind(size(radiance_samples_count), angle_id, z_dist_id);
    count = lin_id;
    count(:) = 1;
    %   reduce function
    [lin_id, reduce_result] = reduce_by_id(lin_id, [count radiance]);
    radiance_samples_count(lin_id) ...
        = radiance_samples_count(lin_id) + reduce_result(:, 1);
    for channel = 1 : 3
        single_sample = radiance_samples(:, :, channel);
        single_sample(lin_id) ...
            = single_sample(lin_id) + reduce_result(:, channel + 1);
        radiance_samples(:, :, channel) = single_sample;
    end
end

%   average the results
for channel = 1 : 3
    radiance_samples(:, :, channel) ...
        = radiance_samples(:, :, channel) ./ radiance_samples_count;
end
radiance_samples(radiance_samples == inf | isnan(radiance_samples)) = 0;

%   save the data so that we won't need to do it again
save('light_radiance_sample.mat', ...
    'radiance_samples', 'min_angle', 'max_angle', 'n_bin_angle', ...
    'min_z_dist', 'max_z_dist', 'n_bin_z_dist', ...
    'angle_step', 'z_dist_step', ...
    'angle_samples', 'z_dist_samples');

%   free the memory
clear angle angle_id count image invalid_id mask normals radiance ...
    z_dist z_dist_id;
%%  fit the model
%   now that we have gathered all the samples, we clamp them, and fit them
%   by the power law
load('light_radiance_sample.mat');
%   fit the data
X = angle_samples;
Y = z_dist_samples / 1000;
%   Z = a*exp(-x^2/b)*y^(c)
%   each column represents the parameters for a channel
paras = zeros(3, 3);
for channel = 1 : 3
    Z = radiance_samples(:,:,channel);
    W = double(Z > 0);
    [func, stat] = fit_gauss_power_function(X, Y, Z, W);
    a = func.a;
    b = func.b;
    c = func.c;
    a = a/(1000^c);
    paras(1, channel) = a;
    paras(2, channel) = b;
    paras(3, channel) = c;
    disp('stats');
    disp(stat);
end

%   save the light model
light_model.light_pos = light_pos;
light_model.light_dir = light_dir;
light_model.min_angle = min_angle;
light_model.max_angle = max_angle;
light_model.n_bin_angle = n_bin_angle;
light_model.min_z_dist = min_z_dist;
light_model.max_z_dist = max_z_dist;
light_model.n_bin_z_dist = n_bin_z_dist;
light_model.paras = paras;
save('light_model.mat', 'light_model');