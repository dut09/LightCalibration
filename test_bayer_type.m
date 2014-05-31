%   Tao Du
%   taodu@stanford.edu
%   May 30, 2014

%   test the bayer type of the dng image
%   please put bayer_test.dng under the folder /Raw
%   it seems dng uses rggb as its bayer type

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
