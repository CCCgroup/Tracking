function cleaned = kill_tail(obj,tailinds)

cleaned = {};

for n = 1:length(obj)
    if ~isempty(obj{n})
    count = 0;
    for q = 1:length(obj{n})
        if (q ~= tailinds(n))
            count = count + 1;
            cleaned{n}(count).PixelList = obj{n}(q).PixelList;
        end
    end
    end
end