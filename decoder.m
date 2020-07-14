%% DECODIFICADOR DE VIDEO

filename = '/media/vguerra/ARM/GRABACIONES/SEA/sea.mp4';

videoObject = VideoReader(filename);

videoObject.CurrentTime = 0;

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


% SIRS
SIR = [10 50 90];
ALPHA = [3 5 10];
FRAMES = [7 14 27];

% Original shaping and current expected positions
% We select the ROI for the whole video processing
videoObject.CurrentTime = 10;
frame = double(readFrame(videoObject));
imshow(frame/255,[]);
[boundaries(:,2), boundaries(:,1)] = ginput(4);
[data_positions, anchor_positions] = getDataAndAnchorPositions(boundaries, codeRows, codeCols);
hold on
scatter(data_positions(2,:), data_positions(1,:),10,'r');
scatter(anchor_positions(2, :), anchor_positions(1,:),10,'g');
hold off

videoObject.CurrentTime = 0;

% Black screen detection
synchronized = 0;

% Timing
times = 16.78*(0:27);

last_anchor_type = 0;

times_position = 1;

for framesPerSymbol = FRAMES
    shaping = getSymbolShape(framesPerSymbol, 0.5);
    [~, max_pos] = max(shaping);
    [~, min_pos] = min(shaping);
    
    max_pos = ceil(max_pos*compression_ratio);
    min_pos = ceil(min_pos*compression_ratio);
    
    
    for alpha = ALPHA
        for sir = SIR
            videoObject.CurrentTime = times(times_position);
            
            METRIC = [];
            METRIC_TYPE = [];
            DECIDED_SYMBOL = [];
            
            fprintf('SIR: %1.2f, ALPHA: %1.2f, FPSymb: %d\n',sir,alpha,framesPerSymbol);
            % Frame buffer
            frameBuffer = zeros(height, width, numChannels,...
                ceil(framesPerSymbol*compression_ratio));
            
            histogram_count = 0;
            
            while(videoObject.CurrentTime < times(times_position+1))
                % We capture a new frame
                frame = double(readFrame(videoObject));
                
                % We introduce the new frame into the buffer
                frameBuffer = shiftBuffer(frameBuffer, frame);
                
                % We gather info from the diff_frame
                % chips = gatherData(diff_frame, data_positions, -1:1);
                [chips, diff_frame] = gatherDataWithCompensation(squeeze(frameBuffer(:,:,3,:)), ...
                    data_positions, ...
                    max_pos, min_pos, -1:1);
                
                % 0 for red, 1 for green, and -1 for nothing
                anchor_type = gatherAnchor(frameBuffer(:,:,:,max_pos), anchor_positions);
                
                % We display the product against the hadamardMatrix to estimate the
                % best candidate
                Z = hadamardMatrix*chips/(32*2*alpha/255);
                
                % softmax
                result = pottsOutput(Z);
                
                if ~isnan(result(1))
                    metric = max(result)/mean(result(result~=max(result)),'all');
                else
                    metric = 0;
                end
                
                METRIC(end+1) = metric;
                METRIC_TYPE(end+1) = anchor_type;
                [~,DECIDED_SYMBOL(end+1)] = max(result);
                
                if (~mod(histogram_count,10))
                    fprintf('Current Time: %1.2f\n', videoObject.CurrentTime);
                end
                histogram_count = histogram_count + 1;
                
            end
            save(sprintf('FPS%d_alpha%d_SIR%d', framesPerSymbol, alpha, sir),'METRIC', 'METRIC_TYPE','DECIDED_SYMBOL');
        end
    end
end