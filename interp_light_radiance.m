%   Tao Du
%   taodu@stanford.edu
%   June 1, 2014

%   the core function in comp_light_radiance
function [ radiance ] = interp_light_radiance( light_model, angle, z_dist )
    num = length(angle);
    radiance = zeros(3, num);
    paras = light_model.paras;
    for channel = 1 : 3
        a = paras(1, channel);
        b = paras(2, channel);
        c = paras(3, channel);
        radiance(channel, :) = a * exp(-angle.^2/b) .* z_dist.^c;
    end
    invalid_id = angle <= light_model.min_angle ...
        | angle >= light_model.max_angle ...
        | z_dist <= light_model.min_z_dist ...
        | z_dist >= light_model.max_z_dist;
    %   clear those invalid points
    radiance(:, invalid_id) = 0;

%   deprecated
%{
    num = length(angle);
    invalid_id = angle <= light_model.min_angle ...
        | angle >= light_model.max_angle ...
        | z_dist <= light_model.min_z_dist ...
        | z_dist >= light_model.max_z_dist;
    
    %   compute the radiance
    angle_step = (light_model.max_angle - light_model.min_angle) ...
        / light_model.n_bin_angle;
    z_dist_step = (light_model.max_z_dist - light_model.min_z_dist) ...
        / light_model.n_bin_z_dist;
    angle_samples = light_model.min_angle + ...
        ((1 : light_model.n_bin_angle) - 0.5) * angle_step;
    z_dist_samples = light_model.min_z_dist + ...
        ((1 : light_model.n_bin_z_dist) - 0.5) * z_dist_step;
    [X, Y] = meshgrid(z_dist_samples, angle_samples);
    radiance = zeros(3, num);
    for channel = 1 : 3
        radiance(channel,:)=interp2(X,Y,light_model.radiance(:,:,channel), ...
            z_dist, angle, 'linear');
    end
    %   clear those invalid points
    radiance(:, invalid_id) = 0;
%}
end

