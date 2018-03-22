function [ knnIdx ] = GetKNN( x, refPtchIdx, cCoarserImg, sAlgParam )
% Caculate Non-local similar patches for each patch
% 
% The dimension of 'knnIdx' is (K x P x M), where:
% K - the number of nearest neighbors
% P - the number of patches in the image
% M - number of scales
%
% The Indexes of the K-NN patches of patch i are located in knnIdx(:,i,:),
% Where the NN from scale 1 are in knnIdx(:,i,1), the NN from scale 2 are in knnIdx(:,i,2), etc.
% -----------------------------------------------------------------------------------------------

K               = sAlgParam.K;
patchSize       = sAlgParam.patchSize;
downScaleFactor = sAlgParam.downScaleFactor;

% Implementation note: in the case of length(downScaleFactor) == 1 the solution provided by
% 'Block_matching' and 'Block_matching_MS' is equal, however, the implementation of
% 'Block_matching' do not uses cells which is faster.
if length(downScaleFactor) == 1
    knnIdx = Block_matching(x, cCoarserImg, refPtchIdx, K, patchSize);
else
    knnIdx = Block_matching_MS(x, cCoarserImg, refPtchIdx, K, patchSize, downScaleFactor);
end

end


function [ knnIdx ] = Block_matching( x, cCoarserImg, refPtchIdx, K, patchSize )
% Caculate Non-local similar patches for each patch

mNeighbors  = cCoarserImg{1,1};
neighborsNum= cCoarserImg{1,2};
xPatches    = GetPatches(x, patchSize);
L           = length(neighborsNum);
knnIdx      = zeros(K, L);
for ii = 1:L
    Patch           = xPatches(:,refPtchIdx(ii),:);
    Neighbors       = xPatches(:,mNeighbors(1:neighborsNum(ii),ii),:);
    Dist            = sum(sum((repmat(Patch,1,size(Neighbors,2),1)-Neighbors).^2),3);
    [~, index]      = sort(Dist);
    knnIdx(:,ii) = mNeighbors(index(1:K),ii);
end

end


function [ knnIdx ] = Block_matching_MS( x, cCoarserImg, refPtchIdx, K, patchSize, downScaleFactor )
% Caculate Non-local similar patches for each patch in both images (x and down-scale image)
%
% 'cCoarserImg' is a numScales x 4 cell, where:
% dim1 - mNeighbors (patches in the search window of each patch)
% dim2 - neighborsNum (number of patches in the search window of each patch)
% dim3 - imgHeight
% dim4 - imgWidth

% --- Create Video - Not Part of the Algorithm (Just For Debug / visualization) ---
makeVideoFlag   = false;
saveVidoeToFile = false;
if makeVideoFlag
    if saveVidoeToFile
        v = VideoWriter('KNN_Search.avi');
        open(v);
    end
    if ispc, set(0,'DefaultFigureWindowStyle','normal'); end
    figure('rend','painters','pos',[400 200 1400 600]);
end
% --- Create Video - Not Part of the Algorithm (Just For Debug / visualization) ---

numScales = length(downScaleFactor);
cPatches = cell(numScales, 1);
C = NaN(numScales, 1);
R = NaN(numScales, 1);
for jj = 1:numScales
    coarserX        = imresize(x, downScaleFactor(jj));
    cPatches{jj}    = GetPatches(coarserX, patchSize);
    C(jj)           = cCoarserImg{jj,3} - patchSize + 1;
    R(jj)           = cCoarserImg{jj,4} - patchSize + 1;
    
    % --- Create Video - Not Part of the Algorithm (Just For Debug / visualization) ---
    if makeVideoFlag, cCoarserX{jj} = coarserX; end
    % --- Create Video - Not Part of the Algorithm (Just For Debug / visualization) ---
end

L = length(cCoarserImg{1,2});
knnIdx = NaN(K, L, numScales);
for ii = 1:L
    
    refIdx1         = ii;
    refPatchIdx1    = double(refPtchIdx(refIdx1));
    col_org         = mod(refPatchIdx1 - 1, C(1)) + 1;
    row_org         = floor((refPatchIdx1 - 1) / C(1)) + 1;
    
    neighbors       = [];
    vPatchesSourse  = [];
    vRefPatchIdx    = NaN(numScales, 1);
    for jj = 1:numScales
        
        if jj == 1
            coarserRefPatchIdx = ii;
        else
            coarserCol = min(max(round(col_org * downScaleFactor(jj)) , 1), C(jj));
            coarserRow = min(max(round(row_org * downScaleFactor(jj)) , 1), R(jj));
            coarserRefPatchIdx  = coarserCol + ((coarserRow - 1) * C(jj));
        end
        vRefPatchIdx(jj)    = coarserRefPatchIdx;
        mPatches            = cPatches{jj};
        mNeighbors          = cCoarserImg{jj,1};
        neighborsNum        = cCoarserImg{jj,2};
        patchesInWin        = mNeighbors(1:neighborsNum(coarserRefPatchIdx), coarserRefPatchIdx);
        neighbors           = [neighbors, mPatches(:, patchesInWin, :)];
        vPatchesSourse      = [vPatchesSourse; jj .* ones(cCoarserImg{jj,2}(coarserRefPatchIdx),1)]; % Mark patches that came not from original image
        
        if jj==1, refPatch = mPatches(:, refPatchIdx1, :); end % Take refPatch from originl image
        
        % --- Create Video - Not Part of the Algorithm (Just For Debug / visualization) ---
        if makeVideoFlag
            cPatchesInWin{jj} = patchesInWin;
        end
        % --- Create Video - Not Part of the Algorithm (Just For Debug / visualization) ---
    end
    
    vDist = sum(sum((repmat(refPatch,1,size(neighbors,2),1)-neighbors).^2),3); % TO DO: Use broadcast
    
    aaa = sortrows([vDist.', vPatchesSourse, (1:length(vPatchesSourse)).']);
    aaa = aaa(1:K, :);
    
    cnt = 0;
    for jj = 1:numScales
        index = aaa(aaa(:,2)==jj,3) - cnt;
        knnIdx(1:length(index),ii,jj) = cCoarserImg{jj,1}(index,vRefPatchIdx(jj));
        cnt = cnt + double(cCoarserImg{jj,2}(vRefPatchIdx(jj)));
        
        % --- Create Video - Not Part of the Algorithm (Just For Debug / visualization) ---
        if makeVideoFlag, cIndex{jj} = index; end
        % --- Create Video - Not Part of the Algorithm (Just For Debug / visualization) ---
    end
    
    
    % --- Create Video - Not Part of the Algorithm (Just For Debug / visualization) ---
    if makeVideoFlag
        
        cFrameImg = cell(3,1);
        
        % Original Image
        % -------------------
        
        for coarserIdx = 1:numScales
            
            % Set Image
            frameImg_channel1 = cCoarserX{coarserIdx};
            frameImg_channel2 = frameImg_channel1;
            frameImg_channel3 = frameImg_channel1;
            
            % Set Search Window
            patchesInWin1   = cPatchesInWin{coarserIdx};
            win_top         = mod(min(patchesInWin1) - 1, C(coarserIdx)) + 1;
            win_left        = floor((min(patchesInWin1) - 1) / C(coarserIdx)) + 1;
            win_bottom      = mod(max(patchesInWin1) - 1, C(coarserIdx)) + patchSize;
            win_right       = floor((max(patchesInWin1) - 1) / C(coarserIdx)) + patchSize;
            win_col         = win_top:win_bottom;
            win_row         = win_left:win_right;
            
            frameImg_channel1(win_col, win_row) = 0;
            frameImg_channel2(win_col, win_row) = frameImg_channel2(win_col, win_row);
            frameImg_channel3(win_col, win_row) = frameImg_channel3(win_col, win_row) + 100;
            
            % Set KNN Patches
            for currNnPatchIdx = 1:length(cIndex{coarserIdx})
                nn_col      = mod(knnIdx(currNnPatchIdx,ii,coarserIdx) - 1, C(coarserIdx)) + 1;
                nn_row      = floor((knnIdx(currNnPatchIdx,ii,coarserIdx) - 1) / C(coarserIdx)) + 1;
                patchColIdx = nn_col:(nn_col+patchSize-1);
                patchRowIdx = nn_row:(nn_row+patchSize-1);
                frameImg_channel1(patchColIdx,patchRowIdx) = 0;
                frameImg_channel2(patchColIdx,patchRowIdx) = 170;
                frameImg_channel3(patchColIdx,patchRowIdx) = 0;
            end
            
            % Set Reference Patche
            if coarserIdx == 1
                patchColIdx = col_org:(col_org+patchSize-1);
                patchRowIdx = row_org:(row_org+patchSize-1);
                frameImg_channel1(patchColIdx,patchRowIdx) = 255;
                frameImg_channel2(patchColIdx,patchRowIdx) = 255;
                frameImg_channel3(patchColIdx,patchRowIdx) = 0;
            end
            
            cFrameImg{coarserIdx} = cat(3,frameImg_channel1, frameImg_channel2, frameImg_channel3);
            
        end
        
        
        % Plot Figure
        % ---------------
        
        fontName = 'Times';
        titlesFontSize = 14;
        detailsFontSize = 10;
        if numScales == 2
            subplot(3,5,[1,2,3,6,7,8,11,12,13]);
            imshow(cFrameImg{1} ./ 255);
            title('Original Image', 'FontName', fontName, 'FontSize', titlesFontSize);
            subplot(3,5,[4,5,9,10]);
            imshow(cFrameImg{2} ./ 255);
            title('Coarser Image', 'FontName', fontName, 'FontSize', titlesFontSize);
            
            detailsStr = {...
                ['Num patches from original Image: ',   num2str(length(cIndex{1}))],...
                ['Num patches from coarser Image: ',    num2str(length(cIndex{2}))],...
                ['Total Number of patches (K): ',       num2str(length(cIndex{1})+length(cIndex{2}))],...
                [],...
                'Yellow: Reference patch',...
                'Blue: Search window',...
                'Green: Selected KNN patches',...
                };
            subplot(3,5,[14,15]);
            cla;
            text(0.05, 0.5, detailsStr, 'FontName', fontName, 'FontSize', detailsFontSize, 'HorizontalAlignment', 'left');
            set(gca,'YTick',[]);
            set(gca,'XTick',[]);
            drawnow;
        else
            detailsStr = {...
                ['Num patches from original Image: ',   num2str(length(cIndex{1}))],...
                ['Num patches from coarser Image 1: ',    num2str(length(cIndex{2}))],...
                ['Num patches from coarser Image 2: ',    num2str(length(cIndex{3}))],...
                ['Total Number of patches (K): ',       num2str(length(cIndex{1})+length(cIndex{2})+length(cIndex{3}))],...
                [],...
                'Yellow: Reference patch',...
                'Blue: Search window',...
                'Green: Selected KNN patches',...
                };
            
            subplot(4,9,[1:4, 10:13, 19:22, 28:31]);
            imshow(cFrameImg{1} ./ 255);
            title('Original Image', 'FontName', fontName, 'FontSize', titlesFontSize);
            subplot(4,9,[5:7, 14:16, 23:25]);
            imshow(cFrameImg{2} ./ 255);
            title('Coarser Image 1', 'FontName', fontName, 'FontSize', titlesFontSize);
            subplot(4,9,[8:9, 17:18]);
            imshow(cFrameImg{3} ./ 255);
            title('Coarser Image 2', 'FontName', fontName, 'FontSize', titlesFontSize);
            subplot(4,9,[26:27,35:36]);
            cla;
            text(0.05, 0.5, detailsStr, 'FontName', fontName, 'FontSize', detailsFontSize, 'HorizontalAlignment', 'left');
            set(gca,'YTick',[]);
            set(gca,'XTick',[]);
            drawnow;
        end
        
    end
    
    if saveVidoeToFile, writeVideo(v,getframe(gcf)); end
    
    % --- Create Video - Not Part of the Algorithm (Just For Debug / visualization) ---
    
end

% --- Create Video - Not Part of the Algorithm (Just For Debug / visualization) ---
if makeVideoFlag && saveVidoeToFile, close(v); end
% --- Create Video - Not Part of the Algorithm (Just For Debug / visualization) ---

end
