function frameBuffer = shiftBuffer (frameBuffer,frame)
% Es una cola FIFO de frames sobre la que actuas. ShiftBuffer es básicamente 
% hacer un desplazamiento de los elementos (o mover un puntero). 
frameBuffer = circshift(frameBuffer,1,4); 
frameBuffer(:,:,:,1) = frame;
end


