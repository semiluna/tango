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

vertices = load("work/newVertices.mat").newV;

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
        ycorners(j) = corners{j}(2);
    end
    in = inpolygon(queryPointsX, queryPointsY, xcorners, ycorners);
    succX = queryPointsX(in) + 600;
    succY = queryPointsY(in) + 600;
    if ~isempty(succX)
        setOccupancy(omap, transpose([succX; succY]), 1);
    end
end

inflate(omap, 2);

topLeft = [40, 290];
botRight = [1120, 910];

xPoints = [];
yPoints = [];

for x=40:1120
   xPoints(8*(x-39)) = x;
   xPoints(8*(x-39)-3) = x;
   xPoints(8*(x-39)-2) = x;
   xPoints(8*(x-39)-1) = x;
   xPoints(8*(x-39)-7) = x;
   xPoints(8*(x-39)-6) = x;
   xPoints(8*(x-39)-5) = x;
   xPoints(8*(x-39)-4) = x;
   yPoints(8*(x-39)) = 289;
   yPoints(8*(x-39)-1) = 290;
   yPoints(8*(x-39)-2) = 910;
   yPoints(8*(x-39)-3) = 911;
   yPoints(8*(x-39)-7) = 288;
   yPoints(8*(x-39)-6) = 287;
   yPoints(8*(x-39)-5) = 912;
   yPoints(8*(x-39)-4) = 913;
end
setOccupancy(omap, transpose([xPoints; yPoints]), 1);

xPoints = [];
yPoints = [];

for y=290:910
   xPoints(8*(y-289)) = 40;
   xPoints(8*(y-289)-3) = 39;
   xPoints(8*(y-289)-2) = 38;
   xPoints(8*(y-289)-1) = 37;
   xPoints(8*(y-289)-7) = 1120;
   xPoints(8*(y-289)-6) = 1121;
   xPoints(8*(y-289)-5) = 1122;
   xPoints(8*(y-289)-4) = 1123;
   yPoints(8*(y-289)) = y;
   yPoints(8*(y-289)-1) = y;
   yPoints(8*(y-289)-2) = y;
   yPoints(8*(y-289)-3) = y;
   yPoints(8*(y-289)-7) = y;
   yPoints(8*(y-289)-6) = y;
   yPoints(8*(y-289)-5) = y;
   yPoints(8*(y-289)-4) = y;
end

setOccupancy(omap, transpose([xPoints; yPoints]), 1);

save("work/omap.mat", "omap");
