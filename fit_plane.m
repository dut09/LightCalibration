%   Tao Du
%   taodu@stanford.edu
%   May 30, 2014

%   fit a plane from a series of 3d points
%   input: a 3xn matrix, each column represents a single point
%   output: the plane equation: n * x + d = 0
function [ n, d ] = fit_plane( points )
    coeff = pca(points');
    n = coeff(:, 3);
    ave = mean(points, 2);
    %   plane equation:
    %   (x - ave) * n = 0
    d = -ave' * n;
end

