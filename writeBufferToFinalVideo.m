function writeBufferToFinalVideo(video, buffer)

% Esta función escribe el buffer en el video

% Iteramos sobre el número de frames del buffer al revés (recuerda que es
% una cola FIFO y hay que escribir desde el último hasta el primero)
for i = size(buffer,4):-1:1
    % Escribimos el frame en el vídeo
    writeVideo(video,uint8(buffer(:,:,:,i))); 
end

end