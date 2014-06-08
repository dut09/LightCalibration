%   Tao Du
%   taodu@stanford.edu
%   May 30, 2014

%   this function borrowed from Robert Summer's RAW guide here:
%   http://users.soe.ucsc.edu/~rcsumner/rawguide/RAWguide.pdf
%   very beautiful documentation, and I highly recommend it!

%   input: the dng image name, the bayer array type:
%   bayer_type can be one of the four: gbrg, grbg, bggr, rggb
%   output: image, in three channels, the range is [0, 1]
function [ image ] = read_dng( name, bayer_type )
   %    turn off the warning message, otherwise matlab will be very verbose
   %    and annoying
    warning off MATLAB:tifflib:TIFFReadDirectory:libraryWarning
    t = Tiff(name, 'r');
    offsets = getTag(t, 'SubIFD');
    setSubDirectory(t, offsets(1));
    raw = read(t);
    close(t);
    meta_info = imfinfo(name);
    
    %   crop to only valid pixels
    x_origin = meta_info.SubIFDs{1}.ActiveArea(2) + 1;
    width = meta_info.SubIFDs{1}.DefaultCropSize(1);
    y_origin = meta_info.SubIFDs{1}.ActiveArea(1) + 1;
    height = meta_info.SubIFDs{1}.DefaultCropSize(2);
    raw = double(raw(y_origin:y_origin+height-1,x_origin:x_origin+width-1));
    
    %   linearization
    if isfield(meta_info.SubIFDs{1}, 'LinearizationTable')
        ltab = meta_info.SubIFDs{1}.LinearizationTable;
        raw = ltab(raw + 1);
    end
    
    %   black level and white level in DNG
    black = meta_info.SubIFDs{1}.BlackLevel(1);
    saturation = meta_info.SubIFDs{1}.WhiteLevel;
    disp('saturation: ');
    disp(saturation);
    if black ~= 0
        disp('warning: black level is not zero!');
    end
    lin_bayer = (raw - black)/(saturation - black);
    lin_bayer = max(0, min(lin_bayer, 1));
    clear raw
    
    %   demosaicing
    temp = uint16(lin_bayer * 2^16);
    image = double(demosaic(temp, bayer_type)) / 65535;
end

