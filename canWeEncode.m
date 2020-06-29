function [cond,SIR]  = canWeEncode(frameBuffer, alpha, threshold, ...
                                   max_sensitivity, min_sensitivity, ...
                                   waveform)
% Devuelve true si se pueden meter datos teniendo en cuenta que el receptor
% los pueda decodificar bien,y siguiendo criterios de visibilidad del codigo.
% Se tiene que definir un estimador de la perceptibilidad del codigo por un
% lado, y luego otro estimador de la tasa de error en el receptor.
% Waveform se utiliza para obtener aquellos índices dentro del frameBuffer
% que maximizan la SIR. Sensitivity es el valor mínimo de señal que debe
% tener la imagen en el canal azul para asegurar que se detecta en la
% cámara.
% - TASA DE ERROR: Se calcula asumiendo que el receptor pilla los cuadritos
%                  de código donde van.
% - SIR: Resta de frame final e inicial.

[max_waveform, max_index] = max(waveform);
[min_waveform, min_index] = min(waveform);


imgInicial = frameBuffer(:,:,:,max_index);
imgFinal   = frameBuffer(:,:,:,min_index);
imgdiff    = imgFinal - imgInicial;

% Interference Average Power
I = mean(imgdiff.^2,'all');

% Proportion es el numero de pixels que supera el umbral
condition_A = (imgInicial(:,:,3)>=min_sensitivity) & ...
              (imgInicial(:,:,3)<=max_sensitivity);
          
condition_B = (imgFinal(:,:,3)>=min_sensitivity) & ...
              (imgFinal(:,:,3)<=max_sensitivity);
          
proportion = sum(condition_A & condition_B, 'all')/length(condition_A(:));

% Signal Average Power (2 alpha es porque el código, al presentarse
% invertido en imgInicial e imgFinal, duplica su valor con la diferencia.
% Además, no hace falta el coeficiente 0.5 porque todos los bits tienen la
% misma energía). 
% Se ha incluído el posible efecto de que la resta del código no sea
% perfecta debido a la forma de onda
S = proportion*(max_waveform - min_waveform)^2*alpha^2;

% Calculate Signal-to-Interference-Ratio
SIR = 10*log10(S/I);

% Condition loop
% No hace falta hacer un if-else, ya que la salida es una comparación con
% un umbral.
cond = SIR >= threshold;
end