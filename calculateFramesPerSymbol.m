function [framesPerSymbol] = calculateFramesPerSymbol(fps,t)
% Funci�n que tiene que devolver el numero de frames por s�mbolo
% teniendo en cuenta el time smoothing. Cuantos frames dura mi 
% s�mbolo en funci�n de mi filtrado temporal. 
framesPerSymbol=round(2*fps*(t*(1-0.5)));
% Ese 0.5 es el valor de thetha entre 0 y 1.
end

