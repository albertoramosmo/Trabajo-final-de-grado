function data_positions = getDataPositions(boundaries, codeRows, codeCols)
% This function returns the sampling points given the ROI and the number of
% rows and cols of the code

% First of all we must sort the boundaries starting from the top-left one
boundaries = sortClockwise(boundaries);

% We define the rectilinear equations of the four segments. Take into
% account that boundaries are in (row, column) format
row_iterator = (0.5:1:codeRows)/codeRows;
col_iterator = (0.5:1:codeCols)/codeCols;

top_cols = boundaries(2,2)*col_iterator + (1 - col_iterator)*boundaries(1,2);
top_rows = boundaries(2,1)*col_iterator + (1 - col_iterator)*boundaries(1,1);

right_cols = boundaries(3,2)*row_iterator + (1 - row_iterator)*boundaries(2,2);
right_rows = boundaries(3,1)*row_iterator + (1 - row_iterator)*boundaries(2,1);

bottom_cols = boundaries(3,2)*col_iterator + (1 - col_iterator)*boundaries(4,2);
bottom_rows = boundaries(3,1)*col_iterator + (1 - col_iterator)*boundaries(4,1);

left_cols = boundaries(4,2)*row_iterator + (1 - row_iterator)*boundaries(1,2);
left_rows = boundaries(4,1)*row_iterator + (1 - row_iterator)*boundaries(1,1);


pos_row = zeros(1,codeRows*codeCols);
pos_col = zeros(size(pos_row));

iterator = 1;
for J = 1:length(col_iterator)
    for I = 1:length(row_iterator)
        
        % Matrix
        M = [bottom_rows(J) - top_rows(J), -(right_rows(I) - left_rows(I));
            bottom_cols(J) - top_cols(J), -(right_cols(I) - left_cols(I))];
        b = [left_rows(I) - top_rows(J); left_cols(I) - top_cols(J)];
        
        % kappa corresponds to rows and mu to cols
        kappa_mu = inv(M)*b;
        
        pos_row(iterator) = top_rows(J) + ...
            kappa_mu(1)*(bottom_rows(J) - top_rows(J));
        pos_col(iterator) = left_cols(I) + ...
            kappa_mu(2)*(right_cols(I) - left_cols(I));
        
        iterator = iterator + 1;
    end
end

data_positions = [pos_row;pos_col];
end