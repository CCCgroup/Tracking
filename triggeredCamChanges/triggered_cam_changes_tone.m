% TO DO:classify traces or parts of traces using the following
% parameters...
%
% -  Movement (start/stop), twitch (start), sitting still (all encoder-based)
% -  Perturbation (start)
% -  Tone (onset/termination)

function eventStore_tone = triggered_cam_changes_tone(folder, x1, x2, y1, y2, ploton)
% x1, x2, y1, y2. (Leftmost, rightmost, upper and lower pixel bounds)

% Check frame changes around perturbations
% Plot horizontal and vertical changes

eventStore_tone=[];

oldDir = cd;
cd(folder)

try
    load toneTimes.mat
    %load analogChannels.mat
    %load motion_vector.mat
    if ~exist('bufferReady.mat','file')
        bufferReady = get_bufferReady;
    else
        load('bufferReady.mat');
    end
    
    % use the tone onsets as triggers
    toneTimes = unique(toneTimes);
    %note that first value is 0 in loaded toneTimes.mat
    toneTimes = toneTimes(2:end);
    toneTimes = toneTimes(1:2:end)

    
    bufferReady   = bufferReady - 1;
    
    %[frametimes,mousePath] = processAnalogSignals(analogChannels);
catch
    disp('Files not found.')
end

stuff   = [];
tone = [];

try
for n = 1:length(toneTimes)
    
    disp(['Working on iteration ' int2str(n) ' out of ' int2str(length(toneTimes))]);
    
    % Take 200ms before perturbation and 800ms after
    if min(bufferReady) < (toneTimes(n) - 200)
        if max(bufferReady) > (toneTimes(n) + 800)
            
            if ((n < length(toneTimes)) && (n > 1))
                
            if ((toneTimes(n) + 800 < toneTimes(n+1)) && (toneTimes(n) - 200 > toneTimes(n-1)))
            
            % match the required image files...
            for m = 22:(length(bufferReady)-79)
                if ((bufferReady(m-1) <= toneTimes(n)) && (bufferReady(m) > toneTimes(n)))
                    
                    theIndices = bufferReady((m-21):(m+79));
                    
                    stuff = [stuff theIndices];
                    tone = [tone toneTimes(n)];
                    
                end
            end
            
            end
            
            elseif (n < length(toneTimes))
                
                if (toneTimes(n) + 800 < toneTimes(n+1))
                    
                    for m = 22:(length(bufferReady)-79)
                        if ((bufferReady(m-1) <= toneTimes(n)) && (bufferReady(m) > toneTimes(n)))
                    
                        theIndices = bufferReady((m-21):(m+79));
                    
                        stuff = [stuff theIndices];
                        tone = [tone toneTimes(n)];
                    
                        end
                    end
                    
                end
                
            elseif (n > 1)
                
                if (toneTimes(n) - 200 > toneTimes(n-1))
                    
                    for m = 22:(length(bufferReady)-79)
                        if ((bufferReady(m-1) <= toneTimes(n)) && (bufferReady(m) > toneTimes(n)))
                    
                            theIndices = bufferReady((m-21):(m+79));
                    
                            stuff = [stuff theIndices];
                            tone = [tone toneTimes(n)];
                    
                        end
                    end
                    
                end
            end
            
        end
    end
    
end

% generate the images
dims = size(stuff);

eventStore_tone = cell(dims(2),1);

for n = 1:dims(2)
    
    disp(['Working on tone onset #' int2str(n)]);
    
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
    
    horzChange = horzChange -  min(horzChange);
    horzChange = horzChange ./ max(horzChange);
    
    vertChange = vertChange -  min(vertChange);
    vertChange = vertChange ./ max(vertChange);

if(ploton)
    newplot = figure;
    colormap(jet(256))
    
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
    colormap(jet(256))
    axis tight
    axis ij
    ylabel('frame number')
    
    subplot(4,2,4)
    hold on
    image(vertTraceAlt' .* 255)
    plot(1:(y2 - y1 + 1),21 .* ones((y2 - y1 + 1),1),'--w')
    hold off
    colormap(jet(256))
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
    colormap(jet(256))
end

    eventStore_tone{n}.horzTraceRaw = horzTrace;
    eventStore_tone{n}.vertTraceRaw = vertTrace';
    eventStore_tone{n}.horzTraceRef = horzTraceAlt;
    eventStore_tone{n}.vertTraceRef = vertTraceAlt;
    eventStore_tone{n}.camTimes     = stuff(:,n)+1;
    eventStore_tone{n}.folder       = folder;
    eventStore_tone{n}.horzChange   = horzChange;
    eventStore_tone{n}.vertChange   = vertChange;
    eventStore_tone{n}.change       = change;
    eventStore_tone{n}.trigger      = tone(n);
    eventStore_tone{n}.trigger_type = 'tone';
    
    found = 0;
    
    for m = 25:101
        
        if ((change(m) > (nanmean(change(1:20)) + (4*nanstd(change(1:20))))) || ...
            (change(m) < (nanmean(change(1:20)) - (4*nanstd(change(1:20))))))
        
            if ~found
                eventStore_tone{n}.twitchFrame = stuff(m,n) + 1;
                found = 1;
            end
        end
    end
    
    if ~found
        eventStore_tone{n}.twitchFrame = NaN;
        eventStore_tone{n}.twitch_x    = NaN;
        eventStore_tone{n}.twitch_y    = NaN;
    else
        disp(['Twitch found in file: img' num2str(eventStore_tone{n}.twitchFrame) '.tif']);
        
        % Get the maximum change location as follows...
        
        % Take twitch frame...
        twitchy = double(imread(['img' num2str(eventStore_tone{n}.twitchFrame) '.tif']));
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
                eventStore_tone{n}.twitch_x = xdir;% + 99;     % take offset into account
            end
        end
        
        for ydir = 1:(y2 - y1 - 28)
            if sum(flat_y(ydir:(ydir+29))) > score_y;
                score_y = sum( flat_y(ydir:(ydir+29)) );
                eventStore_tone{n}.twitch_y = ydir;          % no offset
            end
        end
    end
    
    eventStore_tone{n}.referenceFrame = ref;
    
end

%save('twitches_tone_triggered.mat', 'eventStore')

cd(oldDir)

%disp('-----')
disp(['Folder ' folder ' ...Done!'])
disp('-----')
catch
end
% 