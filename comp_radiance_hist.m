%   Tao Du
%   taodu@stanford.edu
%   Jun 1, 2014

%   compute the histogram of a dng image
%   by default I use 100 bins
function [  ] = comp_radiance_hist( image )
    r = image(:, :, 1);
    figure('name', 'red channel');hist(r(:), 100);
    g = image(:, :, 2);
    figure('name', 'green channel');hist(g(:), 100);
    b = image(:, :, 3);
    figure('name', 'blue channel');hist(b(:), 100);
end

