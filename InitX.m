function [ x ] = InitX( y, HTy, fftHtH, sAlgParam, mOrgImg )
% Set initial value for x

% Extract Data From struct
algorithmPurpose    = sAlgParam.algorithmPurpose;
H                   = sAlgParam.H;
noiseStd            = sAlgParam.noiseStd;
initType            = sAlgParam.initType;
% --------------------------------------------------

% Choose initialization type
switch(initType)
    case(1)
        % Simple Initialization
        x = y;
    case(2)
        % Initialization Using Wiener Filter
        x = RunWienerFilter(y, HTy, fftHtH, sAlgParam);
    case(3)
        % Initialization Using IRCNN
        fprintf('\nInitializing using IRCNN:\n');
        vl_compilenn();
        sAlgParam = RunIRCNN(y, noiseStd, H, algorithmPurpose, sAlgParam, mOrgImg);
        fprintf('Initialization Completed.\n');
        x = sAlgParam.sResults.mRestoredImage;
    otherwise
        % Simple Initialization
        x = y;
end

if nargin > 4, fprintf('PSNR after initialization: %f [db].\n', CalcPsnr(x, mOrgImg)); end

end


function [ x ] = RunWienerFilter( y, HTy, fftHtH, sAlgParam )
% Deblur image using the Wiener filter:
%
%       conj(H)*Y
% X = -------------
%     |H|^2 + Su/Sx
%
% If Image Processing Toolbox is available then x = deconvwnr(y, H, Su)
% -----------------------------------------------------------------------

% Extract Data From struct
noiseStd            = sAlgParam.noiseStd;
imgHeight           = sAlgParam.imgHeight;
imgWidth            = sAlgParam.imgWidth;
imgDim              = sAlgParam.imgDim;
% -----------------------------------------

x = NaN(imgHeight, imgWidth, imgDim);
for ii = 1:imgDim
    Su  = noiseStd^2 / var(reshape(y(:,:,ii),[],1));
    Sx  = 1;
    X   = fft2(HTy(:,:,ii)) ./ (fftHtH + Su/Sx);
    x(:,:,ii) = real(ifft2(X)); % The 'real' is for avoiding numerical issues
end

end
