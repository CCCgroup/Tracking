function filtobj = filter_objects_by_frame(filtdat,objects)

filtobj = objects;

for n = 1:length(filtdat)
    
    if isnan(filtdat(n))
        filtobj(n).objects = [];
    end
end