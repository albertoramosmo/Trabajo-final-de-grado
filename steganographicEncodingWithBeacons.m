function encodedBuffer = steganographicEncodingWithBeacons(frameBuffer,encodedBits,...
    alpha,sigma, shaping, flag, beacon_size)
% This function encodes data

% We allocate memory for the encodedBuffer
encodedBuffer = zeros(size(frameBuffer));

% We get from frameBuffer the width and height of the images
width = size(frameBuffer, 2); % Width is in the cols dimension
height = size(frameBuffer, 1); % Height is in the rows dimension

% From encodedBits we get the grid size (we must determine if it is a exact
% square of just an exact log2)
codeLength = length(encodedBits);

% This function does what was commented above. It assumes that codeLength
% is an exact log2, and prioritizes the number of cols vs rows.
[cols,rows] = getBestColRowFit(codeLength);

% Modificamos ahora encodedBits según cols y rows
encodedBits = reshape(encodedBits, rows,cols);

% Now we set the colSize and rowSize referred to the image size
colSize = floor(width/cols);
rowSize = floor(height/rows);

codeImage = ones(size(frameBuffer,1), ...
    size(frameBuffer,2));

% We iterate to create our image
for I = 1:rows
    for J = 1:cols
        posRow = (I-1)*rowSize+1;
        posCol = (J-1)*colSize+1;
        % Coefficient to multiply the image
        C = encodedBits(I,J)*alpha;
        codeImage(posRow:posRow+rowSize-1, posCol:posCol+colSize-1,:) = ...
            C*codeImage(posRow:posRow+rowSize-1, posCol:posCol+colSize-1,:);
    end
end

% codeImage is the first one, now we must apply image filtering to reduce
% the spatial frequency of the image.
codeImage = imgaussfilt(codeImage, sigma);
% imshow(codeImage,[]);
% return

index = 1;
% This operation can be parallelized using filter function and operating in
% a pixel basis
for P = shaping
    
    
    % We add the information only on the blue channel and add beacon
    image_buffer = frameBuffer(:,:,:,index);
    image_buffer(:,:,3) = image_buffer(:,:,3) + ...
        P*codeImage;

    image_buffer(1:beacon_size,       1:beacon_size, :) = 0;
    image_buffer(1:beacon_size,       1:beacon_size,       1+flag) = 255;
    
    image_buffer(1:beacon_size,       end-beacon_size:end, :) = 0;
    image_buffer(1:beacon_size,       end-beacon_size:end, 1+flag) = 255;
    
    image_buffer(end-beacon_size:end, 1:beacon_size, :) = 0;
    image_buffer(end-beacon_size:end, 1:beacon_size,       1+flag) = 255;
    
    image_buffer(end-beacon_size:end, end-beacon_size:end, :) = 0;
    image_buffer(end-beacon_size:end, end-beacon_size:end, 1+flag) = 255;
    
    encodedBuffer(:,:,:,index) = image_buffer;
    index = index + 1;
end
end