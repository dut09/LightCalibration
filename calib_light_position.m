%   Tao Du
%   taodu@stanford.edu
%   May 30, 2014

%   calibrate the light position
%   put depth, color, color images in /Position

num = numel(dir('Position\*.png'));
center = [];
for i = 1 : num
    image = imread(['Position\color_', num2str(i, '%.4d'), '.bmp']);
    image2 = imread(['Position\color_', num2str(i, '%.4d'), '.jpg']);
    depth = imread(['Position\depth_', num2str(i, '%.4d'), '.png']);
    [n, d] = select_plane(depth, ...
        fc_left, cc_left, kc_left, alpha_c_left);
    %   pick the center of the highlight area
    center_2d = calib_highlight_center(image);
    %   show the center in two color images
    figure; imshow(draw_cross(image, ...
        round(center_2d(1)), round(center_2d(2))));
    %   compute the 3d position
    center_3d = pixel_to_camera(double(center_2d)' - 1, 1,...
        fc_left, cc_left, kc_left, alpha_c_left);
    %   n * (t * center_3d) + d = 0
    t = -d / (n' * center_3d);
    center_3d = center_3d * t;
    center = [center center_3d];
    %   project it back to DSLR color image
    XR = R * center_3d + T;
    %   project to image2
    pr = camera_to_pixel(XR, kc_right, KK_right);
    %   draw crosses on image2
    figure;imshow(draw_cross(image2, round(pr(1)) + 1, round(pr(2)) + 1));
end
%   plot the center
plot(center(3, :), center(2, :), 'r+', center(3, :), center(1, :), 'g+');
%   now, fit a line with center
ave = mean(center, 2);
coeff = pca(center');
d = coeff(:, 1);
%   the line: ave + t * d
%   light position: the position where z = 0
t = -ave(3) / d(3);
light_pos = ave + t * d;
%   tranform to DSLR camera space
light_pos = R * light_pos + T;
%   transform light_dir
light_dir = R * d;
if light_dir(3) < 0
    light_dir = -light_dir;
end
light_dir = light_dir / norm(light_dir);
%   save the results, it has been tested!
save('light_info.mat', 'light_pos', 'light_dir');