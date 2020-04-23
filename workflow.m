%%%%%%% STEGANOGRAPHY WORKFLOW %%%%%%%
filename = 'mountain100.mp4';

% Video de entrada
videoObject = VideoReader(filename);

% Video de salida
outputVideo = VideoWriter('outputVideo.avi');
open(outputVideo);

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
            encodedBuffer = steganographicEncoding(frameBuffer,width,height,codeRows,codeCols,alpha,sigma,N);
            writeBufferToFinalVideo(outputVideo, encodedBuffer);
            % En este punto, ya que hemos escrito lengthBuffer frames y
            % hemos vaciado teóricamente el buffer, vamos a inicializar el
            % contador de frames en el buffer para que vuelva a llenarse.
            framesInBuffer = 0;
        else                                            % False condition
            % Si no puedes codificar, debes escribir en el video el frame
            % mas viejo dentro de la FIFO. Es el último de la lista ya que
            % hemos hecho una FIFO que "empuja" desde el principio.
            writeFrameToFinalVideo(outputVideo, squeeze(frameBuffer(:,:,:,end)));
        end
    end
end

close(outputVideo);

%%
v=VideoReader('outputVideo.avi');
while(hasFrame(v))
    imshow(readFrame(v));
end

