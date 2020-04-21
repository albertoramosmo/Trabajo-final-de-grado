function [code] = codeCreation(codeRows,codeCols)
% Creamos el code entre 0 y 1 con un tamaño de codeSize.
code = randi([0, 1], [codeCols, codeRows]);
% Lo convertimos a -1 y 1.
code(code>1)   = 1.0;                           
code(code<=0)  = -1.0; 
end