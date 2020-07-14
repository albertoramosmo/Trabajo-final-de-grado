function chips = gatherData(buffer, data_positions, max_pos, min_pos, window)

chips = zeros(size(data_positions,2),1);
initial_frame = buffer(:,:,max_pos)/255;
last_frame = buffer(:,:,min_pos)/255;

% Now we get the difference
diff_frame = initial_frame - last_frame;

for I = 1:length(data_positions)
    row = round(data_positions(1,I));
    col = round(data_positions(2,I));
    chips(I) = mean(diff_frame(row+window,col+window), 'all');
end
