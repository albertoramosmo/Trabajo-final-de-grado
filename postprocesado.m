%% PROCESADO EXTREMO

clear
close
clc

folder = {'WALK'}; %{'FLOWER'}; %{'SEA','WALK','BIRDS','FLOWER'};

SIR = [10 50 90];
ALPHA = [3 5 10];
FRAMES = [7 14 27];

for folder_ = folder
    folder__ = folder_{1};
    
    for framesPerSymbol = FRAMES  
        for alpha = ALPHA
            for sir = SIR
                filename = sprintf('%s/%sFPS%d_alpha%d_SIR%d.mat', folder__, folder__, framesPerSymbol, alpha, sir)
                load(filename);
                
                current_state = -1;
                metric_symbols = [];
                metric_nosymbols = [];
                
                buffer = [];
                
                positions_red =         find(METRIC_TYPE == 0);
                positions_green =       find(METRIC_TYPE == 1);
                positions_nosymbol =    find(METRIC_TYPE == -1);
                
                edges_red =         diff(positions_red) == 1;
                edges_green =       diff(positions_green) == 1;
                edges_nosymbol =    diff(positions_nosymbol) == 1;
                
                blocks_red = find(edges_red ~= 1);
                blocks_green = find(edges_green ~= 1);
                blocks_nosymbol= find(edges_nosymbol ~= 1);
                
                for I = 1:length(blocks_red)-1
                    block = sort(METRIC(blocks_red(I):blocks_red(I+1)),'descend');
                    metric_symbols = [metric_symbols block(1)];
                    block(1:2) = [];
                    metric_nosymbols = [metric_nosymbols block];
                end
                
                for I = 1:length(blocks_green)-1
                    block = sort(METRIC(blocks_green(I):blocks_green(I+1)),'descend');
                    metric_symbols = [metric_symbols block(1)];
                    block(1:2) = [];
                    metric_nosymbols = [metric_nosymbols block];
                end
                
                for I = 1:length(blocks_nosymbol)-1
                    block = METRIC(blocks_nosymbol(I):blocks_nosymbol(I+1));
                    metric_nosymbols = [metric_nosymbols block];
                end
                
                [fs,xs] = ecdf(metric_symbols);
                [fns,xns] = ecdf(metric_nosymbols);
                
                plot(xs,fs); hold on; plot(xns,fns,'r');
                
                pause;
                close
            end
        end
    end
end