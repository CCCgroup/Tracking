function cleaned_entries = delete_doubles(some_list)

dims            = size(some_list);
cleaned_entries = some_list;

for n = 1:dims(1)
    
    new_dims = size(cleaned_entries);
    
    if (n >= new_dims(1))
        break
    end
    
    current = cleaned_entries(n,:);
    
    for q = (n+1):new_dims(1)
        
        comparison = (current == cleaned_entries(q,:));
        
        if (sum(comparison) == dims(2))
            %disp('Double entry found.')
            cleaned_entries(q,:) = [];
            break
        end
    end
end