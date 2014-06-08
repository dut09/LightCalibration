%   Tao Du
%   taodu@stanford.edu
%   Jun 1, 2014

%   compute the histogram of a dng image
%   by default I use 100 bins
function [  ] = comp_radiance_hist( image )
    r = image(:, :, 1);
    r = r(:);
    r(r == 0) = [];
    figure('name', 'red channel');hist(r, 100);
    g = image(:, :, 2);
    g = g(:);
    g(g == 0) = [];
    figure('name', 'green channel');hist(g, 100);
    b = image(:, :, 3);
    b = b(:);
    b(b == 0) = [];
    figure('name', 'blue channel');hist(b, 100);
end

