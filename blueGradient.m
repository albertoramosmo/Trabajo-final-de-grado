rows = 3840;
columns = 2160;
black = zeros(columns, rows, 'uint8');
blueRamp = uint8(linspace(0, 255, rows));
% Make into 2-D image.
blueRamp = repmat(blueRamp, [columns, 1]);
rgbImage = cat(3, black, black, blueRamp);
imshow(rgbImage);
%% ------------------------------------------
I = imread('60.jpeg');
B = imread('120.jpeg');
plot(squeeze(I(50,:,3)));
plot(squeeze(B(50,:,3)));
%% ------------------------------------------



