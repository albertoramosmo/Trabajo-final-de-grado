function [cols,rows] = getBestColRowFit(codeLength)

% If it is a perfect square, rows = cols
if (rem(log2(codeLength),2) == 0)
    cols = sqrt(codeLength);
    rows = cols;
else % If not, we assume that cols = rows + 1
    rows = sqrt(codeLength/2);
    cols = 2*rows;
end
end