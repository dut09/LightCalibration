%   Tao Du
%   taodu@stanford.edu
%   May 31, 2014

%   compute the light radiance of a 3d point p
%   p is a 3 by n vector
%   each colum represents a point
function [ radiance ] = comp_light_radiance( light_model, p )
    num = size(p, 2);
    %   compute the angle
    light_vector = p - light_model.light_pos * ones(1, num);
    len = sqrt(sum(light_vector.^2, 1));
    angle = acos(light_model.light_dir' * light_vector ./ len);
    %   compute z_dist
    z_dist = len .* cos(angle);
    radiance = interp_light_radiance(light_model, angle, z_dist);
end