%% DECODIFICADOR DE VIDEO

filename = 'VIDEOS/SEA/sea.mp4';

videoObject = VideoReader(filename);

videoObject.CurrentTime = 30;

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
% the first one ('allones').
[codeCols,codeRows] = getBestColRowFit(size(hadamardMatrix,1));
hadamardMatrix = hadamardMatrix(2:codeSize+1,:);

% Original shaping and current expected positions
framesPerSymbol = 7;

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

% skip frames
skip_frames = 0;
frames_to_skip = ceil(framesPerSymbol*compression_ratio)-3;
skipped_frames = 0;

% decoded frames
decoded_symbols = [];

% Metric storage
METRIC = [];

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
    
    % We gather info from the diff_frame
    % chips = gatherData(diff_frame, data_positions, -1:1);
    [chips, diff_frame] = gatherDataWithCompensation(squeeze(frameBuffer(:,:,3,:)), ...
        data_positions, ...
        max_pos, min_pos, -1:1);
    
    % We show the frame
%     figure(1);
%     imshow(diff_frame,[]);
%     hold on
%     scatter(data_positions(2,:), data_positions(1,:));
%     hold off
    
    
    % We remove outliers
    %chips(abs(chips - mean(chips)) > std(chips)) = 0;
    
    % We display the product against the hadamardMatrix to estimate the
    % best candidate
    fuck = hadamardMatrix*chips/(32*2*10/255);

    result = pottsOutput(fuck);
%     result = pottsOutput(hadamardMatrix*chips/sum(abs(chips)));
    
    % We obtain the metric to synchronize
    if ~isnan(result(1))
        metric = max(result)/mean(result(result~=max(result)),'all');
    else
        metric = 0;
    end
    
    METRIC(end+1) = metric;
    
    fprintf('Estimated metric %1.2f\n', metric);
    
    % If we have to analyze the buffer data...
    if ~skip_frames
        if (metric > 1.70)
            symbol_index = find(result == max(result));
            decoded_bits = dec2bin(symbol_index - 1, batchSize);
            fprintf('Symbol %s obtained with metric %1.2f\n',decoded_bits(end:-1:1), metric);
            skip_frames = 1;
            
            decoded_symbols(end+1,:) = decoded_bits - 48;
        end
        pause(0.25);
        
    else
        skipped_frames = skipped_frames + 1;
        if (skipped_frames >= frames_to_skip)
            skipped_frames = 0;
            skip_frames = 0;
        end
    end
    
end

decoded_symbols = decoded_symbols(:, end:-1:1);
PEPE = reshape(dataBuffer(1:size(decoded_symbols,1)*4), 4, size(decoded_symbols,1))';
1 - sum(decoded_symbols - PEPE == 0, 'all')/numel(decoded_symbols)