%%%%%%% STEGANOGRAPHY WORKFLOW %%%%%%%
filename = 'mountain100.mp4';
videoObject = VideoReader(filename);

% State Machine Status
% AllowedValues = {waitForData, fillingBuffer, checkingSuitability, encodingData, etc...}
% The FSM must take into account the incoming data and how its encoding
% could affect the frame from a user's point of view.
status = 'waitForData';

% Needed variables to carry out the encoding
fps     = videoObject.FrameRate;
width   = videoObject.Width;
height  = videoObject.Height;
numChannels = size(videoObject.readFrame,3);
alpha = 5;                  % Intensity
N = 5;                      % Interpolation samples
sigma = 0.5;                % Spatial filter
tSymb = 0.05;               % Symbol time
threshold = -10;            % SIR threshold

framesPerSymbol = calculateFramesPerSymbol(fps,tSymb);

% Code size
codeRows = 20;
codeCols = 20;
codeSize = codeRows*codeCols;

% frameBuffer
% This is needed for symbol creation using a space-time approach
frameBuffer = zeros(height,width,numChannels,framesPerSymbol);
framesInBuffer = 0;

while hasFrame(videoObject)
    frame = double(readFrame(videoObject));
    frameBuffer = shiftBuffer(frameBuffer,frame);
    % We update the framesInBuffer counter
    framesInBuffer = framesInBuffer + 1;
    
    if framesInBuffer > framesPerSymbol
        framesInBuffer = framesPerSymbol;
        bypassEncoding = false;
    else
        bypassEncoding = true;
    end
    if ~bypassEncoding
        if canWeEncode(frameBuffer,alpha,threshold)     % True condition
            encodedBuffer = steganographicEncoding(frameBuffer,width,height,codeRows,codeCols,alpha,sigma);
            writeBufferToFinalVideo(encodedBuffer,100);
        else                                            % False condition
            % Si no puedes codificar, debes escribir en el video el frame
            % mas viejo dentro de la FIFO. En principio es el primero de la
            % lista si insertamos por el final.
            writeFrameToFinalVideo(squeeze(frameBuffer(:,:,:,1)));
        end
    end
end
%%
v=VideoReader('prueba.mp4');
while(hasFrame(v))
    imshow(readFrame(v));
end

