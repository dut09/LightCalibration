%   Tao Du
%   taodu@stanford.edu
%   May 30, 2014

%   init script
%   please run it at the beginning

%   add path
path(path, pwd);
path(path, [pwd, '\3rdparty\TOOLBOX_calib\']);
%   load calibration results
load('Calib_Results_stereo.mat');
