function frameBuffer = shiftBuffer (frameBuffer,frame,framesInBuffer)
% Es una cola FIFO de frames sobre la que actuas. ShiftBuffer es b�sicamente 
% hacer un desplazamiento de los elementos (o mover un puntero).                
frameBuffer(:,:,:,framesInBuffer) = frame;
end




