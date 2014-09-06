function flags = estimate_borked_frame_trigpoints(angles)

flags = [];

the_diff = diff(angles);

upper_thresh  = nanmean(the_diff) + (3*nanstd(the_diff));
lower_thresh  = nanmean(the_diff) - (3*nanstd(the_diff));

upper_thresh2 = nanmean(angles) + (2*nanstd(angles));
lower_thresh2 = nanmean(angles) - (2*nanstd(angles));

for n = 1:length(the_diff)
    
    if ((the_diff(n) > upper_thresh) && ((angles(n) > upper_thresh2) || (angles(n) < lower_thresh2)))
        flags = [flags ; n+1, 1];
    elseif ((the_diff(n) < lower_thresh) && ((angles(n) < lower_thresh2) || (angles(n) > upper_thresh2)))
        flags = [flags ; n+1, -1];
    end
end

% check the result

if ~isempty(flags)

    flags_up   = flags( flags(:,2) ==  1,1);
    flags_down = flags( flags(:,2) == -1,1);

else
    
    flags_up = [];
    flags_down = [];
    
end

% figure
% hold on
% plot(2:length(angles),the_diff,'Color',[0.5 0.5 0.5],'LineWidth',2);
% plot(ones(size(angles)) * upper_thresh, '--k');
% plot(ones(size(angles)) * lower_thresh, '--k');
% plot(angles,'r','LineWidth',2)
% scatter(flags_up,  angles(flags_up),  '*k');
% scatter(flags_down,angles(flags_down), 'k');
% hold off
