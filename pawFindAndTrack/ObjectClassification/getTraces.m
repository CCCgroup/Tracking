function [fpl,fpr,hpl,hpr,tail] = getTraces(finalTraces)

tic

disp('Converting trace snippets to traces of individual paws...')

% find the last frame...

lastFrame = 0;

for n = 1:length(finalTraces)
    
    if lastFrame < finalTraces{n}.lastFrame
        lastFrame = finalTraces{n}.lastFrame;
    end
end

% initialize matrices, [x y area]
fpl  = NaN .* ones(lastFrame,3);
fpr  = NaN .* ones(lastFrame,3);
hpl  = NaN .* ones(lastFrame,3);
hpr  = NaN .* ones(lastFrame,3);
tail = NaN .* ones(lastFrame,3);

for n = 1:length(finalTraces)
    
    % see where this object fits in
    if finalTraces{n}.class == 1
        
        % check to see if all slots in the trace are free
        if isnan(nanmean(fpl(finalTraces{n}.firstFrame:finalTraces{n}.lastFrame,1)))
            % if they are, dump the data into those slots
            fpl(finalTraces{n}.firstFrame:finalTraces{n}.lastFrame,1) = finalTraces{n}.x';
            fpl(finalTraces{n}.firstFrame:finalTraces{n}.lastFrame,2) = finalTraces{n}.y';
            fpl(finalTraces{n}.firstFrame:finalTraces{n}.lastFrame,3) = ones(length(finalTraces{n}.x),1) .* finalTraces{n}.avgArea;
        else
            for m = 1:length(finalTraces{n}.x)
                
                % if this is a NaN-value, just dump it in there
                if isnan(fpl(finalTraces{n}.firstFrame + m - 1))
                    
                    fpl(finalTraces{n}.firstFrame + m - 1,1) = finalTraces{n}.x(m);
                    fpl(finalTraces{n}.firstFrame + m - 1,2) = finalTraces{n}.y(m);
                    fpl(finalTraces{n}.firstFrame + m - 1,3) = finalTraces{n}.avgArea;
                
                % if not, create a weighted average, based on avgArea
                else
                    
                    mass1     = fpl(finalTraces{n}.firstFrame + m - 1,3);
                    mass2     = finalTraces{n}.avgArea;
                    totalMass = mass1 + mass2;
                    x1        = fpl(finalTraces{n}.firstFrame + m - 1,1);
                    x2        = finalTraces{n}.x(m);
                    newX      = (mass1 * x1 + mass2 * x2) / totalMass;
                    y1        = fpl(finalTraces{n}.firstFrame + m - 1,2);
                    y2        = finalTraces{n}.y(m);
                    newY      = (mass1 * y1 + mass2 * y2) / totalMass;
                    
                    fpl(finalTraces{n}.firstFrame + m - 1,1) = newX;
                    fpl(finalTraces{n}.firstFrame + m - 1,2) = newY;
                    fpl(finalTraces{n}.firstFrame + m - 1,3) = totalMass;
                    
                end
                
            end
        end
        
    else if finalTraces{n}.class == 2
            
            % check to see if all slots in the trace are free
            if isnan(nanmean(fpr(finalTraces{n}.firstFrame:finalTraces{n}.lastFrame,1)))
                % if they are, dump the data in those slots
                fpr(finalTraces{n}.firstFrame:finalTraces{n}.lastFrame,1) = finalTraces{n}.x';
                fpr(finalTraces{n}.firstFrame:finalTraces{n}.lastFrame,2) = finalTraces{n}.y';
                fpr(finalTraces{n}.firstFrame:finalTraces{n}.lastFrame,3) = ones(length(finalTraces{n}.x),1) .* finalTraces{n}.avgArea;
            else
                for m = 1:length(finalTraces{n}.x)
                
                    % if this is a NaN-value, just dump it in there
                    if isnan(fpr(finalTraces{n}.firstFrame + m - 1))
                    
                        fpr(finalTraces{n}.firstFrame + m - 1,1) = finalTraces{n}.x(m);
                        fpr(finalTraces{n}.firstFrame + m - 1,2) = finalTraces{n}.y(m);
                        fpr(finalTraces{n}.firstFrame + m - 1,3) = finalTraces{n}.avgArea;
                
                    % if not, create a weighted average, based on avgArea
                    else
                    
                        mass1     = fpr(finalTraces{n}.firstFrame + m - 1,3);
                        mass2     = finalTraces{n}.avgArea;
                        totalMass = mass1 + mass2;
                        x1        = fpr(finalTraces{n}.firstFrame + m - 1,1);
                        x2        = finalTraces{n}.x(m);
                        newX      = (mass1 * x1 + mass2 * x2) / totalMass;
                        y1        = fpr(finalTraces{n}.firstFrame + m - 1,2);
                        y2        = finalTraces{n}.y(m);
                        newY      = (mass1 * y1 + mass2 * y2) / totalMass;
                    
                        fpr(finalTraces{n}.firstFrame + m - 1,1) = newX;
                        fpr(finalTraces{n}.firstFrame + m - 1,2) = newY;
                        fpr(finalTraces{n}.firstFrame + m - 1,3) = totalMass;
                    
                    end
                
                end
            
            end
            
        else if finalTraces{n}.class == 3
                
                % check to see if all slots in the trace are free
                if isnan(nanmean(hpl(finalTraces{n}.firstFrame:finalTraces{n}.lastFrame,1)))
                    % if they are, dump the data in those slots
                    hpl(finalTraces{n}.firstFrame:finalTraces{n}.lastFrame,1) = finalTraces{n}.x';
                    hpl(finalTraces{n}.firstFrame:finalTraces{n}.lastFrame,2) = finalTraces{n}.y';
                    hpl(finalTraces{n}.firstFrame:finalTraces{n}.lastFrame,3) = ones(length(finalTraces{n}.x),1) .* finalTraces{n}.avgArea;
                else
                    for m = 1:length(finalTraces{n}.x)
                
                        % if this is a NaN-value, just dump it in there
                        if isnan(hpl(finalTraces{n}.firstFrame + m - 1))
                    
                            hpl(finalTraces{n}.firstFrame + m - 1,1) = finalTraces{n}.x(m);
                            hpl(finalTraces{n}.firstFrame + m - 1,2) = finalTraces{n}.y(m);
                            hpl(finalTraces{n}.firstFrame + m - 1,3) = finalTraces{n}.avgArea;
                
                        % if not, create a weighted average, based on avgArea
                        else
                    
                            mass1     = hpl(finalTraces{n}.firstFrame + m - 1,3);
                            mass2     = finalTraces{n}.avgArea;
                            totalMass = mass1 + mass2;
                            x1        = hpl(finalTraces{n}.firstFrame + m - 1,1);
                            x2        = finalTraces{n}.x(m);
                            newX      = (mass1 * x1 + mass2 * x2) / totalMass;
                            y1        = hpl(finalTraces{n}.firstFrame + m - 1,2);
                            y2        = finalTraces{n}.y(m);
                            newY      = (mass1 * y1 + mass2 * y2) / totalMass;
                    
                            hpl(finalTraces{n}.firstFrame + m - 1,1) = newX;
                            hpl(finalTraces{n}.firstFrame + m - 1,2) = newY;
                            hpl(finalTraces{n}.firstFrame + m - 1,3) = totalMass;
                    
                        end
                
                    end
            
                end
                
            else if finalTraces{n}.class == 4
                    
                    % check to see if all slots in the trace are free
                    if isnan(nanmean(hpr(finalTraces{n}.firstFrame:finalTraces{n}.lastFrame,1)))
                        % if they are, dump the data in those slots
                        hpr(finalTraces{n}.firstFrame:finalTraces{n}.lastFrame,1) = finalTraces{n}.x';
                        hpr(finalTraces{n}.firstFrame:finalTraces{n}.lastFrame,2) = finalTraces{n}.y';
                        hpr(finalTraces{n}.firstFrame:finalTraces{n}.lastFrame,3) = ones(length(finalTraces{n}.x),1) .* finalTraces{n}.avgArea;
                    else
                        for m = 1:length(finalTraces{n}.x)
                
                            % if this is a NaN-value, just dump it in there
                            if isnan(hpr(finalTraces{n}.firstFrame + m - 1))
                    
                                hpr(finalTraces{n}.firstFrame + m - 1,1) = finalTraces{n}.x(m);
                                hpr(finalTraces{n}.firstFrame + m - 1,2) = finalTraces{n}.y(m);
                                hpr(finalTraces{n}.firstFrame + m - 1,3) = finalTraces{n}.avgArea;
                
                            % if not, create a weighted average, based on avgArea
                            else
                    
                                mass1     = hpr(finalTraces{n}.firstFrame + m - 1,3);
                                mass2     = finalTraces{n}.avgArea;
                                totalMass = mass1 + mass2;
                                x1        = hpr(finalTraces{n}.firstFrame + m - 1,1);
                                x2        = finalTraces{n}.x(m);
                                newX      = (mass1 * x1 + mass2 * x2) / totalMass;
                                y1        = hpr(finalTraces{n}.firstFrame + m - 1,2);
                                y2        = finalTraces{n}.y(m);
                                newY      = (mass1 * y1 + mass2 * y2) / totalMass;
                    
                                hpr(finalTraces{n}.firstFrame + m - 1,1) = newX;
                                hpr(finalTraces{n}.firstFrame + m - 1,2) = newY;
                                hpr(finalTraces{n}.firstFrame + m - 1,3) = totalMass;
                    
                            end
                
                        end
            
                    end
                    
                else if finalTraces{n}.class == 5
                        
                        % check to see if all slots in the trace are free
                        if isnan(nanmean(tail(finalTraces{n}.firstFrame:finalTraces{n}.lastFrame,1)))
                            % if they are, dump the data in those slots
                            tail(finalTraces{n}.firstFrame:finalTraces{n}.lastFrame,1) = finalTraces{n}.x';
                            tail(finalTraces{n}.firstFrame:finalTraces{n}.lastFrame,2) = finalTraces{n}.y';
                            tail(finalTraces{n}.firstFrame:finalTraces{n}.lastFrame,3) = ones(length(finalTraces{n}.x),1) .* finalTraces{n}.avgArea;
                        else
                            for m = 1:length(finalTraces{n}.x)
                
                                % if this is a NaN-value, just dump it in there
                                if isnan(tail(finalTraces{n}.firstFrame + m - 1))
                    
                                    tail(finalTraces{n}.firstFrame + m - 1,1) = finalTraces{n}.x(m);
                                    tail(finalTraces{n}.firstFrame + m - 1,2) = finalTraces{n}.y(m);
                                    tail(finalTraces{n}.firstFrame + m - 1,3) = finalTraces{n}.avgArea;
                 
                                % if not, create a weighted average, based on avgArea
                                else
                    
                                    mass1     = tail(finalTraces{n}.firstFrame + m - 1,3);
                                    mass2     = finalTraces{n}.avgArea;
                                    totalMass = mass1 + mass2;
                                    x1        = tail(finalTraces{n}.firstFrame + m - 1,1);
                                    x2        = finalTraces{n}.x(m);
                                    newX      = (mass1 * x1 + mass2 * x2) / totalMass;
                                    y1        = tail(finalTraces{n}.firstFrame + m - 1,2);
                                    y2        = finalTraces{n}.y(m);
                                    newY      = (mass1 * y1 + mass2 * y2) / totalMass;
                    
                                    tail(finalTraces{n}.firstFrame + m - 1,1) = newX;
                                    tail(finalTraces{n}.firstFrame + m - 1,2) = newY;
                                    tail(finalTraces{n}.firstFrame + m - 1,3) = totalMass;
                    
                                end
                
                            end
            
                        end
                        
                    end
                end
            end
        end
    end
    
end

disp('Individual paw traces reconstructed.')

toc