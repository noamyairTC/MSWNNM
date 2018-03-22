function [ Z, Z_Weights ] = UpdateZ( z, knnIdx, refPtchIdx, currMu2, sAlgParam )
% Return Z, Z_Weights, where Z is the unweighted image and Z_Weights is the weights image

% Extract Data From struct
patchSize       = sAlgParam.patchSize;
downScaleFactor = sAlgParam.downScaleFactor;
imgHeight       = sAlgParam.imgHeight;
imgWidth        = sAlgParam.imgWidth;
imgDim          = sAlgParam.imgDim;

% Get Overlap Paches and Their Weights
numScales = length(downScaleFactor);
zPatches = GetPatches(z, patchSize);
if numScales == 1
    [overlapPtch, ptchWeights] = RunProjection(zPatches, knnIdx, refPtchIdx, currMu2, sAlgParam);
else
    cPatchesZ = cell(numScales, 1);
    for jj = 1:numScales
        coarserZ        = imresize(z, downScaleFactor(jj)); % Create coarser / down-scaled image
        cPatchesZ{jj}   = GetPatches(coarserZ, patchSize);
    end
    [overlapPtch, ptchWeights] = RunProjection_MS(cPatchesZ, knnIdx, refPtchIdx, currMu2, sAlgParam);
end

% Lay Back (overlap) Patches and Count The Weights
[Z, Z_Weights] = LayBackPatches(overlapPtch, ptchWeights, patchSize, imgHeight, imgWidth, imgDim);

end


function [ overlapPtch, ptchWeights ] = RunProjection( zPatches, knnIdx, refPtchIdx, currMu2, sAlgParam )

K               = sAlgParam.K;
patchSize       = sAlgParam.patchSize;
lambdaMu2Ratio  = sAlgParam.lambdaMu2Ratio;
mu2             = sAlgParam.mu2;
imgDim          = sAlgParam.imgDim;

overlapPtch     = zeros(size(zPatches));
ptchWeights     = zeros(size(zPatches));
lambda          = lambdaMu2Ratio * mu2; % Note: Use the inititial value of mu2 and not the value of mu2 after increasement currMu

for ii = 1:length(refPtchIdx) % Go over all KNN groups
    kNN = zPatches(:, knnIdx(1:K,ii),:); % Extract KNN group (non-local similar patches)
    projectedPatches = ProjectPatches(kNN, lambda, currMu2, imgDim); % Get group in low rank
    overlapPtch(:,knnIdx(1:K,ii),:) = overlapPtch(:,knnIdx(1:K,ii),:)+projectedPatches; % Lay back (overlap) processed patches
    ptchWeights(:,knnIdx(1:K,ii),:) = ptchWeights(:,knnIdx(1:K,ii),:)+ones(patchSize*patchSize,size(knnIdx(1:K,ii),1),imgDim); % Count overlap weights
end

end


function [ overlapPtch, ptchWeights ] = RunProjection_MS( cPatchesZ, knnIdx, refPtchIdx, currMu2, sAlgParam )

patchSize       = sAlgParam.patchSize;
lambdaMu2Ratio  = sAlgParam.lambdaMu2Ratio;
mu2             = sAlgParam.mu2;
imgDim          = sAlgParam.imgDim;
K               = sAlgParam.K;

numScales       = size(cPatchesZ,1);
zPatches        = cPatchesZ{1};

lambda          = lambdaMu2Ratio * mu2; % Note: Use the inititial value of mu2 and not the value of mu2 after increasement currMu
patchSize2      = patchSize * patchSize;
overlapPtch     = zeros(size(zPatches));
ptchWeights     = zeros(size(zPatches));

for ii = 1:length(refPtchIdx) % Go over all KNN groups
    
    % Extract KNN group (non-local similar patches)
    cnt = 0;
    kNN = NaN(patchSize2, K);
    for jj = 1:numScales
        vSimilarPatchesIndx = knnIdx(:,ii,jj);
        vSimilarPatchesIndx(isnan(vSimilarPatchesIndx)) = [];
        numKnnFromCurrImage = length(vSimilarPatchesIndx);
        kNN(:, cnt+(1:numKnnFromCurrImage)) = cPatchesZ{jj}(:, vSimilarPatchesIndx,:);
        cnt = cnt + numKnnFromCurrImage;
        if jj==1
            numPtchFromOrgImg = length(vSimilarPatchesIndx);
            vPatchesFromOrgImg = vSimilarPatchesIndx;
        end
    end
    
    % Get group in low rank
    projectedPatches    = ProjectPatches(kNN, lambda, currMu2, imgDim); % Get group in low rank
    projPtchFromOrgImg  = projectedPatches(:, 1:numPtchFromOrgImg); % Extract only patches from original image
    
    % Lay back (overlap) processed patches and count the weights
    overlapPtch(:,vPatchesFromOrgImg,:) = overlapPtch(:,vPatchesFromOrgImg,:) + projPtchFromOrgImg;
    ptchWeights(:,vPatchesFromOrgImg,:) = ptchWeights(:,vPatchesFromOrgImg,:) + ones(patchSize2, numPtchFromOrgImg, imgDim);
    
end

end


function [ projPatches ] = ProjectPatches( kNN, lambda, currMu2, imgDim )

[L, K, D] = size(kNN);
if(D == 3)
    kNN = [kNN(:,:,1); kNN(:,:,2); kNN(:,:,3)];
end

[U, SigmaY, V]  = svd(full(kNN),'econ');
TempC           = (2 * lambda * imgDim / currMu2) * sqrt(K);
[SigmaX, svp]   = SoftThreshold(SigmaY, TempC, eps);
projPatches     = U(:,1:svp) * diag(SigmaX) * V(:,1:svp)';

if(D == 3)
    projPatches = cat(3, projPatches(1:L,:,:), projPatches((L+1):(2*L),:,:), projPatches((2*L+1):(3*L),:,:));
end

end


function [ SigmaX, svp ] = SoftThreshold( SigmaY, C, oureps )

temp    = (SigmaY - oureps).^2 - 4 * (C - oureps * SigmaY);
ind     = find(temp > 0);
svp     = length(ind);
SigmaX  = max(SigmaY(ind) - oureps + sqrt(temp(ind)), 0) / 2;

end


function [ Z, Z_Weights ] = LayBackPatches( overlapPtch, ptchWeights, patchSize, imgHeight, imgWidth, imgDim )
% Z is the unweighted image and Z_Weights (the weights image

TempR       = imgHeight-patchSize+1;
TempC       = imgWidth-patchSize+1;
TempOffsetR = 1:TempR;
TempOffsetC = 1:TempC;

Z           = zeros(imgHeight,imgWidth,imgDim);
Z_Weights 	= zeros(imgHeight,imgWidth,imgDim);
k           = 0;
for ii = 1:patchSize
    for jj = 1:patchSize
        k = k + 1;
        rowIndices = TempOffsetR-1+ii;
        colIndices = TempOffsetC-1+jj;
        for dd = 1:imgDim
            Z(rowIndices,colIndices,dd) = Z(rowIndices,colIndices,dd) + reshape(overlapPtch(k,:,dd)', [TempR, TempC]);
            Z_Weights(rowIndices,colIndices,dd) = Z_Weights(rowIndices,colIndices,dd) + reshape(ptchWeights(k,:,dd)',  [TempR, TempC]);
        end
    end
end

% for ii = 1:patchSize
%     for jj = 1:patchSize
%         k = k + 1;
%         rowIndices = TempOffsetR-1+ii;
%         colIndices = TempOffsetC-1+jj;
%         Z(rowIndices,colIndices,:) = Z(rowIndices,colIndices,:) +...
%             reshape(squeeze(overlapPtch(k,:,:)).', [TempR, TempC, imgDim]);
%         Z_Weights(rowIndices,colIndices,:) = Z_Weights(rowIndices,colIndices,:) +...
%             reshape(squeeze(ptchWeights(k,:,:)).', [TempR, TempC, imgDim]);
%     end
% end

end