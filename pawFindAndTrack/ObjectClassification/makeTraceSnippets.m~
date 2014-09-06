function traces = makeTraceSnippets(objects,folder)

tic

disp('Matching objects to form traces...')

frames = length(objects);

% temp variables

traces  = {};  % final traces variable, empty at start, filled during process.
matches = {};  % temporary variable storing best matches between traces and objects.
temp    = {};  % temporary variable storing trace snippets, before submitting them to the final traces variable.

% take first frame and start traces... 
% trace objects include starting frame number, x and y traces, average
% area, and average orientation.

for n = 1:length(objects{1})
    
    temp{n}.firstFrame = evalin('base','firstFrame');
    temp{n}.lastFrame  = evalin('base','firstFrame');
    temp{n}.x          = objects{1}{n}.Centroid(1);
    temp{n}.y          = objects{1}{n}.Centroid(2);
    temp{n}.avgArea    = objects{1}{n}.Area;
    temp{n}.avgOrient  = objects{1}{n}.Orientation;
    
end

count = 0;

for n = 2:length(objects)
    
    for k = 1:length(temp)
        matches{k} = [];
    end
    
    % check difference between every object in this frame... 
    for m = 1:length(objects{n})
        
        % ...and every trace in temp
        for k = 1:length(temp)
            
            % calculate Euclidean distance
            dist = sqrt((temp{k}.x(end) - objects{n}{m}.Centroid(1))^2 + (temp{k}.y(end) - objects{n}{m}.Centroid(2))^2);
            
            % calculate pixel area difference
            area = abs(temp{k}.avgArea - objects{n}{m}.Area);
            
            % store this value
            matches{k} = [matches{k} ; m dist area];
            
        end
        
    end
    
    % Now that we have all object-trace distances...
    
    % Create a temporary claims variable
    claims = zeros(length(temp),2);
    
    % For every existing trace
    for k = 1:length(temp)
        
%         disp(['Matching in frame #' int2str(n) ', temp array object #' int2str(k) '.'])
%         disp(['Size of matches at this point: ' num2str(size(matches{k}))])
%         disp(['Size of temp array at this point: ' num2str(size(temp))])
%         disp('-----')
        
        % if there are any matches...
        if sum(size(matches{k})) > 0
        
            % Find the closest match... (smallest distance)
            [~,loc] = min(matches{k}(:,2));
        
            % Verify that this is a likely candidate...
        
                % Total centroid jump in pixels not too big?
                if (matches{k}(loc,2) < 20)
            
                    % Change in number of pixels not too substantial?
                    if (matches{k}(loc,3) < (0.1 * temp{k}.avgArea))
                    
                        % Lay claim...
                        claims(k,:) = [matches{k}(loc,1) matches{k}(loc,2)];
                    end
                end
        else
            disp(['Matching in frame #' int2str(n) ', temp array object #' int2str(k) ' out of ' int2str(length(temp)) '.'])
            disp('Whoa! No matches AT ALL for this object! NIENTE! NADA! RIEN!')
            disp('-----')
%             pause
        end
        
    end
    
    % Now that all traces have "claimed" candidates
    
    % Sort out double claims (if any)
    for k = 1:length(claims(:,1))
        
        if (claims(k,1) ~= 0)
            
            [tf,indices] = isMultiMember(claims(k,1),claims(:,1));
        
            % If an object is claimed by multiple traces in temp
            if tf == 1
            
                distances = [];
                
                % Find all relevant distances
                for m = 1:length(indices)
                
                    distances = [distances ; claims(indices(m),2)];
                
                end
            
                % Get the smallest distance
                [~,loc] = min(distances);
            
                % Eliminate the other claims
                for m = 1:length(indices)
                
                    if m == loc
                    else
                        claims(indices(m),:) = [0 0];
                    end
                
                end
            end
        end
    end
    
    indices = [];
    
    % Update temp traces variable...
    for k = 1:length(claims(:,1))
        
        % Store any discontinued traces for function output and mark for removal from temp...
        if (claims(k,1) == 0)
        
            count = count + 1;
            traces{count} = temp{k};
            indices = [indices ; k];
            
        % Append claimed objects to temp traces
        else
            
            temp{k}.lastFrame =  temp{k}.lastFrame + 1;
            temp{k}.x         = [temp{k}.x objects{n}{claims(k,1)}.Centroid(1)];
            temp{k}.y         = [temp{k}.y objects{n}{claims(k,1)}.Centroid(2)];
            
            theLength         = temp{k}.lastFrame - temp{k}.firstFrame + 1;
            
            temp{k}.avgArea   = ((1 / theLength) * objects{n}{claims(k,1)}.Area)        + (((theLength - 1) / theLength) * temp{k}.avgArea);
            temp{k}.avgOrient = ((1 / theLength) * objects{n}{claims(k,1)}.Orientation) + (((theLength - 1) / theLength) * temp{k}.avgOrient);
            
        end
        
    end
    
    % Remove discontinued traces from temp
    
    temp2 = {};
    
    tempCount = 0;
    
    for k = 1:length(temp)
        
        % If this trace is marked for removal...
        if ismember(k,indices) == 1
            % nothing...
        % If it is not marked for removal...
        else
            % Copy it to temp2...
            tempCount = tempCount + 1;
            temp2{tempCount} = temp{k};
        end
        
    end
    
    % Replace temp with temp2
    temp = temp2;
    
    % Start new traces with objects that are not accounted for
    for k = 1:length(objects{n})
        
        % Do nothing if it was claimed...
        if ismember(claims(:,1),k) == 1
        % But if it was not, store it as the start of a new trace...
        else
            
            tempCount                  = tempCount + 1;
            temp{tempCount}.firstFrame = evalin('base','firstFrame') + n - 1;
            temp{tempCount}.lastFrame  = evalin('base','firstFrame') + n - 1;
            temp{tempCount}.x          = objects{n}{k}.Centroid(1);
            temp{tempCount}.y          = objects{n}{k}.Centroid(2);
            temp{tempCount}.avgArea    = objects{n}{k}.Area;
            temp{tempCount}.avgOrient  = objects{n}{k}.Orientation;
            
        end
        
    end
    
    
    if (mod(n,100) == 0)
        disp(['     ' int2str(n) ' out of ' int2str(frames) ' frames processed so far...']);
    end
    
end

% Put last snippets in temp into traces
for k = 1:length(temp)
    
    traces{count + k} = temp{k};
    
end

disp(['     All ' int2str(frames) ' frames done.'])

disp(['Saving result as: ' strcat(folder,filesep, 'Paws', filesep, 'traces.mat')])
pause(0.001);

save(strcat(folder,filesep, 'Paws', filesep, 'traces.mat'))

disp('Trace forming complete.')

toc
