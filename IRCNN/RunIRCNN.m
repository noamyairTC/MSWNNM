function [ sAlgParam ] = RunIRCNN( y, noiseStd, H, algorithmPurpose, sAlgParam, mOrgImg )
% ----------------------------------------------------------------------------------------
% This code is heavily based on IRCNN:
% Kai Zhang et al. "Learning Deep CNN Denoiser Prior for Image Restoration",
% Conference on Computer Vision and Pattern Recognition (CVPR) 2018.
% Available in https://github.com/cszn/ircnn.
% 
% @inproceedings{zhang2017learning,
%   title={Learning Deep CNN Denoiser Prior for Image Restoration},
%   author={Zhang, Kai and Zuo, Wangmeng and Gu, Shuhang and Zhang, Lei},
%   booktitle={IEEE Conference on Computer Vision and Pattern Recognition},
%   year={2017}
% }
% ----------------------------------------------------------------------------------------

tic;

y = y ./ 255;
noiseStd = noiseStd ./ 255;

% If original image is given then run in debug mode
if nargin < 5, DebugModeFlag = false; sAlgParam = []; mOrgImg = zeros(1,1,size(y,3));
elseif nargin < 6, DebugModeFlag = false; mOrgImg = zeros(1,1,size(y,3));
else, DebugModeFlag = true; fprintf('Initial PSNR: %f [db].\n', CalcPsnr(y.*255, mOrgImg));
end

% Set Algorithm Parameters
sAlgParam = SetAlgorithmParameters(y, noiseStd, H, algorithmPurpose, sAlgParam);

useGPU = 0; % 0 or 1

folderModel = 'models';
totalIter   = 30; % default
lamda       = (noiseStd^2)/3; % default 3, ****** from {1 2 3 4} ******
modelSigma1 = 49; % default
modelSigma2 = 13; % ****** from {1 3 5 7 9 11 13 15} ******
modelSigmaS = logspace(log10(modelSigma1),log10(modelSigma2),totalIter);
rho         = noiseStd^2/((modelSigma1/255)^2);
ns          = min(25,max(ceil(modelSigmaS/2),1));
ns          = [ns(1)-1,ns];

[w,h,c]  = size(y);
V = psf2otf(H,[w,h]);
denominator = abs(V).^2;

if c>1
    denominator = repmat(denominator,[1,1,c]);
    V = repmat(V,[1,1,c]);
end
upperleft = conj(V).*fft2(y);

if c==1
    load(fullfile(folderModel,'modelgray.mat'));
elseif c==3
    load(fullfile(folderModel,'modelcolor.mat'));
end
z = single(y);
if useGPU
    z           = gpuArray(z);
    upperleft   = gpuArray(upperleft);
    denominator = gpuArray(denominator);
end

% Main loop: repeating iteratively the update of x and KNN
vRunTime    = NaN(totalIter,1);
vMse        = NaN(1, totalIter + 1);
vMse(1)     = mean((y(:) - mOrgImg(:)).^ 2);

for itern = 1:totalIter
    
    %%% step 1
    rho = lamda*255^2/(modelSigmaS(itern)^2);
    z = real(ifft2((upperleft + rho*fft2(z))./(denominator + rho)));
    if ns(itern+1)~=ns(itern)
        [net] = loadmodel(modelSigmaS(itern),CNNdenoiser);
        net = vl_simplenn_tidy(net);
        if useGPU
            net = vl_simplenn_move(net, 'gpu');
        end
    end
    
    %%% step 2
    res = vl_simplenn(net, z,[],[],'conserveMemory',true,'mode','test');
    residual = res(end).x;
    z = z - residual;
    
    % Store and print to command window some performance analysis data (not part of the algorithm)
    vRunTime(itern) = toc;
    if DebugModeFlag % If debug mode -> Calculate MSE at the end of each iteration
        vMse(itern+1) = mean((z(:).*255-mOrgImg(:)).^2);
        fprintf('IRCNN. Iter %d out of %d. PSNR: %f [db]. Run-time: %d [sec].\n',...
            itern, totalIter, CalcPsnr(z.*255, mOrgImg), round(vRunTime(itern)));
    else
        fprintf('Iteration %d out of %d.   Total run-time: %d [sec].\n',...
            itern, numItersWNNM, round(vRunTime(itern)));
    end
    
    
end

if useGPU
    x = im2double(gather(z)).*255;
else
    x = im2double(z).*255;
end

mRestoredImage = x;

toc;

% Print to command window the final PSNR
if DebugModeFlag, fprintf('Final IRCNN PSNR: %f [db].\n', CalcPsnr(mRestoredImage, mOrgImg)); end

% Add results to 'sAlgParam' structure
sResults.mCorruptedImage    = y;
sResults.mRestoredImage     = mRestoredImage;
sResults.x                  = x;
sResults.z                  = z;
sResults.vRunTime           = vRunTime;
sResults.vMse               = vMse;
sResults.numMainIters       = itern;
sResults.runTime            = toc;
sResults.vIntermediateMse   = [];
sAlgParam.sResults          = sResults;

end