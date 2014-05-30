%   Tao Du
%   taodo@stanford.edu
%   May 30, 2014

%   input: a 24 bit color image
%   output: the pixel position of the center of the highlight area
%   the range of p is [1, width] x [1, height]
function [ p ] = calib_highlight_center( image )
    [height, width, ~] = size(image);
    [X, Y] = meshgrid(1 : width, 1 : height);
    gray_image = rgb2gray(image);
    max_intensity = max(max(gray_image));
    mask = gray_image > 0.8 * max_intensity;
    count = sum(sum(mask));
    p(1) = sum(sum(X .* mask)) / count;
    p(2) = sum(sum(Y .* mask)) / count;
end

