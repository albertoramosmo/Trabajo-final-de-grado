function [cond,SIR]  = canWeEncode(frameBuffer,alpha,threshold)
% Devuelve true si se pueden meter datos teniendo en cuenta que el receptor
% los pueda decodificar bien,y siguiendo criterios de visibilidad del codigo.
% Se tiene que definir un estimador de la perceptibilidad del codigo por un
% lado, y luego otro estimador de la tasa de error en el receptor.
% - TASA DE ERROR: Se calcula asumiendo que el receptor pilla los cuadritos
%                  de código donde van.
% - SIR: Resta de frame final e inicial.

imgInicial = frameBuffer(:,:,:,1);
imgFinal   = frameBuffer(:,:,:,end);
imgdiff    = imgFinal - imgInicial;

% Interference Average Power
I = mean(imgdiff.^2,'all');

% Proportion es el numero de pixels que supera el umbral
condition_A = imgInicial(:,:,3)>=threshold;
condition_B = imgFinal(:,:,3)>=threshold;
proportion = sum(condition_A)+sum(condition_B);

% Signal Average Power (2 alpha es porque el código, al presentarse
% invertido en imgInicial e imgFinal, duplica su valor con la diferencia.
% Además, no hace falta el coeficiente 0.5 porque todos los bits tienen la
% misma energía).
S = 4*(alpha^2)*proportion;

% Calculate Signal-to-Interference-Ratio
SIR = 10*log10(S/I);

% Condition loop
% No hace falta hacer un if-else, ya que la salida es una comparación con
% un umbral.
cond = SIR >= threshold;
end