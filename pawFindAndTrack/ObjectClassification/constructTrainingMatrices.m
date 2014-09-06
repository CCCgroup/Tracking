function [trainingMatrix,desiredOutput,classifyMatrix] = constructTrainingMatrices(newTraces)

tic

disp('Reformatting traces for use with neural network toolkit.')

% initialize matrices, allocating memory and saving some time
classifyMatrix = zeros(1,4);
trainingMatrix = zeros(1,4);
desiredOutput  = zeros(1,6);

count          = 0;

for n = 1:length(newTraces)
    
    % put every trace into the big matrix for classification
    classifyMatrix(n,1) = mean(newTraces{n}.x);
    classifyMatrix(n,2) = mean(newTraces{n}.y);
    classifyMatrix(n,3) = newTraces{n}.avgArea;
    classifyMatrix(n,4) = newTraces{n}.avgOrient;
    
    % see if the current trace is part of the training set
    if (newTraces{n}.class ~= 0)
        
        % store the trace properties
        count                   = count + 1;
        trainingMatrix(count,1) = mean(newTraces{n}.x);
        trainingMatrix(count,2) = mean(newTraces{n}.y);
        trainingMatrix(count,3) = newTraces{n}.avgArea;
        trainingMatrix(count,4) = newTraces{n}.avgOrient;
        
        % see if disambiguation is necessary
        if length(newTraces{n}.class) > 1
            % if there is a majority for some class, pick the majority
            [tf,maj] = majority(newTraces{n}.class);
            if tf == 1
                outTemp                = zeros(1,6);
                outTemp(maj)           = 1;
                desiredOutput(count,:) = outTemp;
            else
                % if not, decide randomly
                outTemp                = zeros(1,6);
                outTemp(newTraces{n}.class(randi(length(newTraces{n}.class),1))) = 1;
                desiredOutput(count,:) = outTemp;
            end
        else
            % if disambiguation is not necessary, simply store it
            outTemp                       = zeros(1,6);
            outTemp(newTraces{n}.class)   = 1;
            desiredOutput(count,:)        = outTemp;
        end
        
    end
    
end

disp('Reformatting done.')

toc