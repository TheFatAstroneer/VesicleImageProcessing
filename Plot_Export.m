clc;

%Specify:
fileName = '05_15';
sheetName = 'Export8';
%time interval in seconds
timeInterval = 71;
%Gap
gap = 7;

%Import data
data = xlsread(fileName, sheetName);

numVesicles = floor(length(data(1, :)) / gap);
sliceMax = length(data(:, 1)) - 2;

for i = 1 : numVesicles
    vesicle = data(1, i * gap - gap + 1);
    volume = data(1, i * gap - gap + 5);
    D = (volume*3/4/pi)^(1/3);
    
    sliceList = data(3: end, i * gap - gap + 1);
    sliceList = sliceList(sliceList ~= 0);
    fractionList = data(3: end, i * gap - gap + 2);
    fractionList = fractionList(1: length(sliceList));

    %Plot
    subplot(ceil(sqrt(numVesicles)), ceil(sqrt(numVesicles)), i);
    t = sliceList.* timeInterval / 60;

    plot(t, fractionList)
    axis([0 inf 0 1.05])
    title(sprintf('#%.0f, D=%.0f um',vesicle,D), 'FontSize',8)
    xticks(0:100:max(t))
end   