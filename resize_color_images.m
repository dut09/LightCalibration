%   Tao Du
%   taodu@stanford.edu
%   Jun 2, 2014

%   this script will help resize the color images from the external DSLR
%   camera. 

%   get the number of color images. by default the extension for the DSLR
%   images is jpg

function [  ] = resize_color_images( folder )
    image_num = numel(dir([folder, '\color_*.jpg']));

    %   iteratively process all the jpg images
    for i = 1 : image_num
        image_name = [folder, '\color_', num2str(i, '%.4d'), '.jpg'];
        image = imread(image_name);
        %   backup the images
        imwrite(image, [folder, '\old_color_', num2str(i, '%.4d'), '.jpg']);
        image = imresize(image, 0.25, 'method', 'bilinear');
        imwrite(image, image_name);
    end
end


