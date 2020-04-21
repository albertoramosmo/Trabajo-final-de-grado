function writeBufferToFinalVideo(video, buffer)

% Esta función escribe el buffer en el video

% Iteramos sobre el número de frames del buffer
for i = 1:size(buffer,4)    
    img = buffer(:,:,:,i); 
    % Clipeamos aquellos pixels que pasen del rango dinámico
    img(img>1) = 1.0;                           
    img(img<0) = 0.0; 
    % Escribimos el frame en el vídeo
    writeVideo(video,img); 
end

end

