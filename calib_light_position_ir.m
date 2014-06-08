%   Tao Du
%   taodu@stanford.edu
%   Jun 8, 2014

%   calibrate the light position when using ir images
%   put depth and external color images in /Position

num = numel(dir('Position\*.png'));
center = [];
for i = 1 : num
    image = imread(['Position\color_', num2str(i, '%.4d'), '.jpg']);
    depth = imread(['Position\depth_', num2str(i, '%.4d'), '.png']);
    [n, d] = select_plane(depth, ...
        fc_left, cc_left, kc_left, alpha_c_left);
    %   plane equation: n * x + d = 0;
    %   plane equation in DSLR frame:
    %   suppose we have a point X in DSLR frame
    %   transform it back to PrimeSense frame:
    %   n' * (R'(X - T)) + d = 0;
    %   n' * R' * X - n' * R' * T + d = 0
    n2 = n' * R';
    d2 = -n' * R' * T + d;
    n = n2';
    d = d2;
    
    %   pick the center of the highlight area
    %center_2d = calib_highlight_center(image);
    %   pick the hightlight center manually
    imshow(image);
    center_2d = ginput();
    %   show the center in two color images
    figure; imshow(draw_cross(image, ...
        round(center_2d(1)), round(center_2d(2))));
    %   compute the 3d position
    center_3d = pixel_to_camera(double(center_2d)' - 1, 1,...
        fc_right, cc_right, kc_right, alpha_c_right);
    %   n * (t * center_3d) + d = 0
    t = -d / (n' * center_3d);
    center_3d = center_3d * t;
    center = [center center_3d];
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
light_dir = d;
if light_dir(3) < 0
    light_dir = -light_dir;
end
light_dir = light_dir / norm(light_dir);
%   any manual adjustment:
t = input('manually adjust the light position: input t:');
light_pos = light_pos + t * light_dir;
%   save the results, it has been tested!
save('light_info.mat', 'light_pos', 'light_dir');