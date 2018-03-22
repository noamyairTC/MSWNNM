function [ xPatches ] = GetPatches( x, patchSize )

[imgHeight, imgWidth, imgDim] = size(x);

numPtcInImg = (imgHeight - patchSize + 1)*(imgWidth - patchSize + 1); % Total patches number in the image
xPatches    = zeros(patchSize*patchSize, numPtcInImg, imgDim, 'single');
cnt         = 0;
for ii = 1:patchSize
    for jj = 1:patchSize
        cnt = cnt+1;
        patchesBlock        = x(ii:end-patchSize+ii,jj:end-patchSize+jj,:);
        [a,b,~]             = size(patchesBlock);
        xPatches(cnt,:,:)   = squeeze(reshape(patchesBlock, a*b, [], imgDim));
    end
end

end