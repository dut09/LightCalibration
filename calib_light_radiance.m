%   Tao Du
%   taodu@stanford.edu
%   May 31, 2014

%   calibrate the radiance of our LED light
%   take depth/color/color images of a white, diffuse board, put them under
%   the folder /Radiance


%%  setting
%   bayer type
bayer_type = 'rggb';
%   configuration of the clampped bin in angle and theta
%   change them if necessary
min_angle = 0;
max_angle = pi / 6;
n_bin_angle = 50;
min_z_dist = 500;
max_z_dist = 2000;
n_bin_z_dist = 100;

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
[height, width, ~] = size(read_dng('Radiance\color_0001.dng', bayer_type));
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
    imshow(image.^(1/2.2)); %   show the image
    pixels = ginput();  %   select the valid region of the image
    close all;
    pixels = [pixels; pixels(1, :)];
    [X, Y] = meshgrid(1:width, 1:height);
    XV = pixels(:,1);
    YV = pixels(:,2);
    mask = inpolygon(X, Y, XV, YV); %   get the mask
    
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
%%  fit the model
%   now that we have gathered all the samples, we clamp them, and fit them
%   by the power law
load('light_radiance_sample.mat');
