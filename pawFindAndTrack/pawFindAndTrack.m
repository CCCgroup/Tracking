
%% pawFindAndTrack
if(isunix)
    cd ~/Desktop/ 
end

clear
clc

% get user to indicate folder
folder = uigetdir;

cd(folder)

disp('---=%%&%%=---')

% perform background subtraction on all images (previously used LabVIEW for this)
[frames,backImg,indices, files] = backgroundSubtract(folder);


disp('---=%%&%%=---')

h = figure;

imshow(backImg / max(max(backImg)))
brighten(0.4)
title('Click to indicate 20 positions along the edge of the disc...');
[x, y] = ginput(20);
circleFit = CircleFitByTaubin([x y]);

figure(h)
hold on
image(backImg);
circplot(circleFit(1),circleFit(2),circleFit(3))
hold off
%brighten(0.2)
title(folder)

mm_per_pixel = 130 / circleFit(3); % disc radius is 130mm, radius in pixels is circleFit(3)
pause(2);
close(h);

setCriteria

disp('Use the GUI to set threshold and object size for further processing.')
disp('Use the command "return" to continue the program when done with the GUI.')

keyboard

save('temp.mat')

frameSelector

disp('Use the GUI to specify which part of the image sequence to process.')
disp('Use the command "return" to continue the program when done with the GUI.')

keyboard

save('temp.mat')

disp('---=%%&%%=---')

%define train set size
trainSetSize = max([150 round(0.15 * (lastFrame - firstFrame + 1))]);

trainSetSize

% disp('waiting for user input  - just showed trainSetSize');
% pause;

% limit trainSet to 300 frames
if trainSetSize > 300
    trainSetSize = 300;
end

%frameSeq = firstFrame:lastFrame;

% detect all objects matching the criteria (previously used LabVIEW for this)
theObjects = detectAllObjects(folder,criterion,threshold,firstFrame,lastFrame);

disp('Saving "theObjects.mat"...')

save('theObjects.mat','theObjects');
save('temp.mat')

disp('...saved');

disp('---=%%&%%=---')

% match objects to form traces...
traces = makeTraceSnippets(theObjects,folder);

save('temp.mat')

figure(1)
clf
subplot(3,1,1)
hold on
image(backImg)
colormap(gray(256))

for i = 1:length(traces)
    
    plot(traces{i}.x,traces{i}.y,'r')
    
end

hold off
title('Background image with all trace snippets superimposed.')
axis([1 511 1 255]);
axis ij;
axis off;

clear i

disp('---=%%&%%=---')

disp('Creating training set for paw classification algorithm.')

% REWRITE INDICES TO INCLUDE ONLY FIRSTFRAME:LASTFRAME RANGE

indices_cleaned = [];

for i = 1:length(indices)
    
    if ((indices(i) >= firstFrame) && (indices(i) <= lastFrame))
        indices_cleaned = [indices_cleaned ; indices(i)];
    end
end

size(indices_cleaned)
disp('just showed indices_cleaned size');
% select a random set of training frame integers
trainFrames = randi([firstFrame lastFrame],[(trainSetSize), 1]);

% trainFrames = randi([firstFrame lastFrame],[(trainSetSize - length(indices_cleaned)), 1]);
% trainFrames = unique([trainFrames ; indices_cleaned]);
trainFrames = unique(trainFrames);

size(trainFrames)
disp('just showed trainFrames size');


save('temp.mat')

disp('---=%%&%%=---')

disp('Use the GUI to manually classify objects in the training set.')
disp('The training set will then be used to train the automated classification algorithm.')
disp('Use the command "return" to continue the program when done with the GUI.')

trainingSetClassify

keyboard

disp('Saving the training set data as: ');
disp(['     ' folder filesep 'Paws' filesep 'training.mat']);
save([folder filesep 'Paws' filesep 'training.mat'],'trainFrames','trainingOutput');
save('temp.mat')

disp('Continuing program...')

    disp('---=%%&%%=---')

        newTraces = findTraceMatches(traces,trainFrames,trainingOutput,theObjects);

    disp('---=%%&%%=---')

    save('temp.mat')

    figure(1)
    subplot(3,1,2)
    hold on

    image(backImg)
    colormap(gray(256))

    for n = 1:length(newTraces)

        if newTraces{n}.class == 0
            % plot(newTraces{n}.x,newTraces{n}.y,'k')
        else if newTraces{n}.class == 1
                plot(newTraces{n}.x,newTraces{n}.y,'c')
            else if newTraces{n}.class == 2
                    plot(newTraces{n}.x,newTraces{n}.y,'r')
                else if newTraces{n}.class == 3
                        plot(newTraces{n}.x,newTraces{n}.y,'g')
                    else if newTraces{n}.class == 4
                            plot(newTraces{n}.x,newTraces{n}.y,'b')
                        else if newTraces{n}.class == 5
                                plot(newTraces{n}.x,newTraces{n}.y,'m')
                            else if newTraces{n}.class == 6
                                    plot(newTraces{n}.x,newTraces{n}.y,'y')
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    hold off

    axis([1 511 1 255])
    axis ij
    axis off
    title('Background image with training set superimposed.')

    [trainingMatrix,desiredOutput,classifyMatrix] = constructTrainingMatrices(newTraces);

    disp('---=%%&%%=---')

    save('temp.mat')

    disp('Setting the neural network loose on the data...');

% initialize and train network
net = newff(trainingMatrix',desiredOutput',[8 6]);
net = train(net,trainingMatrix',desiredOutput');

% generate classification output
result      = sim(net,classifyMatrix');

% disambiguate the results
resultFinal = winnerTakesAll(result);

% store the result in the newTraces variable
finalTraces = classAllocation(newTraces,resultFinal);

disp('Classification complete.')

save('temp.mat')
   
disp('---=%%&%%=---')

% for every class, reconstruct the path
[fpl,fpr,hpl,hpr,tail] = getTraces(finalTraces);

fpl  = cleanuptrace( fpl,20);
fpr  = cleanuptrace( fpr,20);
hpl  = cleanuptrace( hpl,20);
hpr  = cleanuptrace( hpr,20);
tail = cleanuptrace(tail,20);

% plot results
figure(1)
subplot(3,1,3)

hold on

image(backImg)
colormap(gray(256))

for n = 1:length(finalTraces)
    if finalTraces{n}.class == 1
        plot(finalTraces{n}.x,finalTraces{n}.y,'c')
    else if finalTraces{n}.class == 2
            plot(finalTraces{n}.x,finalTraces{n}.y,'r')
        else if finalTraces{n}.class == 3
                plot(finalTraces{n}.x,finalTraces{n}.y,'g')
            else if finalTraces{n}.class == 4
                    plot(finalTraces{n}.x,finalTraces{n}.y,'b')
                else if finalTraces{n}.class == 5
                        plot(finalTraces{n}.x,finalTraces{n}.y,'m')
                    else if finalTraces{n}.class == 6
                            plot(finalTraces{n}.x,finalTraces{n}.y,'y')
                        end
                    end
                end
            end
        end
    end
end

hold off

axis([1 511 1 255])
axis ij
axis off
title('Background image with all trace snippets after classification.')

disp('Getting statistics...')

% determine tail average position
tailAvg   = [nanmean(tail(:,1)) nanmean(tail(:,2))];

load([folder filesep 'analogChannels.mat'])
load([folder filesep 'bufferReady.mat'])

try
    frames_BKP = frames;
    load([folder filesep 'imageStorage.mat']);
    bufferReady = frames;
    frames = frames_BKP;
    clear frames_BKP
catch
end
    

[frames2P, mousePath,~] = processAnalogSignals(analogChannels);
length(mousePath)
length(bufferReady-1)
mouseHist = binMouse_v2(bufferReady-1,mousePath);

fpl       = fillGaps(fpl,10);
fpr       = fillGaps(fpr,10);
hpl       = fillGaps(hpl,10);
hpr       = fillGaps(hpr,10);

fplStance = detectStance(fpl,mouseHist); % <-- error? possible index out of bounds due to size mismatch of fpl and mouseHist
fprStance = detectStance(fpr,mouseHist);
hplStance = detectStance(hpl,mouseHist);
hprStance = detectStance(hpr,mouseHist);

%  create stance-corrected traces
fplFinal      = zeros(size(fpl));
fplFinal(:,1) = fpl(:,1) .* fplStance(:,1);
fplFinal(:,2) = fpl(:,2) .* fplStance(:,1);
fplFinal(:,3) = fpl(:,3) .* fplStance(:,1);

fprFinal      = zeros(size(fpr));
fprFinal(:,1) = fpr(:,1) .* fprStance(:,1);
fprFinal(:,2) = fpr(:,2) .* fprStance(:,1);
fprFinal(:,3) = fpr(:,3) .* fprStance(:,1);

hplFinal      = zeros(size(hpl));
hplFinal(:,1) = hpl(:,1) .* hplStance(:,1);
hplFinal(:,2) = hpl(:,2) .* hplStance(:,1);
hplFinal(:,3) = hpl(:,3) .* hplStance(:,1);

hprFinal      = zeros(size(hpr));
hprFinal(:,1) = hpr(:,1) .* hprStance(:,1);
hprFinal(:,2) = hpr(:,2) .* hprStance(:,1);
hprFinal(:,3) = hpr(:,3) .* hprStance(:,1);

for n = 1:lastFrame
    
    if fplFinal(n,1) == 0
       fplFinal(n,:) = fplFinal(n,:) .* NaN;
    end
    
    if fprFinal(n,1) == 0
       fprFinal(n,:) = fprFinal(n,:) .* NaN;
    end
    
    if hprFinal(n,1) == 0
       hprFinal(n,:) = hprFinal(n,:) .* NaN;
    end
    
    if hplFinal(n,1) == 0
       hplFinal(n,:) = hplFinal(n,:) .* NaN;
    end
    
end

% determine stride lengths
[fplAvgStride,fplMaxStride,fplCount,fplStrides] = detectStrides(fplFinal,fplStance,30);
[fprAvgStride,fprMaxStride,fprCount,fprStrides] = detectStrides(fprFinal,fprStance,30);
[hplAvgStride,hplMaxStride,hplCount,hplStrides] = detectStrides(hplFinal,hplStance,30);
[hprAvgStride,hprMaxStride,hprCount,hprStrides] = detectStrides(hprFinal,hprStance,30);

% determine front paws base distances
[frontDist,frontMaxDist] = detectDistances(fplFinal,fprFinal);

% determine hind paws base distances
[ hindDist, hindMaxDist] = detectDistances(hplFinal,hprFinal);

tracesObject.fplFinal = fplFinal;
tracesObject.fprFinal = fprFinal;
tracesObject.hplFinal = hplFinal;
tracesObject.hprFinal = hprFinal;
tracesObject.tail     = tail;

tracesObject.avgFrontBase = frontDist;
tracesObject.maxFrontBase = frontMaxDist;
tracesObject.avgHindBase  = hindDist;
tracesObject.maxHindBase  = hindMaxDist;

tracesObject.fplAvgStride = fplAvgStride;
tracesObject.fplMaxStride = fplMaxStride;
tracesObject.fplCount     = fplCount;
tracesObject.fplStrides   = fplStrides;

tracesObject.fprAvgStride = fprAvgStride;
tracesObject.fprMaxStride = fprMaxStride;
tracesObject.fprCount     = fprCount;
tracesObject.fprStrides   = fprStrides;

tracesObject.hplAvgStride = hplAvgStride;
tracesObject.hplMaxStride = hplMaxStride;
tracesObject.hplCount     = hplCount;
tracesObject.hplStrides   = hplStrides;

tracesObject.hprAvgStride = hprAvgStride;
tracesObject.hprMaxStride = hprMaxStride;
tracesObject.hprCount     = hprCount;
tracesObject.hprStrides   = hprStrides;

figure(2)
clf

subplot(2,2,1)
hold on
plot((bufferReady(firstFrame:lastFrame) - min(bufferReady)) ./ 1000 , hpr(firstFrame:lastFrame)     ,'k')
plot((bufferReady(firstFrame:lastFrame) - min(bufferReady)) ./ 1000 , hprFinal(firstFrame:lastFrame),'b')
hold off
title('Hind paw right')
xlabel('Time (s)')
ylabel('Pixel position (x)')

subplot(2,2,2)
hold on
plot((bufferReady(firstFrame:lastFrame) - min(bufferReady)) ./ 1000 , fpr(firstFrame:lastFrame)     ,'k')
plot((bufferReady(firstFrame:lastFrame) - min(bufferReady)) ./ 1000 , fprFinal(firstFrame:lastFrame),'r')
hold off
title('Front paw right')
xlabel('Time (s)')
ylabel('Pixel position (x)')

subplot(2,2,3)
hold on
plot((bufferReady(firstFrame:lastFrame) - min(bufferReady)) ./ 1000 , hpl(firstFrame:lastFrame)     ,'k')
plot((bufferReady(firstFrame:lastFrame) - min(bufferReady)) ./ 1000 , hplFinal(firstFrame:lastFrame),'g')
hold off
title('Hind paw left')
xlabel('Time (s)')
ylabel('Pixel position (x)')

subplot(2,2,4)
hold on
plot((bufferReady(firstFrame:lastFrame) - min(bufferReady)) ./ 1000 , fpl(firstFrame:lastFrame)     ,'k')
plot((bufferReady(firstFrame:lastFrame) - min(bufferReady)) ./ 1000 , fplFinal(firstFrame:lastFrame),'c')
hold off
title('Front paw left')
xlabel('Time (s)')
ylabel('Pixel position (x)')

for n = 1:lastFrame
    
    if hprStance(n,1) == 0
       hprStance(n,1) = NaN;
    end
    
    if fprStance(n,1) == 0
       fprStance(n,1) = NaN;
    end
    
    if hplStance(n,1) == 0
       hplStance(n,1) = NaN;
    end
    
    if fplStance(n,1) == 0
       fplStance(n,1) = NaN;
    end
    
end

tracesObject.fplStance = fplStance;
tracesObject.fprStance = fprStance;
tracesObject.hplStance = hplStance;
tracesObject.hprStance = hprStance;

figure(3)
clf

hold on
plot((bufferReady(firstFrame:lastFrame) - min(bufferReady)) ./ 1000 , hprStance(firstFrame:lastFrame) .* 4,'b')
plot((bufferReady(firstFrame:lastFrame) - min(bufferReady)) ./ 1000 , fprStance(firstFrame:lastFrame) .* 3,'r')
plot((bufferReady(firstFrame:lastFrame) - min(bufferReady)) ./ 1000 , hplStance(firstFrame:lastFrame) .* 2,'g')
plot((bufferReady(firstFrame:lastFrame) - min(bufferReady)) ./ 1000 , fplStance(firstFrame:lastFrame) .* 1,'c')
axis([((bufferReady(firstFrame) - min(bufferReady)) / 1000) ((bufferReady(lastFrame) - min(bufferReady)) / 1000) -5 10])
%axis off
title('Stance times')
xlabel('Time')
hold off

save([folder filesep 'tracesobject.mat'],'tracesObject')

save('temp.mat')

disp('Use the GUI to remove wrongly classified objects.')
disp('Use the command "return" to continue the program when done with the GUI.')

checkClassification();

keyboard

fixTracesObject;

disp('Done!')

disp('---=%%&%%=---')

% save results
disp('Saving all results as:')
disp(['     ' folder filesep 'Paws' filesep 'result.mat'])
save([folder filesep 'Paws' filesep 'result.mat'])
save([folder filesep 'tracesobject.mat'],'tracesObject')
save([folder filesep 'tracesobject-checked.mat'],'checkedTracesObject')