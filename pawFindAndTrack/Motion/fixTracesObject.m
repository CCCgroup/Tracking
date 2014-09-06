% quick script to get new values to checkedTracesObject

fplTemp = [fillGaps(checkedTracesObject.fplFinal(:,1),100) fillGaps(checkedTracesObject.fplFinal(:,2),100) checkedTracesObject.fplFinal(:,3)];
fprTemp = [fillGaps(checkedTracesObject.fprFinal(:,1),100) fillGaps(checkedTracesObject.fprFinal(:,2),100) checkedTracesObject.fprFinal(:,3)];
hplTemp = [fillGaps(checkedTracesObject.hplFinal(:,1),100) fillGaps(checkedTracesObject.hplFinal(:,2),100) checkedTracesObject.hplFinal(:,3)];
hprTemp = [fillGaps(checkedTracesObject.hprFinal(:,1),100) fillGaps(checkedTracesObject.hprFinal(:,2),100) checkedTracesObject.hprFinal(:,3)];

% Redo stance? May solve earlier flukes...
fplStanceTemp = detectStance(fplTemp,mouseHist);
fprStanceTemp = detectStance(fprTemp,mouseHist);
hplStanceTemp = detectStance(hplTemp,mouseHist);
hprStanceTemp = detectStance(hprTemp,mouseHist);

[checkedTracesObject.fplAvgStride,checkedTracesObject.fplStrideDev,checkedTracesObject.fplMaxStride,checkedTracesObject.fplCount,checkedTracesObject.fplStrides] = detectStrides(fplTemp,fplStanceTemp,30);
[checkedTracesObject.fprAvgStride,checkedTracesObject.fprStrideDev,checkedTracesObject.fprMaxStride,checkedTracesObject.fprCount,checkedTracesObject.fprStrides] = detectStrides(fprTemp,fprStanceTemp,30);
[checkedTracesObject.hplAvgStride,checkedTracesObject.hplStrideDev,checkedTracesObject.hplMaxStride,checkedTracesObject.hplCount,checkedTracesObject.hplStrides] = detectStrides(hplTemp,hplStanceTemp,30);
[checkedTracesObject.hprAvgStride,checkedTracesObject.hprStrideDev,checkedTracesObject.hprMaxStride,checkedTracesObject.hprCount,checkedTracesObject.hprStrides] = detectStrides(hprTemp,hprStanceTemp,30);

% determine front paws base distances
[frontDist,frontMaxDist] = detectDistances(checkedTracesObject.fplFinal,checkedTracesObject.fprFinal);

% determine hind paws base distances
[ hindDist, hindMaxDist] = detectDistances(checkedTracesObject.hplFinal,checkedTracesObject.hprFinal);

checkedTracesObject.avgFrontBase = frontDist;
checkedTracesObject.maxFrontBase = frontMaxDist;
checkedTracesObject.avgHindBase  = hindDist;
checkedTracesObject.maxHindBase  = hindMaxDist;

clear fplTemp;
clear fprTemp;
clear hplTemp;
clear hprTemp;