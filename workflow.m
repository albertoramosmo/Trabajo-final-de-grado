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
alpha   = 5;
N = 5;                      % Interpolation samples
thetha = 0.5;               % Spatial filter
tSymb = 0.1;                % Symbol time
threshold = -10;            % SIR threshold
framesPerSymbol = calculateFramesPerSymbol(fps,tSymb);

% Code size
codeRows = 20;  % era 64
codeCols = 20;
codeSize = codeRows*codeCols;

% frameBuffer
% This is needed for symbol creation using a space-time approach
frameBuffer = zeros(height,width,numChannels,framesPerSymbol);
framesInBuffer = 0;

while hasFrame(videoObject)
    frame = double(readFrame(videoObject));
    % We update the framesInBuffer counter
    framesInBuffer = framesInBuffer + 1;
    frameBuffer = double(shiftBuffer(frameBuffer,frame,framesInBuffer));

    if framesInBuffer > framesPerSymbol
        framesInBuffer = framesPerSymbol;
        bypassEncoding = false;
    else
        bypassEncoding = true;
    end
    if ~bypassEncoding
        if canWeEncode(frameBuffer,alpha,threshold)     % True condition
            encodedBuffer = steganographicEncoding(frameBuffer,width,height,codeRows,codeCols);
            writeBufferToFinalVideo(encodedBuffer);
        else                                            % False condition
            % Si no puedes codificar, debes escribir en el video el frame
            % mas viejo dentro de la FIFO. En principio es el primero de la
            % lista si insertamos por el final.
            writeFrameToFinalVideo(squeeze(frameBuffer(1,:,:,:)));
        end
    end
end
