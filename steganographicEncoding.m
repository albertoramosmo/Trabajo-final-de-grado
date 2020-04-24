function [encodedBuffer] = steganographicEncoding(frameBuffer,width,height,codeCols,codeRows,alpha,sigma,N)

% 'L1' y 'L2' será la subdivisión que se realizará, el nuevo cuadrado que
% se generará.
L1 = fix(width/codeCols);
L2 = fix(height/codeRows);

% 'leftover_L1' y 'leftover_L2' serán los restos de la división realizada por
% anchura/columnas y altura/filas.
leftover_L1 = mod(width,codeCols);
leftover_L2 = mod(height,codeRows);

if (rem(leftover_L1,2) == 0)                        % Resto L1 par.
    leftover_matrix_L1 = zeros(L2,(leftover_L1/2));
    mappedCell = codeCreation(L1,L2);            % Función generadora de código
    % función que me generara un código.
    rowAdaptedInColumns = repmat(mappedCell, [1 codeCols]);
    AdaptedInRows = [leftover_matrix_L1 rowAdaptedInColumns leftover_matrix_L1];
else                                                % Resto L1 impar.
    fake_leftover_matrix_L1 = zeros(L2,1);
    leftover_matrix_L1 = zeros(L2,(fix(leftover_L1/2)));
    mappedCell = codeCreation(L1,L2);             % Función generadora de código
    rowAdaptedInColumns = repmat(mappedCell, [1 codeCols]);
    AdaptedInRows = [fake_leftover_matrix_L1 leftover_matrix_L1 rowAdaptedInColumns leftover_matrix_L1];
end

AdaptedInColumns = repmat(AdaptedInRows', [1 codeRows]);

if (rem(leftover_L2,2) == 0)                        % Resto L2 par.
    leftover_matrix_L2 = zeros(fix(leftover_L2/2),width);
    mapped = imgaussfilt([leftover_matrix_L2; AdaptedInColumns'; leftover_matrix_L2],sigma);
else                                                % Resto L2 impar.
    fake_leftover = zeros(1,width);
    leftover_matrix_L2 = zeros((fix(leftover_L2/2)),width);
    mapped = imgaussfilt([fake_leftover; leftover_matrix_L2; AdaptedInColumns'; leftover_matrix_L2],sigma);
end

codeAlpha = mapped*alpha;
bufferSize = size(frameBuffer,4);
numChannels = size(frameBuffer,3);
time = linspace(-1, 1, N);
frames = cat(4,zeros([size(codeAlpha),numChannels,bufferSize]));

for i = 1:length(time)
    frames(:,:,:,i) = codeAlpha.*time(i) + codeAlpha.*(1-time(i))*(-1);
end
for i =1:bufferSize
    encodedBuffer = frameBuffer + frames;
end
end
