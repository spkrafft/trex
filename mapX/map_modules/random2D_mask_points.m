function [X_out,Y_out,Z_out,out_mask] = random2D_mask_points(mask,block_size,overlap)
%Finds indices contained with in the mask that do not overlap within the
%given block size and are completely contained with in the mask

X_out = [];
Y_out = [];
Z_out = [];

out_mask = nan(size(mask));

for k = 1:size(mask,3)
    slice_mask = mask(:,:,k);

    if sum(slice_mask(:)) > (2*block_size^2) %Why twice the size? Somewhat arbitrary, but seems like a decent cutoff since not all points necessarily form a square block...
    
        %Crop it to limit the search space
        %[~,slice_mask] = prepCrop(double(slice_mask),slice_mask);
        
        siz = size(slice_mask);
        size_y = siz(1);
        size_x = siz(2);
        
        %Total number of indices to generate, twice the size along the given
        %dimension
        num_y = size_y*2;
        num_x = size_x*2;

        %Randomly generate [i,j] indices
        rng('Default');
        rng(k); %Set seed
        Y = randi(size_y,[num_y,1]);
        rng(k+1);  %Set seed
        X = randi(size_x,[num_x,1]);
        %%
        [X,Y] = meshgrid(X,Y);
        X = X(:);
        Y = Y(:);
        %%
        rng(k);
        ix = randperm(numel(X));
        X = X(ix);
        Y = Y(ix);

        %%
        %Lower and upper bound for each block centered on ind_Y
        Y_low = Y - floor(block_size/2);
        Y_up = Y + ceil(block_size/2) - 1;

        %Lower and upper bound for each block centered on ind_j
        X_low = X - floor(block_size/2);
        X_up = X + ceil(block_size/2) - 1;

        %If part of the block falls outside the slice, get rid of it, ind_Y
        ind = Y_low < 1 | Y_up > size_y | X_low < 1 | X_up > size_x;
        Y_low(ind) = [];
        Y(ind) = [];
        Y_up(ind) = [];
        X_low(ind) = [];
        X(ind) = [];
        X_up(ind) = [];
        
        num_points = numel(X);

        %%
        keep_count = 0;
        for count = 1:num_points
            %Get the selected mask area for the given indices
            curr_mask = slice_mask(Y_low(count):Y_up(count),...
                             X_low(count):X_up(count));

            %If the current mask area is completely within the masked
            %region (i.e. the number of elements is equal to the area
            %of the block_size) then keep it
            if sum(curr_mask(:)) >= (block_size^2 - block_size*overlap)
                %Set this area of the mask to false to ensure no
                %overlap
                slice_mask(Y_low(count):Y_up(count),...
                           X_low(count):X_up(count)) = false;

                %Add indices to the output variables keep
                X_out(end+1,:) = [X_low(count),X(count),X_up(count)];
                Y_out(end+1,:) = [Y_low(count),Y(count),Y_up(count)];
                Z_out(end+1,:) = [k,k,k];

                keep_count = keep_count + 1;
                if keep_count == (10+overlap) %Keep no more than 10 per slice
                    break
                end
            end
        end

        out_mask(:,:,k) = slice_mask;
    end
end

%%
clearvars -except X_out Y_out Z_out out_mask
