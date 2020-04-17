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

% Interference
I = mean(imgdiff.^2,'all');
% Signal Power
S = 0.5*alpha^2;
% Calculate Signal-to-Interference-Ratio
SIR = 10*log10(S/I);

% Condition loop
if (threshold<SIR<Inf)
    cond = true;
else
    cond = false;
end
end

