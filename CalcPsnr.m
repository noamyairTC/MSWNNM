function [ nPSNR ] = CalcPsnr( estImg, orgImg )
estImg  = double(estImg);
orgImg  = double(orgImg);
nMSE    = mean((estImg(:)-orgImg(:)).^2);
nPSNR   = 10*log10((255^2)/nMSE);
end