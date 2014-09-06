function newTraces = findTraceMatches(traces,trainFrames,trainingOutput,objects)

tic

disp('Extending classification input to trace snippets...')

newTraces = traces;

% add a classification field
for n = 1:length(newTraces)
    
    newTraces{n}.class = 0;
    
end

% for every frame in the set...
for n = 1:length(trainFrames)
    
    frame = trainFrames(n);
    
    disp(['Working on frame ' int2str(frame) ', which is frame ' int2str(n) '/' int2str(length(trainFrames)) ' of the training set.'])
    
    % see if the frame is an element of a trace snippet...
    for m = 1:length(traces)

        
        
        % if the frame is an element of a trace snippet...
        if (ismember(frame,traces{m}.firstFrame:traces{m}.lastFrame))
            
            % get the coordinates at the correct point in time in the trace
            [~,loc] = ismember(frame,traces{m}.firstFrame:traces{m}.lastFrame);
            x       = traces{m}.x(loc);
            y       = traces{m}.y(loc);
            
            loc     = 0;
            
            % match them to the correct object in the frame
            for q = 1:length(objects{frame - evalin('base','firstFrame') + 1})
                
                if ((x == objects{frame - evalin('base','firstFrame') + 1}{q}.Centroid(1)) && (y == objects{frame - evalin('base','firstFrame') + 1}{q}.Centroid(2)))
                    
                    loc = q;
                    
                end
                
            end
            
            % store the class for the object
           
            try
            class = trainingOutput{n}(loc);
            catch
            class = trainingOutput{n}(loc-1); 
            end
            
            % the above try/catch statement was a quick hack for error shown below
            
            
            %             "Attempted to access trainingOutput.%cell(8); index out of bounds because
            %             numel(trainingOutput.%cell)=7.
            % 
            %             Error in findTraceMatches (line 52)
            %             class = trainingOutput{n}(loc);"
            %             
            
%             if class ~= 0
%                 disp(['Classified trace found: ' int2str(class) '.']);
%                 pause(0.001);
%             end
            
            % disp(['Match found in trace snippet ' int2str(m) ', class: ' int2str(class) '!'])
            
            if newTraces{m}.class ~= 0
                
                % store dual classification, disambiguate later
                newTraces{m}.class = [newTraces{m}.class class];
                % quick and dirty disambiguation "fix"
                % newTraces{m}.class = unique([newTraces{m}.class class]);
                
                % disp('Double designation here!')
                
            else
                
                % store classification
                newTraces{m}.class = class;
                
            end
            
        end

    end
    
end

disp('Classification of trace snippets overlapping training set complete.')

toc