function [framesPerSymbol] = calculateFramesPerSymbol(fps,t)
% Función que tiene que devolver el numero de frames por símbolo
% teniendo en cuenta el time smoothing. Cuantos frames dura mi 
% símbolo en función de mi filtrado temporal. 

framesPerSymbol=ceil(2*fps*(t*(1-0.5)));
% Ese 0.5 es el valor de thetha entre 0 y 1.
end

