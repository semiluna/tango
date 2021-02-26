function omap = createOccupancyMap()

buildingDataENU = load("work/test.mat").buildingDataENU;
polygonCorners = [];

polygonCorners{1} = buildingDataENU{1}(4:-1:1,:);
polygonCorners{2} = buildingDataENU{2}(2:5,:);
polygonCorners{3} = buildingDataENU{3}(2:10,:);
polygonCorners{4} = buildingDataENU{4}(2:9,:);
polygonCorners{5} = buildingDataENU{5}(1:end-1,:);
polygonCorners{6} = buildingDataENU{6}(1:end-1,:);
polygonCorners{7} = buildingDataENU{7}(1:end-1,:);
polygonCorners{8} = buildingDataENU{8}(2:end-1,:);
polygonCorners{9} = buildingDataENU{9}(1:end-1,:);
polygonCorners{10} = buildingDataENU{10}(1:end-1,:);
polygonCorners{11} = buildingDataENU{11}(1:end-2,:);

omap = binaryOccupancyMap(600, 600);

queryPointsX = [];
queryPointsY = [];
for i = 1:600
    for j = 1:600
        queryPointsX((i-1)*600+j) = i-300;
        queryPointsY((i-1)*600+j) = j-300;
    end
end
for i=1:length(polygonCorners)
    corners = polygonCorners(i);
    in = inpolygon(queryPointsX, queryPointsY, corners{1}(:, 1), corners{1}(:, 2));
    succX = queryPointsX(in) + 300;
    succY = queryPointsY(in) + 300;

    setOccupancy(omap, transpose([succX; succY]), 1);
end

inflate(omap, 2)