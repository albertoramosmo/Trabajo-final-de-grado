function shaping = getSymbolShape(framesPerSymbol, gamma)

base_slope = linspace(0,1,100);
base_symbol = [ base_slope, ... % Rise and half fall
                1 - base_slope(2:end)]; 

% We add nonlinear softening function
base_symbol = base_symbol.^gamma;
            
base_symbol = [base_symbol, -base_symbol];

% Now we decimate base_symbol attending to the ratio
% length(base_symbol)/framesPerSymbol

step = ceil(length(base_symbol)/framesPerSymbol);

shaping = base_symbol(1:step:framesPerSymbol*step);

end