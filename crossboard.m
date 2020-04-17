function [output] = crossboard(M,N,C,F)
% FUNCION QUE GENERA UN CROSSBOARD CON VALORES DE BLANCO 1 Y DE NEGRO -1
% QUE SUS DIMENSIONES SON M Y N, Y EL NUMERO DE COLUMNAS ES C Y FILAS F.

% 'L1' y 'L2' será el tamaño de la subdivisión que se realizará, el nuevo cuadrado que
% se generará.
L1 = fix(M/C);
L2 = fix(N/F);

% 'leftover_L1' y 'leftover_L2' serán los restos de la división realizada por
% anchura/columnas y altura/filas.
leftover_L1 = mod(M,C);
leftover_L2 = mod(N,F);

% Si el resto de la división de 'leftover_L1' entre 2 es 0, tendremos L1 par.
if (rem(leftover_L1,2) == 0)                        % Resto L1 par.
    leftover_matrix_L1 = zeros(L2,(leftover_L1/2)); % Creo una matriz de L2 de alto
                                                    % y leftover_L1 a la mitad para 
                                                    % meterlo a ambos lados.
    
    zeros_cell = ones(L2, L1, 'single')*(-1);       % Estos serán los valores 
    ones_cell = ones(L2, L1, 'single');             % que tenga el cross.
    
    % 1º TIPO DE FILA: EXTERNA
    % 'inter_columns_extrem_rows' serán los cuadrados negros del cross
    % de la 1º fila.
    intern_columns_extrem_rows = repmat(zeros_cell, [1 C-2]);
    
    % 'extrem_rows' será la primera y última fila.
    extrem_rows = [leftover_matrix_L1 ones_cell intern_columns_extrem_rows ones_cell leftover_matrix_L1];
    
    % 2º TIPO DE FILA: INTERNA
    % Creamos la matriz de unos de nuestro crossboard (parte blanca).
    intern_columns_extrem_rows = repmat(ones_cell, [1 C-2]);
    
    % Se mete el 'leftover_matrix_L1' por ser resto par y como está
    % dividido entre 2 se mete al principio y al final. Generamos la fila
    % interna.
    intern_rows = [leftover_matrix_L1 zeros_cell intern_columns_extrem_rows zeros_cell leftover_matrix_L1];
    
    % Repites la fila interna hasta generar la parte del crossboard
    % interno. 
    intern_crossboard = repmat(intern_rows', [1 F-2]);
    
else                                                   % Resto L1 impar. 
    leftover_matrix_L1 = zeros(L2,fix(leftover_L1/2)); % Ponemos el 'fix' por ser impar.
    fake_leftover = zeros(L2,1);                       % Es mi matriz 'falsa' porque es una sola porque el
                                                       % resto es impar.                                           
    
    zeros_cell = ones(L2, L1, 'single')*(-1);          % Lo mismo que arriba, valores establecidos.
    ones_cell = ones(L2, L1, 'single');
   
    % Básicamente, lo mismo que en el caso de PAR pero introduciendo la
    % columna falsa.
    intern_columns_extrem_rows = repmat(zeros_cell, [1 C-2]);
    extrem_rows = [fake_leftover leftover_matrix_L1 ones_cell intern_columns_extrem_rows ones_cell leftover_matrix_L1];
    intern_columns_extrem_rows = repmat(ones_cell, [1 C-2]);
    intern_rows = [fake_leftover leftover_matrix_L1 zeros_cell intern_columns_extrem_rows zeros_cell leftover_matrix_L1];
    intern_crossboard = repmat(intern_rows', [1 F-2]);
end

% Si el resto de la división de 'leftover_L2' entre 2 es 0, tendremos L2 par.
if (rem(leftover_L2,2) == 0)                           % Resto L2 par.
    leftover_matrix_L2 = zeros((leftover_L2/2),M);     % Creamos una matriz como en el caso de 'leftover_L1',
                                                       % la única diferencia es que rellenaremos cada M
                                                       % en vez de cada L2, como antes porque ya lo tenemos todo lleno.
                                                       
    % Creamos el crossboard para el caso par:                                                                                 
    output = [leftover_matrix_L2; extrem_rows; intern_crossboard'; extrem_rows; leftover_matrix_L2];
else                                                   % Resto L2 impar
    fake_leftover = zeros(1,M);                        % El 'fake' siempre lo meteremos cuando sea resto impar. 
    leftover_matrix_L2 = zeros((fix(leftover_L2/2)),M);% Es necesario el 'fix' por estar en el caso de resto impar.
    
    % Creamos el crossboard para el caso impar.
    output = [fake_leftover; leftover_matrix_L2; extrem_rows; intern_crossboard'; extrem_rows; leftover_matrix_L2];
end
end