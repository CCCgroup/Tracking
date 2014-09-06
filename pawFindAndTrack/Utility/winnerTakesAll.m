function result = winnerTakesAll(votes)

result = zeros(size(votes));

dimensions = size(votes);

for n = 1:dimensions(2)
    
    [~,loc]       = max(votes(:,n));
    result(loc,n) = 1;
    
end