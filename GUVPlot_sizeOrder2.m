function [indiceTable, sliceTable, fractionTable, meanTable, ...
    backgroundMean, vesicles, pairs] = GUVPlot_sizeOrder2()

clearvars;
clc;

%Specify:
fileName = '05_20';
sheetName = 'Input';
ploting = 0;
xyTolerance = 40;
numPlot = 0;
timeInterval = 180/60;
timeTotal = 66 * timeInterval;
plotSomeVes = 0;
removeBurst = 0;
removeSomeVes = [];
radiusLimit = 5;
addSomeVes = [];


%Track vesicles
[vesicles, pairs, mean, backgroundMean] = GUVTracker_sizeOrder2(fileName,...
    sheetName, xyTolerance);
numSliceFound = vesicles(1, 2);
%data = xlsread(fileName, sheetName);

count = 0;
for i = 1 : length(vesicles(:, 1))
    if vesicles(i, 2) >= (timeTotal / timeInterval) * 0.6
       count = count + 1;
    end
end

v1 = vesicles(1 : count, :);
v2 = sortrows(v1, 5);
v3 = flipud(v2);

%Remove vesicles from v3 for those in RemoveSomeVes:
v4 = zeros(length(v3(:, 1))-length(removeSomeVes), length(v3(1,:)));
rowCount = 1;
if ~isempty(removeSomeVes)
   for i = 1 : length(v3)
       remove = 0;
       for j = 1 : length(removeSomeVes)
           if v3(i, 1) == removeSomeVes(j)
               remove = 1;
           end
       end
       
       if remove == 0
           v4(rowCount, :) = v3(i, :);
           rowCount = rowCount + 1;
       end
       
       remove = 0;
   end
else
    v4 = v3;
end

vesicles = v4;
indiceTable = zeros(numSliceFound, numPlot);
meanTable = zeros(numSliceFound, numPlot);
sliceTable = zeros(numSliceFound, numPlot);
fractionTable = zeros(numSliceFound, numPlot);
periCalcTable = zeros(1, numPlot);
%periTableCalc = zeros(1, numPlot);

for i = 1 : length(v4(:, 1))
    Pos1 = v4(i, 1);
    Pos2 = find(pairs(:, 4) == Pos1);
    
    periCalcTable(1, i) = v4(i, 5);
    
    indiceFound = zeros(numSliceFound, 1);
    count = 1;
    for k = 1:length(pairs(:, 1))
        if (pairs(k, 5) == Pos1) && (pairs(k, 9) == 0)
           indiceFound(count, 1) = k;
           count = count + 1;
        end
    end

    indiceFound = indiceFound(indiceFound ~=0);
    
    indice = [Pos1; Pos2(1, 1); indiceFound];
    indiceTable(1:length(indice), i) = indice;
    
    sliceTable(1, i) = pairs(Pos1, 2);
    sliceTable(2, i) = sliceTable(1, i) + 1;
    meanTable(1, i) = mean(Pos1, 1);
    meanTable(2, i) = mean(Pos2(1, 1), 1);
    fractionTable(1, i) = mean(Pos1, 1) / backgroundMean(1, 1);
    fractionTable(2, i) = mean(Pos2(1, 1), 1) / backgroundMean(2, 1);
    
    %Log slice number for each tracked vesicle
    for j = 1:length(indiceFound)
        sliceTable(2 + j, i) = pairs(indiceFound(j, 1), 2);
        meanTable(2 + j, i) = mean(indiceFound(j, 1));
        fractionTable(2 + j, i) = meanTable(2 + j, i) / ...
            backgroundMean(sliceTable(2 + j, i));
    end
end

%Remove bursted vesicles
burstTol = 0.2;

if (removeBurst == 1)
   [v5, sliceTable, fractionTable, periCalcTable, indiceTable, removed] = ...
       RemoveBurst(v4, sliceTable, fractionTable, periCalcTable, indiceTable, ...
       burstTol, timeInterval, addSomeVes, radiusLimit); 
else
    v5 = v4;
end


%Adjust number of vesicles to be plotted
if numPlot == 0
    numPlot = length(v5);
end

%Plot
if (ploting == 1)
    for i = 1:numPlot
       slice = sliceTable(:, i);
       xAxis = slice(slice ~= 0) .* timeInterval;

       fraction = fractionTable(:, i);
       yAxis = fraction(fraction ~= 0);

       diameter = round(periCalcTable(1, i) / pi);

       figure(1)
       subplot(ceil(sqrt(numPlot)), ceil(sqrt(numPlot)), i);
       plot(xAxis, yAxis);
       axis([0 inf, 0 1.1]);

       vesicleIndice = indiceTable (1, i);
       name = sprintf('#%d, dia%d', vesicleIndice, diameter);
       title(name);
    end
end

% Plot some influx
if plotSomeVes == 1
    vesiclesToPlot = [1644, 723, 41, 11, 41, 47, 8, 46];
    for i = 1 : length(vesiclesToPlot)
        vesiclePlot = vesiclesToPlot(i);
        indicePlot = find(indiceTable(1, :) == vesiclePlot);
        slice = sliceTable(:, indicePlot);
        xAxis = slice(slice ~= 0) .* timeInterval;

        fraction = fractionTable(:, indicePlot);
        yAxis = fraction(fraction ~= 0);

        figure(2)
        subplot(4, 2, i);
        plot(xAxis, yAxis, 'lineWidth', 4);
        axis([0 inf, 0 1]);
        set(gca, 'fontweight','bold', 'fontSize', 15);
    end

end


end
