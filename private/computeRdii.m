function [B_sk_rr] = computeRdii(cropSize,B_skf,PaddingRange,B_bw)


B_bwf = false(cropSize);
B_bwf(B_bw) = 1;

rr = PaddingRange.^2;
rrListCount = 0;
for ii = 1:rr
    mask{ii}=DiskMask(ii);
    if any(any(mask{ii}))~= 0
        rrListCount = rrListCount +1;
        rrList(rrListCount) = ii;
    end
end
B_bwf = padarray(B_bwf,[PaddingRange PaddingRange PaddingRange]);
B_sk_rr = uint32(zeros(size(B_skf)));

for ii = 1:length(B_skf)
    
        [x3,y3,z3]=ind2sub(cropSize,B_skf(ii));
        for rrC = 1:rrListCount
            rrI = rrList(rrC);
           rrReal = ceil(sqrt(rrI));
           zone = B_bwf(x3-rrReal+PaddingRange:x3+rrReal+PaddingRange, ...
                       y3-rrReal+PaddingRange:y3+rrReal+PaddingRange, ...
                       z3+PaddingRange:z3+PaddingRange);
           zone = ~zone & mask{rrI};
           if any(any(any(zone))) ~= 0
           break 
           end 
        end
        B_sk_rr(ii) = rrI;

        
end
    
