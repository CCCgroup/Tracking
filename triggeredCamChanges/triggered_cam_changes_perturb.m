% TO DO:classify traces or parts of traces using the following
% parameters...
%
% -  Movement (start/stop), twitch (start), sitting still (all encoder-based)
% -  Perturbation (start)
% -  Tone (onset/termination)

function eventStore = triggered_cam_changes_perturb(folder, x1, x2, y1, y2, ploton)
% x1, x2, y1, y2. (Leftmost, rightmost, upper and lower pixel bounds)

% Check frame changes around perturbations
% Plot horizontal and vertical changes
% folder = uigetdir;

eventStore=[];
try
oldDir = cd;

cd(folder)

    load perturbations.mat
    %load toneTimes.mat
    %load analogChannels.mat
    %load motion_vector.mat
    if ~exist('bufferReady.mat','file')
        bufferReady = get_bufferReady;
    else
        load('bufferReady.mat');
    end
    
    perturbations = unique(perturbations);
    perturbations = perturbations(3:end);
    bufferReady   = bufferReady - 1;
    
    %[frametimes,mousePath] = processAnalogSignals(analogChannels);
catch
    disp('Files not found.')
end

stuff   = [];
perturb = [];

% try
for n = 1:length(perturbations)
    
    disp(['Working on iteration ' int2str(n) ' out of ' int2str(length(perturbations))]);
    
    % Take 200ms before perturbation and 800ms after
    if min(bufferReady) < (perturbations(n) - 200)
        if max(bufferReady) > (perturbations(n) + 800)
            
            if ((n < length(perturbations)) && (n > 1))
                
            if ((perturbations(n) + 800 < perturbations(n+1)) && (perturbations(n) - 200 > perturbations(n-1)))
            
            % match the required image files...
            for m = 22:(length(bufferReady)-79)
                if ((bufferReady(m-1) <= perturbations(n)) && (bufferReady(m) > perturbations(n)))
                    
                    theIndices = bufferReady((m-21):(m+79));
                    
                    stuff = [stuff theIndices];
                    perturb = [perturb perturbations(n)];
                    
                end
            end
            
            end
            
            elseif (n < length(perturbations))
                
                if (perturbations(n) + 800 < perturbations(n+1))
                    
                    for m = 22:(length(bufferReady)-79)
                        if ((bufferReady(m-1) <= perturbations(n)) && (bufferReady(m) > perturbations(n)))
                    
                        theIndices = bufferReady((m-21):(m+79));
                    
                        stuff = [stuff theIndices];
                        perturb = [perturb perturbations(n)];
                    
                        end
                    end
                    
                end
                
            elseif (n > 1)
                
                if (perturbations(n) - 200 > perturbations(n-1))
                    
                    for m = 22:(length(bufferReady)-79)
                        if ((bufferReady(m-1) <= perturbations(n)) && (bufferReady(m) > perturbations(n)))
                    
                            theIndices = bufferReady((m-21):(m+79));
                    
                            stuff = [stuff theIndices];
                            perturb = [perturb perturbations(n)];
                    
                        end
                    end
                    
                end
            end
            
        end
    end
    
end

% generate the images
dims = size(stuff);
size(stuff)
eventStore = cell(dims(2),1);

for n = 1:dims(2)
    
    disp(['Working on perturbation #' int2str(n)]);
    
    horzTrace = [];
    vertTrace = [];
    
    horzTraceAlt = [];
    vertTraceAlt = [];
    
    img = imread(strcat('img',num2str(stuff(1,n) +1),'.tif'));
    img = img(y1:y2,x1:x2);
    
    ref = 0 .* double(img);
        
    for q = 21:21
        img = double(imread(strcat('img',num2str(stuff(q,n)+1),'.tif')));
        img = img(y1:y2,x1:x2);
        img(img > 230) = 0;
        ref = ref + img;
    end
        
    %ref = ref ./ 1;
    ref = medfilt2(ref,[5 5]);
    
    for m = 1:dims(1)
        
        %disp(['Loading image: img' num2str(stuff(m,n)+1) '.tif']);
        img = imread(strcat('img',num2str(stuff(m,n) +1),'.tif'));
        img = img(y1:y2,x1:x2);
        
        img = double(img);
        img(img > 230) = 0;
        img = medfilt2(img,[5 5]);
        
        horz = sum(img,1)/max(sum(img,1));
        vert = sum(img,2)/max(sum(img,2));
        
        horzTrace = [horzTrace ; horz];
        vertTrace = [vertTrace   vert];
        
        horzAlt = sum(abs(img-ref),1)/max(sum(abs(img-ref),1));
        vertAlt = sum(abs(img-ref),2)/max(sum(abs(img-ref),2));
        
        horzTraceAlt = [horzTraceAlt ; horzAlt];
        vertTraceAlt = [vertTraceAlt   vertAlt];
        
    end
    
    img1 = imread(['img' num2str(stuff(21, n)+1) '.tif']);
    img2 = imread(['img' num2str(stuff(end,n)+1) '.tif']);
    
    img1 = img1(y1:y2,x1:x2);
    img2 = img2(y1:y2,x1:x2);
    
    img1 = double(img1);
    img2 = double(img2);
    
    img1(img1 > 230) = 0;
    img2(img2 > 230) = 0;
    
    img1 = medfilt2(img1,[5 5]);
    img2 = medfilt2(img2,[5 5]);
    
    img  = abs(img2 - img1);
    img  = img ./ max(max(img));
    
    % get per-position information on deviations for the baseline portion
    
    horzWeights = zeros(length(horzTraceAlt(1,:)),1);
    vertWeights = zeros(length(vertTraceAlt(:,1)),1);
    
    for m = 1:length(horzTraceAlt(1,:))
        
        horzWeights(m) = std(horzTraceAlt(1:20,m));
        
        if horzWeights(m) ~= 0
            horzWeights(m) = 1 / horzWeights(m);
        end
        
    end
    
    for m = 1:length(vertTraceAlt(:,1))
        
        vertWeights(m) = std(vertTraceAlt(m,1:20));
        
        if vertWeights(m) ~= 0
            vertWeights(m) = 1 / vertWeights(m);
        end
        
    end
    
    % using the acquired weight vectors, map the changes
    
    horzChange = zeros(101,1);
    vertChange = zeros(101,1);
    
    for m = 1:101
        
        horzTemp      = horzTraceAlt(m,:);
        horzTemp      = horzTemp .* horzWeights';
        horzChange(m) = nanmean(horzTemp);
        
        vertTemp      = vertTraceAlt(:,m);
        vertTemp      = vertTemp .* vertWeights;
        vertChange(m) = nanmean(vertTemp);
        
    end
    
%     horzChange = horzChange -  min(horzChange);
%     horzChange = horzChange ./ max(horzChange);
%     
%     vertChange = vertChange -  min(vertChange);
%     vertChange = vertChange ./ max(vertChange);
  
if(ploton)
    newplot = figure;
    s=0:1/256:1-(1/256);
    rgb1 =[0 0 1];
    rgb2=[1 0 0];
    cmap1 =  diverging_map(s,rgb1,rgb2);
    colormap(cmap1);
%    colormap(cmap1)
    
    subplot(4,2,1)
    hold on
    image(horzTrace .* 255)
    plot(1:(x2 - x1 + 1),21 .* ones((x2 - x1 + 1),1),'--w')
    hold off
    %colormap(gray(256))
    axis tight
    axis ij
    ylabel('frame number')
    title('Horizontal')
    
    subplot(4,2,2)
    hold on
    image(vertTrace' .* 255)
    plot(1:(y2 - y1 + 1),21 .* ones((y2 - y1 + 1),1),'--w')
    hold off
    %colormap(gray(256))
    axis tight
    axis ij
    ylabel('frame number')
    title('Vertical')
    
    subplot(4,2,3)
    hold on
    image(horzTraceAlt .* 255)
    plot(1:(x2 - x1 + 1),21 .* ones((x2 - x1 + 1),1),'--w')
    hold off
    colormap(cmap1)
    axis tight
    axis ij
    ylabel('frame number')
    
    subplot(4,2,4)
    hold on
    image(vertTraceAlt' .* 255)
    plot(1:(y2 - y1 + 1),21 .* ones((y2 - y1 + 1),1),'--w')
    hold off
    colormap(cmap1)
    axis tight
    axis ij
    ylabel('frame number')
    
    subplot(4,2,5:6)
    %colormap(gray(256))
    image(img .* 255)
    axis off
end

    change = (horzChange + vertChange) ./ 2;

if(ploton)
    subplot(4,1,4)
    hold on
    plot(change,'k','LineWidth',2)
    plot(1:101,(nanmean(change(1:20)) + (4*nanstd(change(1:20)))) .* ones(101,1),'--r')
    plot(1:101,(nanmean(change(1:20)) - (4*nanstd(change(1:20)))) .* ones(101,1),'--r')
    hold off
    axis tight
    title('normalized deviation from reference')
    xlabel('frame #')
    
    figure(newplot)
    colormap(cmap1)
end   

    eventStore{n}.horzTraceRaw = horzTrace;
    eventStore{n}.vertTraceRaw = vertTrace';
    eventStore{n}.horzTraceRef = horzTraceAlt;
    eventStore{n}.vertTraceRef = vertTraceAlt;
    eventStore{n}.camTimes     = stuff(:,n)+1;
    eventStore{n}.folder       = folder;
    eventStore{n}.horzChange   = horzChange;
    eventStore{n}.vertChange   = vertChange;
    eventStore{n}.change       = change;
    eventStore{n}.trigger      = perturb(n);
    eventStore{n}.trigger_type = 'perturbation';
    
    found = 0;
    
    for m = 25:101
        
        if ((change(m) > (nanmean(change(1:20)) + (4*nanstd(change(1:20))))) || ...
            (change(m) < (nanmean(change(1:20)) - (4*nanstd(change(1:20))))))
        
            if ~found
                eventStore{n}.twitchFrame = stuff(m,n) + 1;
                found = 1;
            end
        end
    end
    
    if ~found
        eventStore{n}.twitchFrame = NaN;
        eventStore{n}.twitch_x    = NaN;
        eventStore{n}.twitch_y    = NaN;
    else
        disp(['Twitch found in file: img' num2str(eventStore{n}.twitchFrame) '.tif']);
        
        % Get the maximum change location as follows...
        
        % Take twitch frame...
        twitchy = double(imread(['img' num2str(eventStore{n}.twitchFrame) '.tif']));
        twitchy = twitchy(y1:y2,x1:x2);
        twitchy = medfilt2(twitchy,[3 3]); % clean it up a bit
        
        % Subtract from the reference frame to get the difference (absolute value, no negatives)...
        diff_frame = abs(twitchy - ref);
        flat_x     = sum(diff_frame,1);
        flat_y     = sum(diff_frame,2);
        
        % using a 30-pixel sliding window, find the maximum in x and y direction
        
        score_x  = 0;
        score_y  = 0;
        
        for xdir = 1:(x2 - x1 - 28)
            if sum(flat_x(xdir:(xdir+29))) > score_x;
                score_x = sum( flat_x(xdir:(xdir+29)) );
                eventStore{n}.twitch_x = xdir;% + 99;     % take offset into account
            end
        end
        
        for ydir = 1:(y2 - y1 - 28)
            if sum(flat_y(ydir:(ydir+29))) > score_y;
                score_y = sum( flat_y(ydir:(ydir+29)) );
                eventStore{n}.twitch_y = ydir;          % no offset
            end
        end
    end
    
    eventStore{n}.referenceFrame = ref;
    
end

%save('twitches_perturb_triggered.mat', 'eventStore')

cd(oldDir)

%disp('-----')
disp(['Folder ' folder ' ...Done!'])
disp('-----')

% catch
%     
%     disp('ERROR happened trying the triggered_cam_changes_perturb function');
%     
% end
