function [mask] = roisubvolumes_extractX(roiname,mask)
%%
tempmask = false(size(mask));

%Get the boundaries of the mask
ind = sum(squeeze(any(mask,1)),1);
ind = find(ind);
startz = min(ind);
if startz < 1
    startz = 1;
end
endz = max(ind);
if endz > size(mask,3)
    endz = size(mask,3);
end

ind = sum(squeeze(any(mask,2)),2);
ind = find(ind);
starty = min(ind);
if starty < 1
    starty = 1;
end
endy = max(ind);
if endy > size(mask,1)
    endy = size(mask,1);
end

ind = sum(squeeze(any(mask,3)),1);
ind = find(ind);
startx = min(ind);
if startx < 1
    startx = 1;
end
endx = max(ind);
if endx > size(mask,2)
    endx = size(mask,2);
end

switch roiname
    case 'Subvolume: Superior_50%'
        slices = startz:floor((endz-startz)/2)+startz;
        tempmask(:,:,slices) = 1;
    case 'Subvolume: Inferior_50%'
        slices = floor((endz-startz)/2)+startz+1:endz;
        tempmask(:,:,slices) = 1;
    case 'Subvolume: Distal_50%'
        slices = startx:floor((endx-startx)/4)+startx;
        slices = [slices, 3*floor((endx-startx)/4)+startx+1:endx];
        tempmask(:,slices,:) = 1;
    case 'Subvolume: Central_50%'
        slices = floor((endx-startx)/4)+startx+1:3*floor((endx-startx)/4)+startx;
        tempmask(:,slices,:) = 1;
    case 'Subvolume: Anterior_50%'
        slices = starty:floor((endy-starty)/2)+starty;
        tempmask(slices,:,:) = 1;
    case 'Subvolume: Posterior_50%'
        slices = floor((endy-starty)/2)+starty+1:endy;
        tempmask(slices,:,:) = 1;
        
    case 'Subvolume: Inter_SDA_50%'
        slicesz = startz:floor((endz-startz)/2)+startz;  
        slicesx = startx:floor((endx-startx)/4)+startx;
        slicesx = [slicesx, 3*floor((endx-startx)/4)+startx+1:endx];
        slicesy = starty:floor((endy-starty)/2)+starty;
        tempmask(slicesy,slicesx,slicesz) = 1;
    case 'Subvolume: Inter_SDP_50%'
        slicesz = startz:floor((endz-startz)/2)+startz;  
        slicesx = startx:floor((endx-startx)/4)+startx;
        slicesx = [slicesx, 3*floor((endx-startx)/4)+startx+1:endx];
        slicesy = floor((endy-starty)/2)+starty+1:endy;
        tempmask(slicesy,slicesx,slicesz) = 1;
    case 'Subvolume: Inter_SCA_50%'        
        slicesz = startz:floor((endz-startz)/2)+startz;       
        slicesx = floor((endx-startx)/4)+startx+1:3*floor((endx-startx)/4)+startx;               
        slicesy = starty:floor((endy-starty)/2)+starty;
        tempmask(slicesy,slicesx,slicesz) = 1;
    case 'Subvolume: Inter_SCP_50%'
        slicesz = startz:floor((endz-startz)/2)+startz;    
        slicesx = floor((endx-startx)/4)+startx+1:3*floor((endx-startx)/4)+startx;             
        slicesy = floor((endy-starty)/2)+starty+1:endy;
        tempmask(slicesy,slicesx,slicesz) = 1;
    case 'Subvolume: Inter_IDA_50%'        
        slicesz = floor((endz-startz)/2)+startz+1:endz;
        slicesx = startx:floor((endx-startx)/4)+startx;
        slicesx = [slicesx, 3*floor((endx-startx)/4)+startx+1:endx];
        slicesy = starty:floor((endy-starty)/2)+starty;
        tempmask(slicesy,slicesx,slicesz) = 1;
    case 'Subvolume: Inter_IDP_50%'
        slicesz = floor((endz-startz)/2)+startz+1:endz;
        slicesx = startx:floor((endx-startx)/4)+startx;
        slicesx = [slicesx, 3*floor((endx-startx)/4)+startx+1:endx];
        slicesy = floor((endy-starty)/2)+starty+1:endy;
        tempmask(slicesy,slicesx,slicesz) = 1;
    case 'Subvolume: Inter_ICA_50%'        
        slicesz = floor((endz-startz)/2)+startz+1:endz;
        slicesx = floor((endx-startx)/4)+startx+1:3*floor((endx-startx)/4)+startx;       
        slicesy = starty:floor((endy-starty)/2)+starty;
        tempmask(slicesy,slicesx,slicesz) = 1;
    case 'Subvolume: Inter_ICP_50%'        
        slicesz = floor((endz-startz)/2)+startz+1:endz;
        slicesx = floor((endx-startx)/4)+startx+1:3*floor((endx-startx)/4)+startx;       
        slicesy = floor((endy-starty)/2)+starty+1:endy;
        tempmask(slicesy,slicesx,slicesz) = 1;

    case 'Subvolume: SI_12'
        slices = startz:floor((endz-startz)/2)+startz;
        tempmask(:,:,slices) = 1;
    case 'Subvolume: SI_22' 
        slices = floor((endz-startz)/2)+startz+1:endz;
        tempmask(:,:,slices) = 1;
    case 'Subvolume: SI_13'
        slices = startz:floor((endz-startz)/3+startz);
        tempmask(:,:,slices) = 1;
    case 'Subvolume: SI_23'
        slices = floor((endz-startz)/3)+startz+1:2*floor((endz-startz)/3)+startz;
        tempmask(:,:,slices) = 1;
    case 'Subvolume: SI_33'
        slices = 2*floor((endz-startz)/3)+startz+1:endz;
        tempmask(:,:,slices) = 1;
    case 'Subvolume: SI_14'
        slices = 1:floor((endz-startz)/4)+startz;
        tempmask(:,:,slices) = 1;
    case 'Subvolume: SI_24'
        slices = floor((endz-startz)/4)+startz+1:2*floor((endz-startz)/4)+startz;
        tempmask(:,:,slices) = 1;
    case 'Subvolume: SI_34'
        slices = 2*floor((endz-startz)/4)+startz+1:3*floor((endz-startz)/4)+startz;
        tempmask(:,:,slices) = 1;
    case 'Subvolume: SI_44'
        slices = 3*floor((endz-startz)/4)+startz+1:endz;
        tempmask(:,:,slices) = 1;
    otherwise
        error('Not a valid subvolume')
end

mask = mask.*tempmask;

%%
clearvars -except mask
