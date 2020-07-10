function anchor_type = gatherAnchor(frameBuffer, anchor_positions)

anchors = frameBuffer(round(anchor_positions(1,:)), round(anchor_positions(2,:)), 1:2);

M = mean(anchors,[1 2]);
S = std(anchors,0, [1 2]);

anchor_index = find(M>195);
anchor_condition = S(anchor_index) < 15;

if numel(anchor_index) == 0
    anchor_type = -1;
elseif numel(anchor_index) == 2
    anchor_type = -1;
else
    if anchor_condition
        anchor_type = anchor_index-1;
    else
        anchor_type = -1;
    end
end
