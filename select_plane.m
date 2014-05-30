%   Tao Du
%   taodu@stanford.edu
%   May 30, 2014

%   pick a plane from the color image and depth image
%   input: depth image, fc, cc, kc, alpha_c
%   output: the plane equation: n*x+d=0
function [ n, d ] = select_plane( depth, fc, cc, kc, alpha_c)
    %   transform the depth
    depth = double(depth);
    %   get the height and width of the depth
    [height, width] = size(depth);
    %   show the depth
    figure;imshow(depth, [200, 3000]);colormap('jet');
    pixels = ginput();
    %   get the polygon
    pixels = [pixels; pixels(1, :)];
    [X, Y] = meshgrid(1:width, 1:height);
    XV = pixels(:,1);
    YV = pixels(:,2);
    mask = inpolygon(X, Y, XV, YV);
    %   uncomment this line if you want to verify the mask
    %   imshow(mask);
    
    %   collect the depth information
    %   filter the depth image
    p = pixel_to_camera_2d(depth, fc, cc, kc, alpha_c);
    points(:,:,1) = p(:,:,1).*mask;
    points(:,:,2) = p(:,:,2).*mask;
    points(:,:,3) = p(:,:,3).*mask;
    points = reshape(points, height * width, 3);
    %   filter out points with z = 0
    points(points(:, 3) == 0, :) = [];
    [n, d] = fit_plane(points');
    
    %   uncomment the following lines if you
    %   want to verify the plane is correct
    %   n'*(t * p) + d = 0;
    %{
    N(:,:,1) = ones(height, width) * n(1);
    %N(:,:,2) = ones(height, width) * n(2);
    N(:,:,3) = ones(height, width) * n(3);
    depth2 = -d ./ dot(N, p, 3) .* depth;
    depth2(depth2 == inf | isnan(depth2)) = 0;
    %   show the difference between the plane
    %   and the depth image
    mesh(double(depth - depth2).*mask);
    %}
end

