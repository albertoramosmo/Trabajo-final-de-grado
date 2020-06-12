
%%%%%%% CHANGE OF FRAMERATE AND GENERATION OF A VIDEO WITH SUCH FRAMERATE %%%%%%%
workingDir = tempname; mkdir(workingDir); 
mkdir(workingDir,'images');
shuttleVideo = VideoReader('playa.mp4');
ii = 1;  
while hasFrame(shuttleVideo)    
    img = readFrame(shuttleVideo);    
    filename = [sprintf('%03d',ii) '.jpg'];    
    fullname = fullfile(workingDir,'images',filename);    
    imwrite(img,fullname)
    ii = ii+1;
end
imageNames = dir(fullfile(workingDir,'images','*.jpg')); imageNames = {imageNames.name}';
outputVideo = VideoWriter('playa50','MPEG-4'); 
outputVideo.FrameRate = 50;         % FRAMERATE
open(outputVideo)
for ii = 1:length(imageNames)    
    img = imread(fullfile(workingDir,'images',imageNames{ii}));    
    writeVideo(outputVideo,img); 
end
close(outputVideo);
