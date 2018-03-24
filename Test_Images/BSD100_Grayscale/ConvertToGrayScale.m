function [ ] = ConvertToGrayScale( )
sListing = dir;
N = length(sListing);
for ii = 1:N
    nameStr = sListing(ii).name;
    if((length(nameStr) < 4) || (~strcmp(nameStr(end-3:end), '.jpg')))
        continue;
    end
    I = imread(nameStr);
    if size(I, 3) ~= 1
        I = rgb2gray(I);
        imwrite(I, [nameStr(1:(end-4)),'_rgb2gray.png']);
        delete(nameStr);
    end
end
end