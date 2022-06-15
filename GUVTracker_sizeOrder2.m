function [vesicles, pairs, mean, backgroundMean] = GUVTracker(fileName, ...
    sheetName, xyTolerance)

%Input data from selected Excel file
input = xlsread(fileName, sheetName);

slice = input(1:end, 2);
x = input(1:end, 7);
y = input(1:end, 8);
peri = input(1:end, 9);
periCalc = input(1:end, 11);
mean = input(1:end, 4);
backgroundMean = input(1:end, 10);

total = length(slice);
numSlice = slice(end,1);

pairs = zeros(total, 9);
pairs(:,2) = slice;

%For each slice
for i = 2:numSlice
    indiceThisSlice = find(slice == i);
    numThisSlice = length(indiceThisSlice);
    indiceStartThis = indiceThisSlice(1, 1);
    indiceEndThis = indiceThisSlice(end, 1);
    
    %For each vesicle in this slice
    for j = indiceStartThis:indiceEndThis
        xThis = x(j, 1);
        yThis = y(j, 1);
        periThis = peri(j, 1);
        meanThis = mean(j, 1);
        
        pairs(j, 1) = j;
        pairs(j, 3) = meanThis;
        
        failCount = 0;
        paired = false;
        
        %Keep searching in previous slice until failing for 3 times
        while (failCount <= 3) && (i - failCount > 1) && (~paired)
            
            indicePrevSlice = find(slice == i - failCount - 1);
            indiceStartPrev = indicePrevSlice(1, 1);
            indiceEndPrev = indicePrevSlice(end, 1);
            
            firstEntry = true;
            errorPrev = inf;
            
            %Compare to each vesicle in previous slice
            for k = indiceStartPrev:indiceEndPrev
                xPrev = x(k, 1);
                yPrev = y(k, 1);
                periPrev = peri(k, 1);
                meanPrev = mean(k, 1);

                pairs(j, 7) = failCount;
                
                if (xPrev < xThis + xyTolerance) && (xPrev > xThis - ...
                        xyTolerance)
                    if (yPrev < yThis + xyTolerance) && (yPrev > ...
                            yThis - xyTolerance)
                        if (periPrev < periThis * 1.2) && (periPrev > ...
                                periThis * 0.8)

                            errorThis = (xThis - xPrev).^2 + (yThis - ...
                                yPrev).^2;

                            % Select the closest vesicle if more than one 
                            % found
                            if (errorThis <= errorPrev) || firstEntry
                                
                                paired = true;
                                pairs(j, 4) = k;
                                pairs(j, 6) = meanPrev;
                                pairs(j, 8) = errorThis;
                                
                                errorPrev = errorThis;
                                firstEntry = false;

                                if (pairs(k, 5) == 0)
                                    pairs(j, 5) = pairs(k, 4);
                                else
                                    pairs(j, 5) = pairs(k, 5);
                                end
                                
                                % Differentiate two adjacent vesicles
                                if (pairs(k, 9) == -1)
                                    pairs(j, 9) = -1;
                                end
                                
                                
                                %Check if the previous vesicle has been
                                %pair with other vesicles in this slice
                                for m = indiceStartThis:(j - 1)
                                    if (pairs(m, 4) == pairs(j, 4)) && ...
                                            ~(pairs(m, 4) == -1)
                                       if (errorThis < pairs(m, 8))
                                           %pairs(m, 5) = -1;
                                           pairs(m, 9) = -1;
                                       else
                                           %pairs(j, 5) = -1;
                                           pairs(j, 9) = -1;
                                       end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            if (~paired)
                failCount = failCount + 1;
            else
                failCount = 0;
            end
        end
    end
end

%Calculate and log number of pairs found
numFound = zeros(total, 5);

for i = 1:total
    numFound(i, 1) = i;
    count = 0;
    replicantCount = 0;
    periThis = 0;
    
    for j = 1:total
        if (pairs(j, 5) == i)
            if ~(pairs(j, 9) == -1)
                count = count + 1;
            else
                replicantCount = replicantCount + 1;
            end
        end
    end
    
    numFound(i, 2) = count;
    numFound(i, 3) = replicantCount;
    numFound(i, 4) = peri(i, 1);
    numFound(i, 5) = periCalc(i, 1);
end

vesiclesReverse = sortrows(numFound, 2);
vesicles = flipud(vesiclesReverse);


end
