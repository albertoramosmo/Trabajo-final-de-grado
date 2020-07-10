function out = isBlackScreen(frame, data_positions)

frame = frame(round(data_positions(1,:)), round(data_positions(2,:)),:)/255;

out = mean(frame,'all') < 0.2;