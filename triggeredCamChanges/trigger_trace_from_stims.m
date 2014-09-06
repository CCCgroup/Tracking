function [outvector, outvector_snippets] = trigger_trace_from_stims(vector,stims, pre, post)
% function [outvector, outvector_snippets] = trigger_trace_from_stims(vector,stims, pre, post)

%ensure that stim trigger falls in right range
stimssub = stims-pre;
stimsadd = stims+post;

idx=find(stimssub<1);
idx2=find(stimsadd>length(vector));

% if(isempty(idx))
%     idx=[];
% end
% 
% if(isempty(idx2))
%     idx2=[];
% end
% 
idx
idx2
stims(idx)=[];
stims(idx2)=[];

size(stims)
length(stims)
numstims = length(stims);
numstims
stims
trace_snippets = zeros(numstims,pre+post+1);
for i=1:numstims
    i
   if(stims(i)-pre > 0 && stims(i)+post < length(vector))
  
       trace_snippets(i,:)=vector(stims(i)-pre:stims(i)+post);
       
   end
    
end

figure;
plot(nanmean(trace_snippets),'Color',[ 0 0 0], 'LineSmoothing', 'on');


outvector=nanmean(trace_snippets);
outvector_snippets=trace_snippets;