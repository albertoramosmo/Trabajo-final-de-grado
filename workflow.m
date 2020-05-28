%% Trabajo Fin de Grado
% Author: Alberto Ramos Monagas
% Tutores: Rafael Perez-Jimenez y Victor Guerra
% Fecha: Abril 2020

% STEGANOGRAPHY WORKFLOW %
filename = 'mountain50.mp4';

% Video de entrada
videoObject = VideoReader(filename);

% Needed variables to carry out the encoding
fps     = videoObject.FrameRate;
width   = videoObject.Width;
height  = videoObject.Height;
numChannels = size(videoObject.readFrame,3);

% Video de salida
outputVideo = VideoWriter('outputVideo','MPEG-4');
%outputVideo = VideoWriter('outputVideo');
outputVideo.FrameRate = fps;
open(outputVideo);

% In this first approach we are using an absolute value for alpha, but it
% may take the form of a proportional value
alpha = 3;                  % Intensity
sigma = 15;                  % Spatial filter
threshold = 0;            % SIR threshold
sensitivity = 70;         % Minimum blue value to ensure detection

framesPerSymbol = 10; %calculateFramesPerSymbol(fps,tSymb);
shaping = getSymbolShape(framesPerSymbol, 0.5);

% We create a random number of data bits to encode, 1000 bits for instance
dataBuffer = randi([0,1], 1, 1000);
% Pointer to the next batch of data to encode
dataPointer = 1;

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

% frameBuffer
% This is needed for symbol creation using a space-time approach
frameBuffer = zeros(height,width,numChannels,framesPerSymbol);
framesInBuffer = 0;

while hasFrame(videoObject)
    
    frame = double(readFrame(videoObject));
    frameBuffer = shiftBuffer(frameBuffer,frame);
    
    % We update the framesInBuffer counter
    framesInBuffer = framesInBuffer + 1;
    fprintf('Fetched a new frame... %d/%d\n',...
        framesInBuffer, ...
        framesPerSymbol);
    
    % We have filled the buffer
    if framesInBuffer < framesPerSymbol
        fprintf('Frame buffer not full yet...\n');
        bypassEncoding = true;
    else
        bypassEncoding = false;
    end
    
    % If dataPointer<0,  it means that we have reached the end
    if (dataPointer < 0)
        fprintf('All data already encoded...\n');
        bypassEncoding = true;
    end
    
    if ~bypassEncoding
        [goEncode, calculatedSIR] = canWeEncode(frameBuffer, alpha, ...
                                                threshold, sensitivity,...
                                                shaping);
        fprintf('Current SIR: %f -->',calculatedSIR);
        if goEncode
            
            % If we can endode, we pull some data bits
            [databits, dataPointer] = getDataToEncode(dataBuffer, dataPointer, batchSize);
            
            fprintf('Encoding bits...\n');
            encodedBits = hadamardEncode(databits, hadamardMatrix);
            bypassEncoding = false;
            
            fprintf('SIR is good enough, encoding data...\n');
            encodedBuffer = steganographicEncoding(frameBuffer,...
                encodedBits,...
                alpha,...
                sigma, shaping);
            
            writeBufferToFinalVideo(outputVideo, encodedBuffer);
            
            % En este punto, ya que hemos escrito lengthBuffer frames y
            % hemos vaciado teóricamente el buffer, vamos a inicializar el
            % contador de frames en el buffer para que vuelva a llenarse.
            framesInBuffer = 0;
        else
            fprintf('SIR is poor, writing data without encoding...\n');
            % Si no puedes codificar, debes escribir en el video el frame
            % mas viejo dentro de la FIFO. Es el último de la lista ya que
            % hemos hecho una FIFO que "empuja" desde el principio.
            writeFrameToFinalVideo(outputVideo, squeeze(frameBuffer(:,:,:,end)));
            framesInBuffer = framesInBuffer - 1;
        end
    end
    
    fprintf('\n');
end

close(outputVideo);

