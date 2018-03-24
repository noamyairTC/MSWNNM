function [ sSimData ] = RunMe( )
% --------------------------------------------------------------------------------
% This code demonstrate the image restoration experiments conducted in
% N. Yair and T. Michaeli, "Multi-Scale Weighted Nuclear Norm Image Restoration",
% Conference on Computer Vision and Pattern Recognition (CVPR 2018).
% https://tomer.net.technion.ac.il/files/2018/03/MultiScaleWNNM_CVPR18.pdf
% To reproduce the paper results, follow the instruction in the 'ReadMe.md' file.
% 
% This function simulates the restoration algorithm, as it:
% - Create a corrupted image.
% - Run the restoration algorithm on the corrupted image.
% - Display results.
% 
% At the end of the simulation:
% - A results figure will be displayed and saved in 'ResultsFiles' folder.
% - The 'sSimData' output parameter will contain all simulation information.
% 
% The initialization of this algorithm is based on IRCNN:
% Kai Zhang et al. "Learning Deep CNN Denoiser Prior for Image Restoration",
% Conference on Computer Vision and Pattern Recognition (CVPR) 2018.
% The IRCNN code is available in https://github.com/cszn/ircnn.
% 
% Please feel free to contact me at noamyair10.tc@gmail.com.
% --------------------------------------------------------------------------------

% Add all subfolders to path
addpath(genpath(pwd));

% Set Simulation Parameters (noise level, blur-kernel / mask etc.)
sSimParam = SetSimulationParams();

% Get Original And Corrupted Images
sSimParam = GetOriginalAndCorruptedImages(sSimParam);

% Run Restoration Algorithm
fprintf(GetTextToDisp(sSimParam));
sAlgParam = RunAlgorithm(sSimParam.mCorruptedImage, sSimParam.noiseStd,...
    sSimParam.H, sSimParam.algorithmPurpose, [], sSimParam.mOrgImg);

% Display Results
DisplayResults(sAlgParam, sSimParam);

% Gather Simulation Data
sSimData.sAlgParam = sAlgParam;
sSimData.sSimParam = sSimParam;

end


function [ sSimParam ] = SetSimulationParams( )
% Choose algorithm purpose, noise level, blur-kernel / mask etc.

% Choose algorithm purpose
sSimParam.algorithmPurpose = 'deblurring'; % Options: deblurring , inpainting

% Choose blur-kernel / mask
if strcmp(sSimParam.algorithmPurpose,'deblurring')
    
    % Choose noise level
    sSimParam.noiseStd = 2; % Define the noise STD
    
    % Define blur kernel type
    sSimParam.kernelName = 'Gaussian'; % Options: 'Gaussian' , 'Uniform' or 'Delta'
    
    % Create blur convolution kernel H according to the chosen type
    if strcmp(sSimParam.kernelName, 'Gaussian')
        sSimParam.H = fspecial(sSimParam.kernelName, 25, 1.6);
    elseif strcmp(sSimParam.kernelName, 'Uniform')
        H = ones(9);
        sSimParam.H = H ./ sum(H(:));
    elseif strcmp(sSimParam.kernelName, 'Delta')
        sSimParam.H = 1;
    else
        error('Parameret ''kernelName'' is not supported')
    end
    
elseif strcmp(sSimParam.algorithmPurpose,'inpainting')
    
    % Choose noise level
    sSimParam.noiseStd = 0; % Define the noise STD
    
    % Define the ratio of the random missing pixels
    sSimParam.missingDataRatio = 0.5;
    
else
    
    error('Wrong ''algorithmPurpose'' value');
    
end

% Fix Random Seed
randn('seed', 0);   % Fix random seed for generated noise
rand('seed', 0);    % Fix random seed for inpainting mask

% Choose image-resize factor (in case you want to get results faster, work on a smaller image...)
sSimParam.imageResizeFacor = 1; % Choose '1' to use original size image

% Choose Image
sSimParam.imageFileName = 'Lena.tif';

end


function [ sSimParam ] = GetOriginalAndCorruptedImages( sSimParam )

% Load Original Image
ext =  {'','.tif','.jpg','.png','.bmp'};
imageFileName = sSimParam.imageFileName;
imgFound = false;
for ii = 1:length(ext)
    if exist([imageFileName, ext{ii}], 'file')
        mOrgImg = double(imread([imageFileName, ext{ii}]));
        imgFound = true;
        break;
    end
end
if ~imgFound
    mOrgImg = double(imread(imageFileName));
end

% Resize (usually down-scale) Original Image (for faster simulation)
mOrgImg = imresize(mOrgImg, sSimParam.imageResizeFacor);
sSimParam.mOrgImg = mOrgImg;

% Create Corrupted Image
mOrgImg = sSimParam.mOrgImg;
if strcmp(sSimParam.algorithmPurpose, 'deblurring')
    % H is a blur convolution kernel
    mCorruptedImage = imfilter(mOrgImg, sSimParam.H, 'circular', 'conv');
elseif strcmp(sSimParam.algorithmPurpose, 'inpainting')
    sSimParam.H = (rand(size(mOrgImg)) > sSimParam.missingDataRatio); % Create inpainting mask
    mCorruptedImage = mOrgImg .* sSimParam.H; % Apply mask on original image
else
    mCorruptedImage = mOrgImg; % Do not degrade image
end
mCorruptedImage = mCorruptedImage + (sSimParam.noiseStd * randn(size(mCorruptedImage))); % Add noise
sSimParam.mCorruptedImage = mCorruptedImage;

end


function [ txtStr ] = GetTextToDisp( sSimParam )

algorithmPurpose = sSimParam.algorithmPurpose;
noiseStdStr = num2str(sSimParam.noiseStd);
txtStr1 = ['Run ', algorithmPurpose, ' on image ''', sSimParam.imageFileName,''' ('];
if strcmp(algorithmPurpose,'denoising')
    txtStr2 = ['noise STD ', noiseStdStr,').\n'];
    txtStr = [txtStr1, txtStr2];
elseif strcmp(algorithmPurpose,'deblurring')
    txtStr2 = [sSimParam.kernelName,' blur kernel, noise STD ', noiseStdStr,').\n'];
    txtStr = [txtStr1, txtStr2];
elseif strcmp(algorithmPurpose,'inpainting')
    txtStr2 = ['missing data ratio ', num2str(sSimParam.missingDataRatio),' and noise STD ', noiseStdStr,').\n'];
    txtStr = [txtStr1, txtStr2];
else
    error('Wrong ''algorithmPurpose'' value');
end

end
