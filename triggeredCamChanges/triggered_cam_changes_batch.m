
function triggered_cam_changes_batch()

%Settings changed to match data of 18-06-2012 to 20-06-2012
%likely to apply for most data, but change as necessary
x1=35;
x2=512;
y1=17;
y2=256;

dir = uigetdir;

[p f] = subdir(dir); %extract subdirectories (p) and filenames (f) therein

subfon=0;

for i=1:length(f)
    p{i}
    cd(p{i});
	sf = f{i};

    try
        eventStore_perturb=triggered_cam_changes_perturb(p{i},x1,x2,y1,y2,0)
    catch
    end
    try
        eventStore_tone=triggered_cam_changes_tone(p{i},x1,x2,y1,y2,0)
    catch
    end
    try
       eventStore_toneoff=triggered_cam_changes_toneoff(p{i},x1,x2,y1,y2,0)
    catch
    end
    
    try
        
        if(exist('eventStore_tone','var') && exist('eventStore_toneoff','var') && exist('eventStore_perturb','var'))
            save('StimTriggeredTwitches.mat','eventStore_perturb','eventStore_tone','eventStore_toneoff');
        end
    
    catch
        
        try
        
            if(exist('eventStore_perturb','var'))
                save('StimTriggeredTwitches.mat','eventStore_perturb');
            end
            
        catch
        
            try
                if(exist('eventStore_toneoff','var'))
                save('StrimTriggeredTwitches.mat','eventStore_tone','eventStore_toneoff');
                end
            catch
                
            end
            
        end
         
    end
        
        
    end
    

    
   

        
end
