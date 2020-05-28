function boundaries = sortClockwise(boundaries)
% First element is row, the second is column

% We calculate the center

center_row = mean(boundaries(:,1));
center_col = mean(boundaries(:,2));

% We get the corresponding angles respect to the center
angles = atan2(boundaries(:,2)-center_col, boundaries(:,1)-center_row)*180/pi;

angles(angles < 0) = angles(angles < 0) + 360;

% Now we sort angles accordingly. We must take into account that sorting
% here counterclockwise will result in a clockwise orientation in the image
% domain

first = find(angles >= 180 & angles < 270);
second = find(angles >= 90 & angles < 180);
third = find(angles > 0 & angles < 90);
fourth = find(angles >= 270);

boundaries = boundaries([first second third fourth],:);