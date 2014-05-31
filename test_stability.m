%   Tao Du
%   taodu@stanford.edu
%   May 31, 2014

%   test whether your setting is stable
%   with exactly the same settings, take 3 images, compare their
%   differences

%   name the three images as stable_test_1.dng, stable_test_2.dng,
%   stable_test_3.dng, put them under the folder /Raw

%   change the number here if you want to use more/less images to test
img_num = 3;
bayer_type = 'rggb';

img = read_dng('Raw\stable_test_1.dng', bayer_type);
for i = 2 : img_num
    img2 = read_dng(['Raw\stable_test_', num2str(i, '%.1d'), '.dng'], ...
        bayer_type);
    %   compare img2 and img
    abs_diff = abs(img2 - img);
    figure('name', 'abs diff'); imshow(abs_diff);
    rel_diff = abs_diff ./ img;
    rel_diff(rel_diff == inf | isnan(rel_diff)) = 1;
    figure('name', 'rel diff'); imshow(rel_diff);
    img = img2;
end