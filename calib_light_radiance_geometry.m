%   Tao Du
%   taodu@stanford.edu
%   May 31, 2014

%   the geometry core function in calib_light_radiance
%   the input includes the raw image, the plane equation [n;d]
%   the light info [light_pos light_dir] and the normal matrix from the
%   DSLR camera
%   the output will be the angle between light vector and the light_dir
%   the z_dist,  and radiance in three channels
function [ angle, z_dist, radiance ] ...
    = calib_light_radiance_geometry( image, n, d, ...
    light_pos, light_dir, normals )

    [height, width, ~] = size(image);
    %   build a light dir matrix for future use
    DIR(:, :, 1) = ones(height, width) .* light_dir(1);
    DIR(:, :, 2) = ones(height, width) .* light_dir(2);
    DIR(:, :, 3) = ones(height, width) .* light_dir(3);
    
    %   compute the intersection points from normals to the plane
    %   n * (t * normals) + d = 0
    %   t = -d / (n * normals)
    N(:, :, 1) = ones(height, width) * n(1);
    N(:, :, 2) = ones(height, width) * n(2);
    N(:, :, 3) = ones(height, width) * n(3);
    t = -d ./ dot(N, normals, 3);
    %   intersection points
    light_vector = zeros(height, width, 3);
    for channel = 1 : 3
        light_vector(:, :, channel) = normals(:, :, channel) .* t ...
            - light_pos(channel);
    end    
    len = sqrt(sum(light_vector.^2, 3));
    %   compute the cosine for each light vector and the light dir
    cosine = dot(light_vector, DIR, 3) ./ len;
    %   compute the angle
    angle = acos(cosine);
    %   compute the projected distance for each light vector
    z_dist = len .* cosine;
    %   now compute the radiance
    cosine = abs(dot(light_vector, N, 3)) ./ len;
    radiance = zeros(height, width, 3);
    for channel = 1 : 3
        radiance(:, :, channel) = image(:, :, channel) ./ cosine;
    end
end

