function [ ] = DisplayResults( sAlgParam, sSimParam )

% Extract Data From struct
mOrgImg             = sSimParam.mOrgImg;
mCorruptedImage     = sSimParam.mCorruptedImage;
algorithmPurpose    = sAlgParam.algorithmPurpose;
numItersMain        = sAlgParam.numItersMain;
numItersHQS         = sAlgParam.numItersHQS;
sResults            = sAlgParam.sResults;
imgHeight           = sAlgParam.imgHeight;
imgWidth            = sAlgParam.imgWidth;
imgDim              = sAlgParam.imgDim;
initType            = sAlgParam.initType;
mRestoredImage      = sResults.mRestoredImage;
numMainIters        = sResults.numMainIters;
vMse                = sResults.vMse;
vIntermediateMse    = sResults.vIntermediateMse;
runTime             = sResults.runTime;
vRunTime            = sResults.vRunTime;
numIters            = numItersMain;
numInnerIters       = numItersHQS;
% --------------------------------------------------

% Get PSNR
initialPsnr             = CalcPsnr(mCorruptedImage, mOrgImg);
finalPsnr               = CalcPsnr(mRestoredImage, mOrgImg);
vPsnr                   = 10*log10((255^2) ./ (vMse));
vIntermediatePsnr       = 10*log10((255^2) ./ (vIntermediateMse));
vPsnrPad                = [vPsnr; NaN(numInnerIters-1, length(vPsnr))];
vPsnrPad                = vPsnrPad(1:(end-numInnerIters+1)).';

% Get details in string text
averageRunTimeMinutes       = round(runTime / 60);
singleIterAverageRunTime    = mean(diff(vRunTime));

if strcmp(algorithmPurpose, 'deblurring')
    corruptionType = ['Kernel File Name: ',  strrep(sSimParam.kernelName, '_', ' ')];
elseif strcmp(algorithmPurpose, 'inpainting')
    corruptionType = ['Missing Data Ratio: ', num2str(sSimParam.missingDataRatio)];
elseif strcmp(algorithmPurpose, 'denoising')
    corruptionType = ['Noise STD: ', num2str(sSimParam.noiseStd)];
else
    error('Wrong ''algorithmPurpose'' value');
end

if initType == 1 % 1 - simple (x=y), 2 - Using Wiener Filter , 3 - PPP with WNNM denoiser
    initStr = 'Simple (x=y)';
elseif initType == 2
    initStr = 'Wiener Filter';
elseif initType == 3
    initStr = 'PPP with WNNM denoiser';
elseif initType == 4
    initStr = 'IRCNN';
else
    initStr = '???';
end

detailsStr1 = {...
    'Performance & Simulation Details:',...
    '-----------------------------------------------------',...
    ['Restored Image PSNR: ',       num2str(finalPsnr), ' [db]'],...
    ['Corrupted Image PSNR: ',      num2str(initialPsnr), ' [db]'],...
    ['Run Time: ',                  num2str(averageRunTimeMinutes), ' [minutes]'],...
    ['Single Iter. Av. Run-Time: ', num2str(singleIterAverageRunTime), ' [sec]'],...
    ['Algorithm Purpose: ',         algorithmPurpose],...
    ['Image File Name: ',           sSimParam.imageFileName],...
    ['Image Size: ',                num2str(imgHeight),'x',num2str(imgWidth),'x',num2str(imgDim),' [pixels]'],...
    corruptionType,...
    ['Noise STD: ',                 num2str(sSimParam.noiseStd)],...
    '',...
    };

detailsStr2 = {...
    'Algorithm Details:',...
    '-----------------------------------------------------',...
    ['Main & inner Num. Iter. = ',  ['[', num2str(numMainIters), ', ', num2str(numInnerIters), ']']],...
    ['Scales: ',                    num2str(sAlgParam.downScaleFactor)],...
    ['Coarser Image Win. Method = ',sAlgParam.winSizeMethod],...
    ['Init. & Final K = ',          ['[', num2str(sAlgParam.initK), ', ', num2str(sAlgParam.K), ']']],...
    ['Patch Size = ',               num2str(sAlgParam.patchSize), 'x', num2str(sAlgParam.patchSize), ' [pixels]'],...
    ['[\lambda, \mu1, \mu2] = ',    ['[', num2str(sAlgParam.lambdaMu2Ratio * sAlgParam.mu2 * 1e3), ', ',...
                                    num2str(sAlgParam.mu1 * 1e3), ', ', num2str(sAlgParam.mu2 * 1e3), '] [milli]']],...
    ['[\mu1,\mu2] Increment Rate = ',['[', num2str(sAlgParam.mu1IncrementRate), ', ', num2str(sAlgParam.mu2IncrementRate), ']']],...
    ['Step Size = ',                num2str(sAlgParam.stepSize)],...
    ['x Initialization Type: ',     initStr],...
    '',...
    };

% Plot figures
figure;
subplot(2, 3, 1);
imshow(uint8(mCorruptedImage));
title(['Corrupted Image. PSNR: ', num2str(round(initialPsnr, 2))]);

subplot(2, 3, 2);
imshow(uint8(mRestoredImage));
title(['Restored Image. PSNR: ', num2str(round(finalPsnr,2))]);

subplot(2, 3, 3);
imshow(uint8(mOrgImg));
title('Original Image');

subplot(2, 3, 4);
plot((0:numIters*numInnerIters)./numInnerIters, vIntermediatePsnr, 'LineWidth', 0.3, 'color', [0.6 0.8 0.6]);
hold on;
plot((0:numIters*numInnerIters)./numInnerIters, vPsnrPad, '.', 'MarkerSize', 20, 'color', [0 0.4 0.8]);
hold off;
grid('on');
title('Evolution of PSNR (dB)');
xlabel('Iteration Number');
ylabel('PSNR [db]');
xlim([0, numMainIters+1])

subplot(2, 3, [5, 6]);
title('Details');
text(0.05, 0.5, detailsStr1, 'FontSize', 10, 'HorizontalAlignment', 'left');
text(0.60, 0.5, detailsStr2, 'FontSize', 10, 'HorizontalAlignment', 'left');
set(gca,'YTick',[]);
set(gca,'XTick',[]);

if(~exist('ResultsFiles', 'dir')), mkdir('ResultsFiles'); end
savefig(['ResultsFiles/', sSimParam.imageFileName, '_Image_', datestr(now,'yyyy_mm_dd_HH_MM_SS'),'.fig']);

end
