function [ mNeighbors, neighborsNum, refPtchIdx ] = GetNeighborIndex(...
    imgHeight, imgWidth, stepSize, searchWinSize, patchSize )
% -----------------------------------------------------------------------------------
% Compute all patch indexes in the Searching window
% - mNeighbors is the array of neighbor patch indexes for each keypatch
% - neighborsNum is array of the effective neighbor patch numbers for each keypatch
% - refPtchIdx is the index of keypatches in the total patch index array
% -----------------------------------------------------------------------------------

R               = imgHeight - patchSize + 1;
C               = imgWidth - patchSize + 1;
gridIdxR        = 1:stepSize:R;
gridIdxR        = [gridIdxR, gridIdxR(end)+1:R];
gridIdxC        = 1:stepSize:C;
gridIdxC        = [gridIdxC, gridIdxC(end)+1:C];

Idx             = (1:R*C);
Idx             = reshape(Idx, R, C);
gridR_H         = length(gridIdxR);    
gridC_W         = length(gridIdxC); 

mNeighbors      = int32(zeros(4*searchWinSize*searchWinSize, gridR_H*gridC_W));
neighborsNum    = int32(zeros(1, gridR_H*gridC_W));
refPtchIdx      = int32(zeros(1, gridR_H*gridC_W));

for ii = 1:gridR_H
    for jj = 1:gridC_W
        OffsetR     = gridIdxR(ii);
        OffsetC     = gridIdxC(jj);
        Offset1  	= (OffsetC-1)*R + OffsetR;
        Offset2   	= (jj-1)*gridR_H + ii;
                
        top         = max(OffsetR-searchWinSize, 1);
        button      = min(OffsetR+searchWinSize, R);        
        left        = max(OffsetC-searchWinSize, 1);
        right       = min(OffsetC+searchWinSize, C);     
        
        NL_Idx      = Idx(top:button, left:right);
        NL_Idx      = NL_Idx(:);

        neighborsNum(Offset2) = length(NL_Idx);
        mNeighbors(1:neighborsNum(Offset2),Offset2) = NL_Idx;   
        refPtchIdx(Offset2) = Offset1;
    end
end

end