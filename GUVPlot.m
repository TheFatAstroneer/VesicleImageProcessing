%Specify:
fileName = '05_16';
sheetName = 'Input_All';
xyTolerance = 40;
numPlot = 100;
timeInterval = 180/60;
maxMean = 160;

%Track vesicles
[vesicles, pairs, mean] = GUVTracker(fileName, ...
    sheetName, xyTolerance);

numSliceFound = vesicles(1, 2);
timeTotal = numSliceFound * timeInterval;

indiceTable = zeros(numSliceFound, numPlot);
meanTable = zeros(numSliceFound, numPlot);
sliceTable = zeros(numSliceFound, numPlot);

for i = 1 : numPlot
    Pos1 = vesicles(i, 1);
    Pos2 = find(pairs(:, 4) == Pos1);
    
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
    
    sliceTable(1, i) = 1;
    sliceTable(2, i) = 2;
    meanTable(1, i) = mean(Pos1, 1);
    meanTable(2, i) = mean(Pos2(1, 1), 1);
    
    %Log slice number for each tracked vesicle
    for j = 1:length(indiceFound)
        sliceTable(2 + j, i) = pairs(indiceFound(j, 1), 2);
        meanTable(2 + j, i) = mean(indiceFound(j, 1));
    end
end

%Plot
for i = 1:numPlot
   slice = sliceTable(:, i);
   xAxis = slice(slice ~= 0) .* timeInterval;
   
   meanList = meanTable(:, i);
   yAxis = meanList(1 : length(xAxis), 1);
   
   figure(1)
   subplot(ceil(sqrt(numPlot)), ceil(sqrt(numPlot)), i);
   plot(xAxis, yAxis);
   axis([0 inf, 0 maxMean]);
   
   vesicleIndice = indiceTable (1, i);
   name = sprintf('Vesicle %d', vesicleIndice);
   title(name);
end
