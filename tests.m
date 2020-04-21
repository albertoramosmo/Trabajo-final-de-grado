% TESTS

%% canWeEncodeTest
% Creamos dos imagenes controladas, de tamaño 10x10 y 3 canales, para que
% la interferencia sea 20 dB (10 de diferencia en valor de pixel).
imgInicial = ones(10,10,3);
imgFinal = ones(10,10,3)*11;
frameBuffer = cat(4, imgInicial, imgFinal); % Concatena en la dimensión 4

alpha = 1; % Esto implica que la potencia de alfa será 4 (6 dB)

% La SIR esperada es del -14 dB approx

SIRestimada = 10*log10((2*alpha)^2 / mean((imgFinal - imgInicial).^2,'all'));

% Si fijamos el umbral en -15 debería devolver true, y si lo fijamos en -13
% debería devolver false, lo comprobamos.

assert(canWeEncode(frameBuffer, alpha, -15) == true);
assert(canWeEncode(frameBuffer, alpha, -13) == false);

fprintf('canWeEncode test passed\n');


%% shiftBufferTest
% En este caso podemos reutilizar el frameBuffer de arriba, y comprobar que
% al hacer el shiftBuffer con un frame de zeros, el de la primera posición
% es el frame nulo y el de la posición 1 es el de unos.
frameBuffer = shiftBuffer(frameBuffer, zeros(10,10,3));
assert(mean(frameBuffer(:,:,:,1),'all') == 0);
assert(mean(frameBuffer(:,:,:,end),'all') == 1);

fprintf('shiftBuffer test passed\n');

%% writeBufferToFinalVideo
% Vamos a escribir el buffer en un vídeo, leerlo y comprobar que la
% escritura ha sido correcta. Podemos reutilizar frameBuffer
video = VideoWriter('prueba.avi');
open(video);
writeBufferToFinalVideo(video, frameBuffer);
close(video);

% Ahora lo abrimos
video = VideoReader('prueba.avi');
% Sabemos que tiene dos frames...
readFrames = zeros(size(frameBuffer));
readFrames(:,:,:,1)=readFrame(video);
readFrames(:,:,:,end) = readFrame(video);
delete(video);

% Ahora comprobamos que readFrames y frameBuffer sean iguales, o realmente
% casi iguales por problemas de codificación con pérdidas.
% Dividimos por 255 porque al escribir, un double igual a 1.0 se interpreta
% como el valor 255 en uint8.
assert(mean(abs(double(readFrames)/255 - frameBuffer), 'all') < 0.001);
fprintf('writeBufferToFinalVideo test passed\n');

%% writeFrameToFinalVideo
% Repetimos la operación anterior, pero ahora con la función writeFrame...
% Vamos a crear un vídeo de un único frame, leerlo y comprobar
video = VideoWriter('prueba.avi');
open(video);
writeBufferToFinalVideo(video, frameBuffer(:,:,:,end));
close(video);

% Ahora lo abrimos
video = VideoReader('prueba.avi');
% Sabemos que tiene dos frames...
frame=readFrame(video);
delete(video);

% Ahora comprobamos que frame y frameBuffer(end) sean iguales, o realmente
% casi iguales por problemas de codificación con pérdidas.
% Dividimos por 255 porque al escribir, un double igual a 1.0 se interpreta
% como el valor 255 en uint8.
assert(mean(abs(double(frame)/255 - frameBuffer(:,:,:,end)), 'all') < 0.001);
fprintf('writeFrameToFinalVideo test passed\n');