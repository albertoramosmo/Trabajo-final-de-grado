function writeBufferToFinalVideo(video, buffer)

% Esta función escribe el buffer en el video

% Iteramos sobre el número de frames del buffer
for i = 1:size(buffer,4)    
    img = buffer(:,:,:,i); 

    % Escribimos el frame en el vídeo
    writeVideo(video,uint8(img)); 
end

end

