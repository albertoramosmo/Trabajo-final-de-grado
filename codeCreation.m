function code = codeCreation(codeRows,codeCols)
% We randomly generate a bipolar code with values {-1,1}
code = 2.0*(1 - 0.5*randi([0, 1], [codeCols, codeRows]));
