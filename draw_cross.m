%   Tao Du
%   taodu@stanford.edu
%   May 29, 2014

%   draw a cross at [px, py]
function [ image ] = draw_cross( image, px, py )
    [height, width, ~] = size(image);
    len = round(min(height, width) / 100);
    wid = round(len / 4);
    %   if out of bound, do not draw it
    if (px - len) < 1 || (px + len) > width ...
        || (py - len) < 1 || (py + len) > height
        return;
    end
    for h = py - wid : py + wid
        for w = px - len : px + len
            image(h, w, 1) = 255;
            image(h, w, 2) = 0;
            image(h, w, 3) = 0;
        end
    end
    for w = px - wid : px + wid
        for h = py - len : py + len
            image(h, w, 1) = 255;
            image(h, w, 2) = 0;
            image(h, w, 3) = 0;
        end
    end
end

