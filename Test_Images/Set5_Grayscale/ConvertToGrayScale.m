function [ ] = ConvertToGrayScale( )
% Set5 source: https://github.com/titu1994/Image-Super-Resolution/tree/master/val_images/set5
sListing = dir;
N = length(sListing);
for ii = 1:N
    nameStr = sListing(ii).name;
    if((length(nameStr) < 4) || (~strcmp(nameStr(end-3:end), '.bmp')))
        continue;
    end
    I = imread(nameStr);
    I = rgb2gray(I);
    imwrite(I, nameStr);
end
end