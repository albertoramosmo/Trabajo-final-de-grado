function [databits, nextPointer] = getDataToEncode(dataBuffer, ...
                                                   dataPointer, batchSize)
% This function gets the next databits to encode. If the buffer is full, it
% makes a zero padding including trailing zeroes. When it gets to the end,
% nextPointer is -1

if (dataPointer == 0)
    nextPointer = -1;
    databits = -1;
    return
end

L = length(dataBuffer);

% If the batch surpasses the buffer length, we trim it
if (dataPointer + batchSize -1 >= L)
    realBatchSize = L - dataPointer + 1;
    nextPointer = 0;
else % if not, we just keep things going
    realBatchSize = batchSize;
    nextPointer = dataPointer + batchSize;
end

databits = [dataBuffer(dataPointer:dataPointer+realBatchSize-1), ...
            zeros(1,batchSize-realBatchSize)];