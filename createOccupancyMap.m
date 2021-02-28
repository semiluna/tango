function omap = createOccupancyMap()

% vertices = load("vertices.mat").vertices;
% newV = [];
% for i=1:83
%     bv = [];
%     for j=1:63
%         x = vertices(i, 2*j-1);
%         y = vertices(i, 2*j);
%         if x ~= 0 || y ~= 0
%             bv{j} = [x;y];
%         end
%     end
%     newV{i} = bv;
% end
% save("newVertices.mat", "newV");

vertices = load("newVertices.mat").newV;

omap = binaryOccupancyMap(1200, 1200);

queryPointsX = [];
queryPointsY = [];
for i = 1:1200
    for j = 1:1200
        queryPointsX((i-1)*1200+j) = i-600;
        queryPointsY((i-1)*1200+j) = j-600;
    end
end

for i=1:length(vertices)
    corners = vertices(i);
    corners = corners{1};
    xcorners = [];
    ycorners = [];
    for j=1:length(corners)
        xcorners(j) = corners{j}(1);
        ycorners(j) = -corners{j}(2);
    end
    in = inpolygon(queryPointsX, queryPointsY, xcorners, ycorners);
    succX = queryPointsX(in) + 600;
    succY = queryPointsY(in) + 600;
    if ~isempty(succX)
        setOccupancy(omap, transpose([succX; succY]), 1);
    end
    
end

inflate(omap, 3);
