function [ sAlgParam ] = SetAlgorithmParameters( mCorruptedImage, noiseStd, H, algorithmPurpose, sAlgParam )

% Set default algorithm parameters
sAlgParamDefault = SetDefaultAlgParams(mCorruptedImage, noiseStd, H, algorithmPurpose);

% Complete missing parameters with default parameters
cFieldnames = fieldnames(sAlgParamDefault);
for currFieldIdx = 1:length(cFieldnames)
    currFieldName = cFieldnames{currFieldIdx};
    if ~isfield(sAlgParam,currFieldName)
        sAlgParam.(currFieldName) = sAlgParamDefault.(currFieldName);
    end
end

end


function [ sAlgParam ] = SetDefaultAlgParams( mCorruptedImage, noiseStd, H, algorithmPurpose )

[imgHeight, imgWidth, imgDim] = size(mCorruptedImage);

if strcmp(algorithmPurpose,'denoising')
    sAlgParam.numItersMain      = 2;
    sAlgParam.mu1               = 1e3;      % Initial value
    sAlgParam.mu2               = 1e10;     % Initial value
    sAlgParam.lambdaMu2Ratio    = 5.5;      % lambdaMu2Ratio = lambda / mu2
    sAlgParam.H                 = [];       % Not in used on 'denoising' case
    sAlgParam.downScaleFactor   = [1];      % use [1] for no multiscale or [1, x, y...] for several scales
    sAlgParam.numItersHQS       = 1;
elseif strcmp(algorithmPurpose,'deblurring')
    sAlgParam.numItersMain      = 5;
    sAlgParam.mu1               = 1.5e-3;   % Initial value
    sAlgParam.mu2               = 1e-3;     % Initial value
    sAlgParam.lambdaMu2Ratio    = 10;       % lambdaMu2Ratio = lambda / mu2
    sAlgParam.H                 = H;        % H is the blur convolution kernel
    sAlgParam.downScaleFactor   = [1, 0.75]; % use [1] for no multiscale or [1, x, y...] for several scales
    sAlgParam.numItersHQS       = 5;
elseif strcmp(algorithmPurpose,'inpainting')
    missingDataRatio = mean(~H(:));
    if missingDataRatio <= 0.3
        sAlgParam.numItersMain  = 200;
    elseif missingDataRatio <= 0.55
        sAlgParam.numItersMain  = 300;
    else
        sAlgParam.numItersMain  = 400;
    end
    sAlgParam.mu1               = 5e-3;     % Initial value
    sAlgParam.mu2               = 5e-4;     % Initial value
    sAlgParam.lambdaMu2Ratio    = 15;       % lambdaMu2Ratio = lambda / mu2
    sAlgParam.H                 = H;        % H is the inpainting mask
    sAlgParam.downScaleFactor   = [1, 0.75]; % use [1] for no multiscale or [1, x, y...] for several scales
    sAlgParam.numItersHQS       = 5;
else
    error('Wrong ''algorithmPurpose'' value');
end

if noiseStd <= 20
    sAlgParam.patchSize = 6;
    sAlgParam.initK     = 60;
elseif noiseStd <= 40
    sAlgParam.patchSize = 7;
    sAlgParam.initK     = 80;
elseif noiseStd <= 60
    sAlgParam.patchSize = 8;
    sAlgParam.initK     = 110;
else
    sAlgParam.patchSize = 9;
    sAlgParam.initK     = 130;
end

sAlgParam.stepSize          = floor((sAlgParam.patchSize) / 2 - 1);
sAlgParam.algorithmPurpose  = algorithmPurpose;
sAlgParam.K                 = sAlgParam.initK;
sAlgParam.noiseStd          = noiseStd;
sAlgParam.imgHeight         = imgHeight;
sAlgParam.imgWidth          = imgWidth;
sAlgParam.imgDim            = imgDim;
sAlgParam.winSizeMethod     = 'Fixed'; % Fixed , ChangeWithScale
sAlgParam.mu1IncrementRate  = 2;
sAlgParam.mu2IncrementRate  = 1.5;
sAlgParam.searchWinSize     = 30;
sAlgParam.initType          = 3; % 1 - simple (x=y), 2 - Using Wiener Filter , 3 - IRCNN

% PPP-HQS with WNNM denoiser
sAlgParam.numItersWNNM      = 30;
sAlgParam.muWNNM            = 0.25 * 1e-3;
sAlgParam.lambdaWNNM        = 200 * sAlgParam.muWNNM * (noiseStd^2);
sAlgParam.muWNNMIncrementRate = 1.1;

end