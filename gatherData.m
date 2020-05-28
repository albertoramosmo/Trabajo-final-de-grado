function chips = gatherData(diff_frame, data_positions, window)

chips = zeros(size(data_positions,2),1);

for I = 1:length(data_positions)
    row = round(data_positions(1,I));
    col = round(data_positions(2,I));
    chips(I) = mean(diff_frame(row+window,col+window), 'all');
end