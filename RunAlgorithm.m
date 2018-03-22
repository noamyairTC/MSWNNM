function [ sAlgParam ] = RunAlgorithm( y, noiseStd, H, algorithmPurpose, sAlgParam, mOrgImg )
% Run Restoration Algorithm
%
% Function inputs:
% y                 - The corrupted input image.
% noiseStd          - The STD of the noise.
% H                 - The blur convolution kernel or the inpainting mask.
% algorithmPurpose  - Algorithm purpose: 'deblurring' / 'inpainting' / 'denoising'.
% sAlgParam         - Structure of algorithm parameters. An optional parameter.
% mOrgImg           - The original image. An optional parameter. Used only
%                       to evaluate performance (not part of the algorithm).
%
% Function outputs:
% sAlgParam         - Structure of algorithm parameters, including the results.
%
% ---------------------------------------------------------------------------------

tic;

% If original image is given then run in debug mode
if nargin < 5, DebugModeFlag = false; sAlgParam = []; mOrgImg = zeros(1,1,size(y,3));
elseif nargin < 6, DebugModeFlag = false; mOrgImg = zeros(1,1,size(y,3));
else, DebugModeFlag = true; fprintf('Initial PSNR: %f [db].\n', CalcPsnr(y, mOrgImg));
end

% Set Algorithm Parameters
sAlgParam = SetAlgorithmParameters(y, noiseStd, H, algorithmPurpose, sAlgParam);

% Extract Data From struct (data that is relevant to this function)
algorithmPurpose    = sAlgParam.algorithmPurpose;
numItersMain        = sAlgParam.numItersMain;
numItersHQS         = sAlgParam.numItersHQS;
mu1                 = sAlgParam.mu1;
mu2                 = sAlgParam.mu2;
mu1IncrementRate    = sAlgParam.mu1IncrementRate;
mu2IncrementRate    = sAlgParam.mu2IncrementRate;

% Interpolate image in the case of inpainting
if strcmp(algorithmPurpose, 'inpainting')
    y = InterpolateImage(y, H);
    noiseStd = max(noiseStd, 1); % TO DO: Fix!!!
    disp('TO DO: Fix the way of handling the noise STD!!!');
end

% Pre-compute H.'*y and H.'*H in frequency domine
[HTy, fftHtH] = ComputeHTy(y, sAlgParam);

% Pre-find for each patch its neighbors (namely, all other patches inside its searching window)
[refPtchIdx, cCoarserImg] = FindNeighbors(y, sAlgParam);

% Main loop: repeating iteratively the update of x and KNN
x                   = InitX(y, HTy, fftHtH, sAlgParam, mOrgImg);    % Set initial value for x
vRunTime            = NaN(numItersMain+1, 1);                       % Run-time after each iteration
vRunTime(1)         = toc;                                          % Run-time after initialization
vMse                = NaN(1, numItersMain + 1);                     % MSE after each iteration
vMse(1)             = sum((x(:) - mOrgImg(:)).^ 2) / numel(x);      % MSE after initialization
vIntermediateMse    = NaN(1, numItersMain*numItersHQS + 1);         % MSE after each inner-iteration
vIntermediateMse(1) = vMse(1);                                      % MSE after initialization
for currIterNumMain = 1:numItersMain
    
    % Update KNN
    % ------------
    knnIdx = GetKNN(x, refPtchIdx, cCoarserImg, sAlgParam);
    
    % Update x
    % ------------
    % Inner HQS loop: repeating iteratively the update of Z, z and x
    z       = x;    % Set initial value for z
    currMu1 = mu1;  % Set initial value for mu1
    currMu2 = mu2;  % Set initial value for mu2
    for currIterHQS = 1:numItersHQS
        
        % Update Z
        % Comment for next line: Z is the unweighted image and Z_Weights is the weights image
        [Z, Z_Weights] = UpdateZ(z, knnIdx, refPtchIdx, currMu2, sAlgParam);
        
        % Update z
        z = ((currMu1 * x) + (currMu2 * Z)) ./ (currMu1 + (currMu2 * Z_Weights));
        
        % Update x
        q = HTy + (noiseStd^2 * currMu1 * z);
        if strcmp(algorithmPurpose, 'denoising')
            x = q ./ (1 + (noiseStd^2 * currMu1));
        elseif strcmp(algorithmPurpose, 'deblurring')
            x = real(ifft2(fft2(q) ./ (fftHtH + (noiseStd^2 * currMu1))));
        elseif strcmp(algorithmPurpose, 'inpainting')
            x = q ./ (H + (noiseStd^2 * currMu1));
        else
            error('Wrong ''algorithmPurpose'' value');
        end
        
        % Increase mu1 and mu2
        currMu1 = currMu1 * mu1IncrementRate;
        currMu2 = currMu2 * mu2IncrementRate;
        
        % In the case of inpainting with no noise, keep original pixels
        if strcmp(algorithmPurpose, 'inpainting') && sAlgParam.noiseStd == 0
            Hrep = repmat(H,1,1,sAlgParam.imgDim);
            x = y.*Hrep + x.*(1-Hrep);
            z = y.*Hrep + z.*(1-Hrep);
        end
        
        % If debug mode -> Calculate intermediate MSE at the end of each inner HQS iteration
        if DebugModeFlag, vIntermediateMse((currIterNumMain-1)*numItersHQS + currIterHQS+1) =...
                sum((x(:) - mOrgImg(:)).^2)/numel(x); end
        
    end
    
    % Store and print to command window some performance analysis data (not part of the algorithm)
    vRunTime(currIterNumMain+1) = toc;
    if DebugModeFlag % If debug mode -> Calculate MSE at the end of each iteration
        vMse(currIterNumMain+1) = mean((x(:)-mOrgImg(:)).^2);
        fprintf('Iteration %d out of %d.   PSNR: %f [db].   Total run-time: %d [sec].\n',...
            currIterNumMain, numItersMain, CalcPsnr(x, mOrgImg), round(vRunTime(currIterNumMain+1)));
    else
        fprintf('Iteration %d out of %d.   Total run-time: %d [sec].\n',...
            currIterNumMain, numItersMain, round(vRunTime(currIterNumMain+1)));
    end
    
end

% Print to command window the final PSNR
if DebugModeFlag, fprintf('Final PSNR: %f [db].\n', CalcPsnr(x, mOrgImg)); end

% Add results to 'sAlgParam' structure
sResults.mCorruptedImage    = y;
sResults.mRestoredImage     = x;
sResults.vRunTime           = vRunTime;
sResults.vMse               = vMse;
sResults.vIntermediateMse   = vIntermediateMse;
sResults.numMainIters       = currIterNumMain;
sResults.runTime            = toc;
sAlgParam.sResults          = sResults;

end


function [ HTy, fftHtH ] = ComputeHTy( y, sAlgParam )
% Compute H.'*y, and H.'*H in frequency domine of deblurring case.
% H is the blur convolution kernel on "deblurring", and the inpainting mask "inpainting".

% Extract Data From struct
algorithmPurpose    = sAlgParam.algorithmPurpose;
imgHeight           = sAlgParam.imgHeight;
imgWidth            = sAlgParam.imgWidth;
H                   = sAlgParam.H;
% --------------------------------------------------

% Compute H in frequency domine (fftH)
% If Image Processing Toolbox is available then fftHtH = abs(psf2otf(H,[imgHeight,imgWidth])).^2
[kerH, kerW]= size(H);
padH        = zeros(imgHeight, imgWidth);
padH(1:kerH, 1:kerW) = H;
padH        = circshift(padH, -round([(kerH - 1) / 2, (kerW - 1) / 2])); % pad PSF
fftH        = fft2(padH);
fftHtH      = abs(fftH).^2; % H.'*H in frequency domine

if strcmp(algorithmPurpose, 'denoising')
    HTy = y;
elseif strcmp(algorithmPurpose, 'deblurring')
    HTy = imfilter(y, rot90(H, 2), 'circular', 'conv'); % = ifft2(conj(H_FFT).*fft2(y))
elseif strcmp(algorithmPurpose, 'inpainting')
    y   = InterpolateImage(y, H);
    HTy = H .* y; % HT = H
else
    error('Wrong ''algorithmPurpose'' value');
end

end


function [ refPtchIdx, cCoarserImg ] = FindNeighbors( y, sAlgParam )
% Find for each patch its neighbors.
% Namely, for each patch find all the other patches inside its searching window.

% Extract Data From struct
patchSize           = sAlgParam.patchSize;
stepSize            = sAlgParam.stepSize;
searchWinSize       = sAlgParam.searchWinSize;
winSizeMethod       = sAlgParam.winSizeMethod;
downScaleFactor     = sAlgParam.downScaleFactor;
% ------------------------------------------------

numScales = length(downScaleFactor);

if strcmp(winSizeMethod, 'ChangeWithScale')
    vSearchWinSize = ceil(searchWinSize .* downScaleFactor);
elseif strcmp(winSizeMethod, 'Fixed')
    vSearchWinSize = searchWinSize .* ones(numScales, 1);
    vStepSize = ones(numScales, 1);
    vStepSize(1) = stepSize;
else
    error('Parameter ''winSizeMethod'' has invalid value.');
end

cCoarserImg = cell(numScales,4); % dim1 - mNeighbors , dim2 - neighborsNum , dim3 - imgHeight , dim4 - imgWidth
for ii = 1:numScales
    mCoarserImg = imresize(y(:,:,1), downScaleFactor(ii));
    [coarserImgHeight, coarserImgWidth, ~] = size(mCoarserImg); % TO DO: calc coarser image size without using y
    [mCoarserNeighbors, coarserNeighborsNum, currRefPtchIdx] = GetNeighborIndex(coarserImgHeight,...
        coarserImgWidth, vStepSize(ii), vSearchWinSize(ii), patchSize);
    cCoarserImg{ii,1} = mCoarserNeighbors;
    cCoarserImg{ii,2} = coarserNeighborsNum;
    cCoarserImg{ii,3} = coarserImgHeight;
    cCoarserImg{ii,4} = coarserImgWidth;
    if ii==1, refPtchIdx = currRefPtchIdx; end % Take refPtchIdx from original scale
end

end


function [ mCorruptedImage ] = InterpolateImage( mCorruptedImage, mMask )
% Delaunay triangulation based interpolation

mMask           = ~mMask;
[x, y]          = find(mMask == 0);
[M, N, D]       = size(mCorruptedImage);
[x1, y1]        = meshgrid(1:M, 1:N);
mCorruptedImage = griddata(x, y, mCorruptedImage(mMask == 0), x1, y1);
mCorruptedImage = mCorruptedImage.';
mCorruptedImage(isnan(mCorruptedImage)) = 128;

if D==3
    disp('Current implementation does not support 3D images');
    keyboard;
end

end
