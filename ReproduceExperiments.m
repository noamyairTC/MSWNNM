function [ cSimData ] = ReproduceExperiments( )
% --------------------------------------------------------------------------------
% This code reproduce the image restoration experiments conducted in
% N. Yair and T. Michaeli, "Multi-Scale Weighted Nuclear Norm Image Restoration",
% Conference on Computer Vision and Pattern Recognition (CVPR 2018).
% https://tomer.net.technion.ac.il/files/2018/03/MultiScaleWNNM_CVPR18.pdf
% Use the 'experimentType' parameter to choose what experiments to reproduce.
% Follow the instruction in the 'ReadMe.md' file for more details.
% 
% This function simulates the restoration algorithm, as it:
% - Create a corrupted image.
% - Run the restoration algorithm on the corrupted image.
% - Display and save results.
% - Repeat the steps above for all chosen images.
% 
% At the end of the simulation:
% - A results figures will be displayed and saved in 'ResultsFiles' folder.
% - The 'cSimData' output parameter will contain all simulation information.
% 
% The initialization of this algorithm is based on IRCNN:
% Kai Zhang et al. "Learning Deep CNN Denoiser Prior for Image Restoration",
% Conference on Computer Vision and Pattern Recognition (CVPR) 2018.
% The IRCNN code is available in https://github.com/cszn/ircnn.
% 
% Note: Running the algorithm with the naive initialization and for 300
% iterations might take a few hours for each images. Running with the IRCNN
% initialization and for 5 iterations will take a few minutes (about 5 minutes,
% depends on the hardware). For a simple example use experimentType = 0. This
% will perform a deblurring example on the 'Lena' image with a Gaussian Blur
% and Noise STD 2 and will take about 5 minutes.
% 
% Please feel free to contact me at noamyair10.tc@gmail.com.
% --------------------------------------------------------------------------------

% --------------------------------
% Choose experiments to reproduce
% --------------------------------
experimentType = 0;
% if experimentType =  1: Table 1 - 1st exp: Debluring on 'set5' with Gauss Blur and Noise STD Sqrt(2)
% if experimentType =  2: Table 1 - 2st exp: Debluring on 'set5' with Gauss Blur and Noise STD 2
% if experimentType =  3: Table 1 - 3st exp: Debluring on 'set5' with uniform Blur and Noise STD Sqrt(2)
% if experimentType =  4: Table 1 - 4st exp: Debluring on 'set5' with uniform Blur and Noise STD 2
% if experimentType =  5: Table 2 - 1st exp: Debluring on set NCSR with Gauss Blur and Noise STD Sqrt(2)
% if experimentType =  6: Table 2 - 2st exp: Debluring on set NCSR with Gauss Blur and Noise STD 2
% if experimentType =  7: Table 2 - 3st exp: Debluring on set NCSR with uniform Blur and Noise STD Sqrt(2)
% if experimentType =  8: Table 2 - 4st exp: Debluring on set NCSR with uniform Blur and Noise STD 2
% if experimentType =  9: Table 3 - 1st exp: Debluring on set BSD100 with Gauss Blur and Noise STD Sqrt(2)
% if experimentType = 10: Table 3 - 2st exp: Debluring on set BSD100 with Gauss Blur and Noise STD 2
% if experimentType = 11: Table 3 - 3st exp: Debluring on set BSD100 with uniform Blur and Noise STD Sqrt(2)
% if experimentType = 12: Table 3 - 4st exp: Debluring on set BSD100 with uniform Blur and Noise STD 2
% if experimentType = 13: Table 4 - 1st exp: Inpainting on set5 with 25% missing pixels
% if experimentType = 14: Table 4 - 1st exp: Inpainting on set5 with 50% missing pixels
% if experimentType = 15: Table 4 - 1st exp: Inpainting on set5 with 75% missing pixels
% if experimentType = 16: Table 5 - 1st exp: Inpainting on set NCSR with 25% missing pixels
% if experimentType = 17: Table 5 - 1st exp: Inpainting on set NCSR with 50% missing pixels
% if experimentType = 18: Table 5 - 1st exp: Inpainting on set NCSR with 75% missing pixels
% if experimentType = 19: Figure 2 - Debluring of image 3096 from set BSD100 with Gauss Blur and Noise STD 2
% if experimentType = 20: Figure 4 - Inpainting of image 'starfish' with 75% missing pixels
% If non of the above: Run some simple deblurring example ('Lena' image with Gauss Blur and Noise STD 2)

switch experimentType
    case(1)
        % Table 1 - 1st exp: Debluring on 'set5' with Gauss Blur and Noise STD Sqrt(2)
        sAlgParam.algorithmPurpose  = 'deblurring';
        sAlgParam.numItersMain      = 300;
        sAlgParam.initType          = 1; % Using naive initialization
        sSimParam.kernelName        = 'Gaussian';
        sSimParam.H                 = fspecial(sSimParam.kernelName, 25, 1.6);
        sSimParam.noiseStd          = sqrt(2);
        cImages = {'z_baby_GT_rgb2gray','z_bird_GT_rgb2gray','z_butterfly_GT_rgb2gray', 'z_head_GT_rgb2gray','z_woman_GT_rgb2gray'};
    case(2)
        % Table 1 - 2st exp: Debluring on 'set5' with Gauss Blur and Noise STD 2
        sAlgParam.algorithmPurpose  = 'deblurring';
        sAlgParam.numItersMain      = 300;
        sAlgParam.initType          = 1; % Using naive initialization
        sSimParam.kernelName        = 'Gaussian';
        sSimParam.H                 = fspecial(sSimParam.kernelName, 25, 1.6);
        sSimParam.noiseStd          = 2;
        cImages = {'z_baby_GT_rgb2gray','z_bird_GT_rgb2gray','z_butterfly_GT_rgb2gray', 'z_head_GT_rgb2gray','z_woman_GT_rgb2gray'};
    case(3)
        % Table 1 - 3st exp: Debluring on 'set5' with uniform Blur and Noise STD Sqrt(2)
        sAlgParam.algorithmPurpose  = 'deblurring';
        sAlgParam.numItersMain      = 300;
        sAlgParam.initType          = 1; % Using naive initialization
        sSimParam.kernelName        = 'Uniform';
        sSimParam.H                 = ones(9) ./ (9^2);
        sSimParam.noiseStd          = sqrt(2);
        cImages = {'z_baby_GT_rgb2gray','z_bird_GT_rgb2gray','z_butterfly_GT_rgb2gray', 'z_head_GT_rgb2gray','z_woman_GT_rgb2gray'};
    case(4)
        % Table 1 - 4st exp: Debluring on 'set5' with uniform Blur and Noise STD 2
        sAlgParam.algorithmPurpose  = 'deblurring';
        sAlgParam.numItersMain      = 300;
        sAlgParam.initType          = 1; % Using naive initialization
        sSimParam.kernelName        = 'Uniform';
        sSimParam.H                 = ones(9) ./ (9^2);
        sSimParam.noiseStd          = 2;
        cImages = {};
    case(5)
        % Table 2 - 1st exp: Debluring on set NCSR with Gauss Blur and Noise STD Sqrt(2)
        sAlgParam.algorithmPurpose  = 'deblurring';
        sAlgParam.numItersMain      = 300;
        sAlgParam.initType          = 1; % Using naive initialization
        sSimParam.kernelName        = 'Gaussian';
        sSimParam.H                 = fspecial(sSimParam.kernelName, 25, 1.6);
        sSimParam.noiseStd          = sqrt(2);
        cImages = {'Barbara';'Boats';'Cameraman';'House';'Leaves'; 'Lena';'Monarch';'Parrot';'Peppers';'Starfish'};
    case(6)
        % Table 2 - 2st exp: Debluring on set NCSR with Gauss Blur and Noise STD 2
        sAlgParam.algorithmPurpose  = 'deblurring';
        sAlgParam.numItersMain      = 300;
        sAlgParam.initType          = 1; % Using naive initialization
        sSimParam.kernelName        = 'Gaussian';
        sSimParam.H                 = fspecial(sSimParam.kernelName, 25, 1.6);
        sSimParam.noiseStd          = 2;
        cImages = {'Barbara';'Boats';'Cameraman';'House';'Leaves'; 'Lena';'Monarch';'Parrot';'Peppers';'Starfish'};
    case(7)
        % Table 2 - 3st exp: Debluring on set NCSR with uniform Blur and Noise STD Sqrt(2)
        sAlgParam.algorithmPurpose  = 'deblurring';
        sAlgParam.numItersMain      = 300;
        sAlgParam.initType          = 1; % Using naive initialization
        sSimParam.kernelName        = 'Uniform';
        sSimParam.H                 = ones(9) ./ (9^2);
        sSimParam.noiseStd          = sqrt(2);
        cImages = {'Barbara';'Boats';'Cameraman';'House';'Leaves'; 'Lena';'Monarch';'Parrot';'Peppers';'Starfish'};
    case(8)
        % Table 2 - 4st exp: Debluring on set NCSR with uniform Blur and Noise STD 2
        sAlgParam.algorithmPurpose  = 'deblurring';
        sAlgParam.numItersMain      = 300;
        sAlgParam.initType          = 1; % Using naive initialization
        sSimParam.kernelName        = 'Uniform';
        sSimParam.H                 = ones(9) ./ (9^2);
        sSimParam.noiseStd          = 2;
        cImages = {'Barbara';'Boats';'Cameraman';'House';'Leaves'; 'Lena';'Monarch';'Parrot';'Peppers';'Starfish'};
    case(9)
        % Table 3 - 1st exp: Debluring on set BSD100 with Gauss Blur and Noise STD Sqrt(2)
        sAlgParam.algorithmPurpose  = 'deblurring';
        sAlgParam.numItersMain      = 5;
        sAlgParam.initType          = 3; % Using IRCNN initialization
        sSimParam.kernelName        = 'Gaussian';
        sSimParam.H                 = fspecial(sSimParam.kernelName, 25, 1.6);
        sSimParam.noiseStd          = sqrt(2);
        cImages = {'101085_rgb2gray.png';'101087_rgb2gray.png';'102061_rgb2gray.png';'103070_rgb2gray.png';'105025_rgb2gray.png';'106024_rgb2gray.png';'108005_rgb2gray.png';'108070_rgb2gray.png';'108082_rgb2gray.png';'109053_rgb2gray.png';'119082_rgb2gray.png';'12084_rgb2gray.png';'123074_rgb2gray.png';'126007_rgb2gray.png';'130026_rgb2gray.png';'134035_rgb2gray.png';'14037_rgb2gray.png';'143090_rgb2gray.png';'145086_rgb2gray.png';'147091_rgb2gray.png';'148026_rgb2gray.png';'148089_rgb2gray.png';'156065_rgb2gray.png';'157055_rgb2gray.png';'159008_rgb2gray.png';'160068_rgb2gray.png';'16077_rgb2gray.png';'163085_rgb2gray.png';'167062_rgb2gray.png';'167083_rgb2gray.png';'170057_rgb2gray.png';'175032_rgb2gray.png';'175043_rgb2gray.png';'182053_rgb2gray.png';'189080_rgb2gray.png';'19021_rgb2gray.png';'196073_rgb2gray.png';'197017_rgb2gray.png';'208001_rgb2gray.png';'210088_rgb2gray.png';'21077_rgb2gray.png';'216081_rgb2gray.png';'219090_rgb2gray.png';'220075_rgb2gray.png';'223061_rgb2gray.png';'227092_rgb2gray.png';'229036_rgb2gray.png';'236037_rgb2gray.png';'24077_rgb2gray.png';'241004_rgb2gray.png';'241048_rgb2gray.png';'253027_rgb2gray.png';'253055_rgb2gray.png';'260058_rgb2gray.png';'271035_rgb2gray.png';'285079_rgb2gray.png';'291000_rgb2gray.png';'295087_rgb2gray.png';'296007_rgb2gray.png';'296059_rgb2gray.png';'299086_rgb2gray.png';'300091_rgb2gray.png';'302008_rgb2gray.png';'304034_rgb2gray.png';'304074_rgb2gray.png';'306005_rgb2gray.png';'3096_rgb2gray.png';'33039_rgb2gray.png';'351093_rgb2gray.png';'361010_rgb2gray.png';'37073_rgb2gray.png';'376043_rgb2gray.png';'38082_rgb2gray.png';'38092_rgb2gray.png';'385039_rgb2gray.png';'41033_rgb2gray.png';'41069_rgb2gray.png';'42012_rgb2gray.png';'42049_rgb2gray.png';'43074_rgb2gray.png';'45096_rgb2gray.png';'54082_rgb2gray.png';'55073_rgb2gray.png';'58060_rgb2gray.png';'62096_rgb2gray.png';'65033_rgb2gray.png';'66053_rgb2gray.png';'69015_rgb2gray.png';'69020_rgb2gray.png';'69040_rgb2gray.png';'76053_rgb2gray.png';'78004_rgb2gray.png';'8023_rgb2gray.png';'85048_rgb2gray.png';'86000_rgb2gray.png';'86016_rgb2gray.png';'86068_rgb2gray.png';'87046_rgb2gray.png';'89072_rgb2gray.png';'97033_rgb2gray.png'};
    case(10)
        % Table 3 - 2st exp: Debluring on set BSD100 with Gauss Blur and Noise STD 2
        sAlgParam.algorithmPurpose  = 'deblurring';
        sAlgParam.numItersMain      = 5;
        sAlgParam.initType          = 3; % Using IRCNN initialization
        sSimParam.kernelName        = 'Gaussian';
        sSimParam.H                 = fspecial(sSimParam.kernelName, 25, 1.6);
        sSimParam.noiseStd          = 2;
        cImages = {'101085_rgb2gray.png';'101087_rgb2gray.png';'102061_rgb2gray.png';'103070_rgb2gray.png';'105025_rgb2gray.png';'106024_rgb2gray.png';'108005_rgb2gray.png';'108070_rgb2gray.png';'108082_rgb2gray.png';'109053_rgb2gray.png';'119082_rgb2gray.png';'12084_rgb2gray.png';'123074_rgb2gray.png';'126007_rgb2gray.png';'130026_rgb2gray.png';'134035_rgb2gray.png';'14037_rgb2gray.png';'143090_rgb2gray.png';'145086_rgb2gray.png';'147091_rgb2gray.png';'148026_rgb2gray.png';'148089_rgb2gray.png';'156065_rgb2gray.png';'157055_rgb2gray.png';'159008_rgb2gray.png';'160068_rgb2gray.png';'16077_rgb2gray.png';'163085_rgb2gray.png';'167062_rgb2gray.png';'167083_rgb2gray.png';'170057_rgb2gray.png';'175032_rgb2gray.png';'175043_rgb2gray.png';'182053_rgb2gray.png';'189080_rgb2gray.png';'19021_rgb2gray.png';'196073_rgb2gray.png';'197017_rgb2gray.png';'208001_rgb2gray.png';'210088_rgb2gray.png';'21077_rgb2gray.png';'216081_rgb2gray.png';'219090_rgb2gray.png';'220075_rgb2gray.png';'223061_rgb2gray.png';'227092_rgb2gray.png';'229036_rgb2gray.png';'236037_rgb2gray.png';'24077_rgb2gray.png';'241004_rgb2gray.png';'241048_rgb2gray.png';'253027_rgb2gray.png';'253055_rgb2gray.png';'260058_rgb2gray.png';'271035_rgb2gray.png';'285079_rgb2gray.png';'291000_rgb2gray.png';'295087_rgb2gray.png';'296007_rgb2gray.png';'296059_rgb2gray.png';'299086_rgb2gray.png';'300091_rgb2gray.png';'302008_rgb2gray.png';'304034_rgb2gray.png';'304074_rgb2gray.png';'306005_rgb2gray.png';'3096_rgb2gray.png';'33039_rgb2gray.png';'351093_rgb2gray.png';'361010_rgb2gray.png';'37073_rgb2gray.png';'376043_rgb2gray.png';'38082_rgb2gray.png';'38092_rgb2gray.png';'385039_rgb2gray.png';'41033_rgb2gray.png';'41069_rgb2gray.png';'42012_rgb2gray.png';'42049_rgb2gray.png';'43074_rgb2gray.png';'45096_rgb2gray.png';'54082_rgb2gray.png';'55073_rgb2gray.png';'58060_rgb2gray.png';'62096_rgb2gray.png';'65033_rgb2gray.png';'66053_rgb2gray.png';'69015_rgb2gray.png';'69020_rgb2gray.png';'69040_rgb2gray.png';'76053_rgb2gray.png';'78004_rgb2gray.png';'8023_rgb2gray.png';'85048_rgb2gray.png';'86000_rgb2gray.png';'86016_rgb2gray.png';'86068_rgb2gray.png';'87046_rgb2gray.png';'89072_rgb2gray.png';'97033_rgb2gray.png'};
    case(11)
        % Table 3 - 3st exp: Debluring on set BSD100 with uniform Blur and Noise STD Sqrt(2)
        sAlgParam.algorithmPurpose  = 'deblurring';
        sAlgParam.numItersMain      = 5;
        sAlgParam.initType          = 3; % Using IRCNN initialization
        sSimParam.kernelName        = 'Uniform';
        sSimParam.H                 = ones(9) ./ (9^2);
        sSimParam.noiseStd          = sqrt(2);
        cImages = {'101085_rgb2gray.png';'101087_rgb2gray.png';'102061_rgb2gray.png';'103070_rgb2gray.png';'105025_rgb2gray.png';'106024_rgb2gray.png';'108005_rgb2gray.png';'108070_rgb2gray.png';'108082_rgb2gray.png';'109053_rgb2gray.png';'119082_rgb2gray.png';'12084_rgb2gray.png';'123074_rgb2gray.png';'126007_rgb2gray.png';'130026_rgb2gray.png';'134035_rgb2gray.png';'14037_rgb2gray.png';'143090_rgb2gray.png';'145086_rgb2gray.png';'147091_rgb2gray.png';'148026_rgb2gray.png';'148089_rgb2gray.png';'156065_rgb2gray.png';'157055_rgb2gray.png';'159008_rgb2gray.png';'160068_rgb2gray.png';'16077_rgb2gray.png';'163085_rgb2gray.png';'167062_rgb2gray.png';'167083_rgb2gray.png';'170057_rgb2gray.png';'175032_rgb2gray.png';'175043_rgb2gray.png';'182053_rgb2gray.png';'189080_rgb2gray.png';'19021_rgb2gray.png';'196073_rgb2gray.png';'197017_rgb2gray.png';'208001_rgb2gray.png';'210088_rgb2gray.png';'21077_rgb2gray.png';'216081_rgb2gray.png';'219090_rgb2gray.png';'220075_rgb2gray.png';'223061_rgb2gray.png';'227092_rgb2gray.png';'229036_rgb2gray.png';'236037_rgb2gray.png';'24077_rgb2gray.png';'241004_rgb2gray.png';'241048_rgb2gray.png';'253027_rgb2gray.png';'253055_rgb2gray.png';'260058_rgb2gray.png';'271035_rgb2gray.png';'285079_rgb2gray.png';'291000_rgb2gray.png';'295087_rgb2gray.png';'296007_rgb2gray.png';'296059_rgb2gray.png';'299086_rgb2gray.png';'300091_rgb2gray.png';'302008_rgb2gray.png';'304034_rgb2gray.png';'304074_rgb2gray.png';'306005_rgb2gray.png';'3096_rgb2gray.png';'33039_rgb2gray.png';'351093_rgb2gray.png';'361010_rgb2gray.png';'37073_rgb2gray.png';'376043_rgb2gray.png';'38082_rgb2gray.png';'38092_rgb2gray.png';'385039_rgb2gray.png';'41033_rgb2gray.png';'41069_rgb2gray.png';'42012_rgb2gray.png';'42049_rgb2gray.png';'43074_rgb2gray.png';'45096_rgb2gray.png';'54082_rgb2gray.png';'55073_rgb2gray.png';'58060_rgb2gray.png';'62096_rgb2gray.png';'65033_rgb2gray.png';'66053_rgb2gray.png';'69015_rgb2gray.png';'69020_rgb2gray.png';'69040_rgb2gray.png';'76053_rgb2gray.png';'78004_rgb2gray.png';'8023_rgb2gray.png';'85048_rgb2gray.png';'86000_rgb2gray.png';'86016_rgb2gray.png';'86068_rgb2gray.png';'87046_rgb2gray.png';'89072_rgb2gray.png';'97033_rgb2gray.png'};
    case(12)
        % Table 3 - 4st exp: Debluring on set BSD100 with uniform Blur and Noise STD 2
        sAlgParam.algorithmPurpose  = 'deblurring';
        sAlgParam.numItersMain      = 5;
        sAlgParam.initType          = 3; % Using IRCNN initialization
        sSimParam.kernelName        = 'Uniform';
        sSimParam.H                 = ones(9) ./ (9^2);
        sSimParam.noiseStd          = 2;
        cImages = {'101085_rgb2gray.png';'101087_rgb2gray.png';'102061_rgb2gray.png';'103070_rgb2gray.png';'105025_rgb2gray.png';'106024_rgb2gray.png';'108005_rgb2gray.png';'108070_rgb2gray.png';'108082_rgb2gray.png';'109053_rgb2gray.png';'119082_rgb2gray.png';'12084_rgb2gray.png';'123074_rgb2gray.png';'126007_rgb2gray.png';'130026_rgb2gray.png';'134035_rgb2gray.png';'14037_rgb2gray.png';'143090_rgb2gray.png';'145086_rgb2gray.png';'147091_rgb2gray.png';'148026_rgb2gray.png';'148089_rgb2gray.png';'156065_rgb2gray.png';'157055_rgb2gray.png';'159008_rgb2gray.png';'160068_rgb2gray.png';'16077_rgb2gray.png';'163085_rgb2gray.png';'167062_rgb2gray.png';'167083_rgb2gray.png';'170057_rgb2gray.png';'175032_rgb2gray.png';'175043_rgb2gray.png';'182053_rgb2gray.png';'189080_rgb2gray.png';'19021_rgb2gray.png';'196073_rgb2gray.png';'197017_rgb2gray.png';'208001_rgb2gray.png';'210088_rgb2gray.png';'21077_rgb2gray.png';'216081_rgb2gray.png';'219090_rgb2gray.png';'220075_rgb2gray.png';'223061_rgb2gray.png';'227092_rgb2gray.png';'229036_rgb2gray.png';'236037_rgb2gray.png';'24077_rgb2gray.png';'241004_rgb2gray.png';'241048_rgb2gray.png';'253027_rgb2gray.png';'253055_rgb2gray.png';'260058_rgb2gray.png';'271035_rgb2gray.png';'285079_rgb2gray.png';'291000_rgb2gray.png';'295087_rgb2gray.png';'296007_rgb2gray.png';'296059_rgb2gray.png';'299086_rgb2gray.png';'300091_rgb2gray.png';'302008_rgb2gray.png';'304034_rgb2gray.png';'304074_rgb2gray.png';'306005_rgb2gray.png';'3096_rgb2gray.png';'33039_rgb2gray.png';'351093_rgb2gray.png';'361010_rgb2gray.png';'37073_rgb2gray.png';'376043_rgb2gray.png';'38082_rgb2gray.png';'38092_rgb2gray.png';'385039_rgb2gray.png';'41033_rgb2gray.png';'41069_rgb2gray.png';'42012_rgb2gray.png';'42049_rgb2gray.png';'43074_rgb2gray.png';'45096_rgb2gray.png';'54082_rgb2gray.png';'55073_rgb2gray.png';'58060_rgb2gray.png';'62096_rgb2gray.png';'65033_rgb2gray.png';'66053_rgb2gray.png';'69015_rgb2gray.png';'69020_rgb2gray.png';'69040_rgb2gray.png';'76053_rgb2gray.png';'78004_rgb2gray.png';'8023_rgb2gray.png';'85048_rgb2gray.png';'86000_rgb2gray.png';'86016_rgb2gray.png';'86068_rgb2gray.png';'87046_rgb2gray.png';'89072_rgb2gray.png';'97033_rgb2gray.png'};
    case(13)
        % Table 4 - 1st exp: Inpainting on set5 with 25% missing pixels
        sAlgParam.algorithmPurpose  = 'inpainting';
        sAlgParam.initType          = 1; % Using naive initialization
        sSimParam.missingDataRatio  = 0.25;
        sSimParam.noiseStd          = 0;
        cImages = {'z_baby_GT_rgb2gray','z_bird_GT_rgb2gray','z_butterfly_GT_rgb2gray', 'z_head_GT_rgb2gray','z_woman_GT_rgb2gray'};
    case(14)
        % Table 4 - 1st exp: Inpainting on set5 with 50% missing pixels
        sAlgParam.algorithmPurpose  = 'inpainting';
        sAlgParam.initType          = 1; % Using naive initialization
        sSimParam.missingDataRatio  = 0.5;
        sSimParam.noiseStd          = 0;
        cImages = {'z_baby_GT_rgb2gray','z_bird_GT_rgb2gray','z_butterfly_GT_rgb2gray', 'z_head_GT_rgb2gray','z_woman_GT_rgb2gray'};
    case(15)
        % Table 4 - 1st exp: Inpainting on set5 with 75% missing pixels
        sAlgParam.algorithmPurpose  = 'inpainting';
        sAlgParam.initType          = 1; % Using naive initialization
        sSimParam.missingDataRatio  = 0.75;
        sSimParam.noiseStd          = 0;
        cImages = {'z_baby_GT_rgb2gray','z_bird_GT_rgb2gray','z_butterfly_GT_rgb2gray', 'z_head_GT_rgb2gray','z_woman_GT_rgb2gray'};
    case(16)
        % Table 5 - 1st exp: Inpainting on set NCSR with 25% missing pixels
        sAlgParam.algorithmPurpose  = 'inpainting';
        sAlgParam.initType          = 1; % Using naive initialization
        sSimParam.missingDataRatio  = 0.25;
        sSimParam.noiseStd          = 0;
        cImages = {'Barbara';'Boats';'Cameraman';'House';'Leaves'; 'Lena';'Monarch';'Parrot';'Peppers';'Starfish'};
    case(17)
        % Table 5 - 1st exp: Inpainting on set NCSR with 50% missing pixels
        sAlgParam.algorithmPurpose  = 'inpainting';
        sAlgParam.initType          = 1; % Using naive initialization
        sSimParam.missingDataRatio  = 0.5;
        sSimParam.noiseStd          = 0;
        cImages = {'Barbara';'Boats';'Cameraman';'House';'Leaves'; 'Lena';'Monarch';'Parrot';'Peppers';'Starfish'};
    case(18)
        % Table 5 - 1st exp: Inpainting on set NCSR with 75% missing pixels
        sAlgParam.algorithmPurpose  = 'inpainting';
        sAlgParam.initType          = 1; % Using naive initialization
        sSimParam.missingDataRatio  = 0.75;
        sSimParam.noiseStd          = 0;
        cImages = {'Barbara';'Boats';'Cameraman';'House';'Leaves'; 'Lena';'Monarch';'Parrot';'Peppers';'Starfish'};
    case(19)
        % Figure 2 - Debluring of image 3096 from set BSD100 with Gauss Blur and Noise STD 2
        sAlgParam.algorithmPurpose  = 'deblurring';
        sAlgParam.numItersMain      = 300;
        sAlgParam.initType          = 1; % Using naive initialization
        sSimParam.kernelName        = 'Gaussian';
        sSimParam.H                 = fspecial(sSimParam.kernelName, 25, 1.6);
        sSimParam.noiseStd          = 2;
        cImages = {'3096_rgb2gray.png'};
    case(20)
        % Figure 4 - Inpainting of image 'starfish' with 75% missing pixels
        sAlgParam.algorithmPurpose  = 'inpainting';
        sAlgParam.initType          = 1; % Using naive initialization
        sSimParam.missingDataRatio  = 0.75;
        sSimParam.noiseStd          = 0;
        cImages = {'Starfish.png'};
    otherwise
        % Run some simple deblurring example ('Lena' image with Gauss Blur and Noise STD 2)
        sAlgParam.algorithmPurpose  = 'deblurring';
        sAlgParam.numItersMain      = 5;
        sAlgParam.initType          = 3; % Using IRCNN initialization
        sSimParam.kernelName        = 'Gaussian';
        sSimParam.H                 = fspecial(sSimParam.kernelName, 25, 1.6);
        sSimParam.noiseStd          = 2;
        cImages = {'Lena.tif'};
end


numImages = length(cImages);
cSimData = cell(numImages,1);
for ii = 1:numImages
    sSimParam.imageFileName = cImages{ii};
    cSimData{ii} = RunSimulation(sSimParam, sAlgParam);
end

end


function [ sSimData ] = RunSimulation( sSimParam, sAlgParam )
% ---------------------------------------------------------------------
% Simulate the restoration algorithm by creating a corrupted image,
% running the restoration algorithm on it and displaying results.
% Input arguments are optional (uses defaults in their absence).
% Output 'sSimData' parameter will contain all simulation information.
% Results figure will be displayed and saved in 'ResultsFiles' folder.
% ---------------------------------------------------------------------

if nargin == 0, sSimParam = []; sAlgParam = []; end

% Add all subfolders to path
addpath(genpath(pwd));

% Set Simulation Parameters (noise level, blur-kernel / mask etc.)
sSimParam = SetSimulationParams(sSimParam, sAlgParam);

% Get Original And Corrupted Images
sSimParam = GetOriginalAndCorruptedImages(sSimParam);

% Run Restoration Algorithm
fprintf(GetTextToDisp(sSimParam));
sAlgParam = RunAlgorithm(sSimParam.mCorruptedImage, sSimParam.noiseStd,...
    sSimParam.H, sSimParam.algorithmPurpose, sAlgParam, sSimParam.mOrgImg);

% Display Results
DisplayResults(sAlgParam, sSimParam);

% Gather Simulation Data
sSimData.sAlgParam = sAlgParam;
sSimData.sSimParam = sSimParam;

end


function [ sSimParam ] = SetSimulationParams( sSimParam, sAlgParam )
% Choose algorithm purpose, noise level, blur-kernel / mask etc.

% Choose algorithm purpose (if case it is not given)
if ~isfield(sAlgParam,'algorithmPurpose')
    sSimParam.algorithmPurpose = 'deblurring'; % deblurring , inpainting , denoising
else
    sSimParam.algorithmPurpose = sAlgParam.algorithmPurpose;
end

% Choose blur-kernel / mask and noise level (if case it is not given)
if strcmp(sSimParam.algorithmPurpose,'denoising')
    sSimParam = ChooseNoiseLevel(sSimParam);
elseif strcmp(sSimParam.algorithmPurpose,'deblurring')
    sSimParam = ChooseBlurKernelAndNoiseLevel(sSimParam);
elseif strcmp(sSimParam.algorithmPurpose,'inpainting')
    sSimParam = ChooseMaskAndNoiseLevel(sSimParam);
else
    error('Wrong ''algorithmPurpose'' value');
end

% Fix Random Seed
if strcmp(sSimParam.algorithmPurpose, 'deblurring')
    % On deblurring, use 'seed' = 0 to be consistent with the experiments in NCSR
    FixedRandomSeed = 'seed';% Fix random seed for generated noise
else
    % Fixed random seed options: 'seed' or 'state'
    FixedRandomSeed = 'seed';% Fix random seed for generated noise
end
randn(FixedRandomSeed, 0); % Fix random seed for inpainting mask

% Choose Crop Image Level
if ~isfield(sSimParam,'imageResizeFacor')
    sSimParam.imageResizeFacor = 1;
end

% Choose Image
if ~isfield(sSimParam,'imageFileName')
    sSimParam.imageFileName = 'Lena'; % Barbara , Starfish
end

% Run only PPP with WNNM Denoiser
if ~isfield(sSimParam,'restorAlgType')
    sSimParam.restorAlgType = 1;
end

end


function [ sSimParam ] = GetOriginalAndCorruptedImages( sSimParam )

% Load Original Image
ext =  {'','.tif','.jpg','.png','.bmp'};
imageFileName = sSimParam.imageFileName;
for ii = 1:length(ext)
    if exist([imageFileName, ext{ii}], 'file')
        mOrgImg = double(imread([imageFileName, ext{ii}]));
        break;
    end
end

% Resize (down-scale) Original Image (for faster simulation)
mOrgImg = imresize(mOrgImg, sSimParam.imageResizeFacor);
sSimParam.mOrgImg = mOrgImg;

% Create Corrupted Image
mOrgImg = sSimParam.mOrgImg;
if strcmp(sSimParam.algorithmPurpose, 'deblurring')
    % H is a blur convolution kernel
    mCorruptedImage = imfilter(mOrgImg, sSimParam.H, 'circular', 'conv');
elseif strcmp(sSimParam.algorithmPurpose, 'inpainting')
    if ~isfield(sSimParam,'H')
        rand('seed', 0); % Fix random seed
        sSimParam.H = (rand(size(mOrgImg)) > sSimParam.missingDataRatio);
    end
    mCorruptedImage = mOrgImg .* sSimParam.H;
else
    mCorruptedImage = mOrgImg;
end
mCorruptedImage = mCorruptedImage + (sSimParam.noiseStd * randn(size(mCorruptedImage)));
sSimParam.mCorruptedImage = mCorruptedImage;

end


function [ sSimParam ] = ChooseNoiseLevel( sSimParam )

noiseStd = 2;
if ~isfield(sSimParam,'noiseStd')
    sSimParam.noiseStd = noiseStd;
end
if ~isfield(sSimParam,'H')
    sSimParam.H = [];
end

end


function [ sSimParam ] = ChooseBlurKernelAndNoiseLevel( sSimParam )
% H is a blur convolution kernel

noiseStd = 2;

switch 2
    case 1
        kernelName  = 'Uniform';
        H           = ones(9);
        H           = H ./ sum(H(:));
    case 2
        kernelName  = 'Gaussian';
        H = fspecial(kernelName, 25, 1.6);
    case 3
        kernelName  = 'Motion';
        H = fspecial(kernelName, 10, 45);
    case 4
        kernelName  = 'im05_flit01';
        H           = load(kernelName);
        H           = H.f;
    case 5
        kernelName  = 'Motion_blur';
        H           = load(kernelName);
        H           = H.f;
    case 6
        kernelName  = 'Delta';
        H           = 1;
end

if ~isfield(sSimParam,'noiseStd')
    sSimParam.noiseStd = noiseStd;
end
if ~isfield(sSimParam,'kernelName')
    sSimParam.kernelName = kernelName;
end
if ~isfield(sSimParam,'H')
    sSimParam.H = H; % H is a blur convolution kernel
end

end


function [ sSimParam ] = ChooseMaskAndNoiseLevel( sSimParam )

if ~isfield(sSimParam,'noiseStd')
    sSimParam.noiseStd = 0;
end
if ~isfield(sSimParam,'missingDataRatio')
    if isfield(sSimParam,'H')
        sSimParam.missingDataRatio = NaN;
    else
        sSimParam.missingDataRatio = 0.5;
    end
end

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
