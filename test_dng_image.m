%   Tao Du
%   taodu@stanford.edu
%   May 30, 2014

%   this script does a couple of tests about the dng images
%   it will help you find the bayer type in the dng image, the proper
%   combination of iso/shutter speed/aperture in the experiment

%%  bayer test
%   test the bayer type of the dng image
%   please put bayer_test.dng under the folder /Raw
%   some bayer types:
%   Nikon D7000:        rggb
%   Nokia Lumia 1520:   gbrg

%   gbrg
image = read_dng('Raw/bayer_test.dng', 'gbrg');
figure('name', 'gbrg'); imshow((image).^(1/2.2));

%   grbg
image = read_dng('Raw/bayer_test.dng', 'grbg');
figure('name', 'grbg'); imshow((image).^(1/2.2));

%   bggr
image = read_dng('Raw/bayer_test.dng', 'bggr');
figure('name', 'bggr'); imshow((image).^(1/2.2));

%   rggb
image = read_dng('Raw/bayer_test.dng', 'rggb');
figure('name', 'rggb'); imshow((image).^(1/2.2));


%%  radiance histogram test
%   you will probably do this test multiple times
%   for a combination of iso/shutter speed/aperture, take a photo of the
%   gray board, use comp_radiance_hist to see the distribution of the
%   sensor data. In principle, if it uniformly distributes in [0, 1], then
%   this setting is good. If the data are too dark(clustered in [0, 0.3],
%   for example), then the noise will greatly affect the percision of the
%   data; on the other hand, if too many pixels are overexposured, we may
%   loss too much information.
%   
%   put rad_hist_test.dng under /Raw, then run the following line:

bayer_type = 'gbrg';
image = read_dng('Raw\rad_hist_test.dng', bayer_type);
[height, width, ~] = size(image);
figure;imshow(image);
pixels = ginput();
%   get the polygon
pixels = [pixels; pixels(1, :)];
[X, Y] = meshgrid(1:width, 1:height);
XV = pixels(:,1);
YV = pixels(:,2);
mask = inpolygon(X, Y, XV, YV);
for channel = 1 : 3
    image(:, :, channel) = image(:, :, channel).*mask;
end
comp_radiance_hist(image);

%%  black test
%   you will probably do this test multiple times
%   after you have decided the proper iso/shutter speed/aperture settings,
%   another thing that might ease your work is to decide whether your
%   enviromnent is completely dark. Otherwise every time you have to take
%   two images: with the light, without the light, and subtract the latter
%   from the former. Take an image when every light is turned off in your
%   room, name it as black_test.dng, and analyse its histogram. If they are
%   close to zero, then you can assure the enviromnent ligth won't affect
%   the results (at least obviously) when the point light is turned on.
bayer_type = 'gbrg';
comp_radiance_hist(read_dng('Raw\black_test.dng', bayer_type));

%%  stability test
%   test whether your setting is stable
%   with exactly the same settings, take 3 images, compare their
%   differences

%   name the three images as stable_test_1.dng, stable_test_2.dng,
%   stable_test_3.dng, put them under the folder /Raw

%   change the number here if you want to use more/less images to test
image_num = 3;
bayer_type = 'gbrg';

image = read_dng('Raw\stable_test_1.dng', bayer_type);
for i = 2 : image_num
    image2 = read_dng(['Raw\stable_test_', num2str(i, '%.1d'), '.dng'], ...
        bayer_type);
    %   compare img2 and img
    abs_diff = abs(image2 - image);
    figure('name', 'abs diff'); imshow(abs_diff);
    comp_radiance_hist(abs_diff);
    rel_diff = abs_diff ./ image;
    rel_diff(rel_diff == inf | isnan(rel_diff)) = 1;
    figure('name', 'rel diff'); imshow(rel_diff);
    comp_radiance_hist(rel_diff);
    image = image2;
end

%%  shutter speed test
%   test whether the radiance goes linearly with the shutter speed. This
%   might be helpful if we want to correct the overexposure problem.

%   take a series of images under different shutter speed, name them as
%   shutter_test_X.dng, where X = 1, 2, 3, ...

%   in our experiment we use 4. change this when necessary
image_num = 4;
bayer_type = 'rggb';

%   the correct shutter speed, you should know this value from the camera
shutter = [2; 5/3; 4/3; 1];
image = read_dng('Raw/shutter_test_1.dng', bayer_type);

for i = 2 : image_num
    image2 = read_dng(['Raw\shutter_test_', num2str(i, '%.1d'), '.dng'], ...
        bayer_type);
    comp_radiance_hist(image ./ image2);
end

