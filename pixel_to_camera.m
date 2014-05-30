%   Tao Du
%   taodu@stanford.edu
%   May 29, 2014

%   Xp can be a matrix with each column represents a point
%   z is a row vector
function [ XXc ] = pixel_to_camera( Xp, z, fc, cc, kc, alpha_c )
Xn = normalize(Xp, fc, cc, kc, alpha_c);
[~, num] = size(Xn);
XXc = [Xn; ones(1, num)] .* [z; z; z];
end
    
