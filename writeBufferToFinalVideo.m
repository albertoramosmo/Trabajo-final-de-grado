function [video] = writeBufferToFinalVideo(buffer)
video = VideoWriter('snailNuevo','MPEG-4'); 
video.FrameRate = 25; 
open(video)

for i = 1:size(buffer,4)    
    img = buffer(:,:,:,i); 
    img(img>1) = 1;                           
    img(img<0) = 0; 
    writeVideo(video,img); 
end
close(video);
end

