function [encodedBuffer] = steganographicEncoding(frameBuffer,M,N,C,F)
% FUNCI�N QUE GENERA UN CROSSBOARD (N,M) CON UN CROSSBOARD (y_size,x_size).
% QUE SUS DIMENSIONES SON M Y N, Y EL NUMERO DE COLUMNAS ES C Y FILAS F.

% 'L1' y 'L2' ser� la subdivisi�n que se realizar�, el nuevo cuadrado que
% se generar�.
L1 = fix(M/C);
L2 = fix(N/F);

% 'leftover_L1' y 'leftover_L2' ser�n los restos de la divisi�n realizada por
% anchura/columnas y altura/filas.
leftover_L1 = mod(M,C);
leftover_L2 = mod(N,F);

if (rem(leftover_L1,2) == 0)                        % Resto L1 par.
    leftover_matrix_L1 = zeros(L2,(leftover_L1/2)); 
    mappedCell = crossboard(L1,L2,F,C);            % Como puede ser crossboard pudiera ser cualquier
                                                   % funci�n que me generara un c�digo.
    rowAdaptedInColumns = repmat(mappedCell, [1 C]);
    AdaptedInRows = [leftover_matrix_L1 rowAdaptedInColumns leftover_matrix_L1];
else                                                % Resto L1 impar.
    fake_leftover_matrix_L1 = zeros(L2,1);
    leftover_matrix_L1 = zeros(L2,(fix(leftover_L1/2)));
    mappedCell = crossboard(L1,L2,F,C);            % Cualquier funci�n generadora de c�digo.
    rowAdaptedInColumns = repmat(mappedCell, [1 C]);
    AdaptedInRows = [fake_leftover_matrix_L1 leftover_matrix_L1 rowAdaptedInColumns leftover_matrix_L1];
end

AdaptedInColumns = repmat(AdaptedInRows', [1 F]);

if (rem(leftover_L2,2) == 0)                        % Resto L2 par.
    leftover_matrix_L2 = zeros(fix(leftover_L2/2),M);
    mapped = [leftover_matrix_L2; AdaptedInColumns'; leftover_matrix_L2];
else                                                % Resto L2 impar.
    fake_leftover = zeros(1,M);
    leftover_matrix_L2 = zeros((fix(leftover_L2/2)),M);
    mapped = [fake_leftover; leftover_matrix_L2; AdaptedInColumns'; leftover_matrix_L2];
end
    encodedBuffer = frameBuffer + mapped;
end

