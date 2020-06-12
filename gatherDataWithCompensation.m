function [chips, diff_frame] = gatherDataWithCompensation(buffer, data_positions, max_pos, min_pos, window)

chips = zeros(size(data_positions,2),1);
initial_frame = buffer(:,:,max_pos)/255;
last_frame = buffer(:,:,min_pos)/255;

% FAST Features
ptThresh = 0.1;
pointsA = detectFASTFeatures(initial_frame, 'MinContrast', ptThresh);
pointsB = detectFASTFeatures(last_frame, 'MinContrast', ptThresh);

% FREAK features
[featuresA, pointsA] = extractFeatures(initial_frame, pointsA);
[featuresB, pointsB] = extractFeatures(last_frame, pointsB);

% Matching
indexPairs = matchFeatures(featuresA, featuresB);
pointsA = pointsA(indexPairs(:, 1), :);
pointsB = pointsB(indexPairs(:, 2), :);

% Transformation of last_frame

% If we do not have enough points, we carry out the untransformed
% difference
if ((length(pointsA) < 3) && (length(pointsB) < 3))
    last_frame_transformed = last_frame;

else
    fprintf('Enough points to carry out warping\n');
    [tform, ~, ~] = estimateGeometricTransform(...
        pointsB, pointsA, 'affine');
    
    last_frame_transformed = imwarp(last_frame, tform, 'OutputView', ...
        imref2d(size(last_frame)));
    
end

% Now we get the difference
diff_frame = initial_frame - last_frame_transformed;

for I = 1:length(data_positions)
    row = round(data_positions(1,I));
    col = round(data_positions(2,I));
    chips(I) = mean(diff_frame(row+window,col+window), 'all');
end