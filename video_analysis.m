%% VIDEO ANALYSIS

videoObject = VideoReader('prueba50FPS.mp4');

capture_fps     = videoObject.FrameRate;
width           = videoObject.Width;
height          = videoObject.Height;
numChannels     = size(videoObject.readFrame,3);

% Original video fps
original_fps = 50;

% Compression ratio to estimate the position of the new max and min values
% within the buffer
compression_ratio = capture_fps/original_fps;

% Hadamard Code
% We define the batch size and then we adjust the number of cols and rows
% of the code
batchSize = 4;

% Code size (must be exact log2).
codeSize = 2^batchSize;

hadamardMatrix = hadamard(2^(batchSize+1));
% We keep only 2^batchSize elements from the previous matrix, discarding
% the firs one ('allones').
[codeCols,codeRows] = getBestColRowFit(size(hadamardMatrix,1));
hadamardMatrix = hadamardMatrix(2:codeSize+1,:);

% Original shaping and current expected positions
framesPerSymbol = 10;

shaping = getSymbolShape(framesPerSymbol, 0.5);
[~, max_pos] = max(shaping);
[~, min_pos] = min(shaping);

max_pos = ceil(max_pos*compression_ratio);
min_pos = ceil(min_pos*compression_ratio);

% Frame buffer
frameBuffer = zeros(height, width, numChannels,...
    ceil(framesPerSymbol*compression_ratio));

framesInBuffer = 0;

% Auxiliary variables
roi_selected = 0;
boundaries = [];

while (hasFrame(videoObject))
    frame = double(readFrame(videoObject));
    
    % We ask the user to insert the positions of the ROI (4 points romboid)
    if ~roi_selected
        imshow(frame/255,[]);
        [boundaries(:,2), boundaries(:,1)] = ginput(4);
        data_positions = getDataPositions(boundaries, codeRows, codeCols);
        roi_selected = 1;
    end
    
    frameBuffer = shiftBuffer(frameBuffer, frame);
    
    diff_frame = frameBuffer(:,:,3,max_pos) - frameBuffer(:,:,3,min_pos);
    
    figure(1);
    imshow(diff_frame/255,[]);
    hold on
    scatter(data_positions(2,:), data_positions(1,:));
    hold off
    
    % We gather info from the diff_frame
    chips = gatherData(diff_frame, data_positions, -1:1);
    % We remove outliers
    chips(abs(chips - mean(chips)) > std(chips)) = 0;
    
    % We display the product against the hadamardMatrix to estimate the
    % best candidate
    result = hadamardMatrix*chips
    find(result == max(result))
    pottsOutput(result)
    figure(2);
    plot(chips);
    
    pause;
   
end