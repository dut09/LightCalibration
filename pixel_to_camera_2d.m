%   Tao Du
%   taodu@stanford.edu
%   May 29, 2014

%   compute the XXc for all the pixel in a height * width image
%   z is a height * width matrix
function [ XXc ] = pixel_to_camera_2d(z, fc, cc, kc, alpha_c )
%   build Xp
[height, width] = size(z);
Xp = zeros(2, height * width);
Xp(1, :) = reshape(ones(height, 1) * (0 : width - 1), 1, height * width);
Xp(2, :) = reshape((ones(width, 1) * (0 : height - 1))', 1, height * width);
z = reshape(z, 1, height * width);
Xn = normalize(Xp, fc, cc, kc, alpha_c);
[~, num] = size(Xn);
XXc2D = [Xn; ones(1, num)] .* [z; z; z];
XXc = zeros(height, width, 3);
XXc(:, :, 1) = reshape(XXc2D(1, :), height, width);
XXc(:, :, 2) = reshape(XXc2D(2, :), height, width);
XXc(:, :, 3) = reshape(XXc2D(3, :), height, width);
end 