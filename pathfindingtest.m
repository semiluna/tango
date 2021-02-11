% Set RNG seed for repeatable result
%rng(1,"twister");

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

    succ = transpose([succX; succY]);
    setOccupancy(omap, transpose([succX; succY]), 1);
end

inflate(omap, 2)

start = [-50, 50];
goal = [-100,-270];

start = start + 300;
goal = goal + 300;

% figure("Name","StartAndGoal")
% hMap = show(omap);
% hold on
% plot(start(1), start(2), 'ro', 'MarkerSize', 10);
% plot(goal(1), goal(2), 'ro', 'MarkerSize', 10);
% hold off

ss = stateSpaceSE2;
sv = validatorOccupancyMap(ss);
sv.Map = omap;
sv.ValidationDistance = 0.01;
ss.StateBounds = [omap.XWorldLimits; omap.YWorldLimits; [-pi pi]];

planner = plannerAStarGrid(omap);
%planner.ContinueAfterGoalReached = true;

%planner.MaxIterations = 10000;
%planner.MaxConnectionDistance = 5;

%start(3) = 0;
%goal(3) = 0;
start = flip(start);
goal = flip(goal);
start(1) = 600 - start(1);
goal(1) = 600 - goal(1);
start
goal
route = plan(planner,start,goal);
show(planner)

route(:, 1) = 600 - route(:, 1);
route = route - 300;
route = flip(route, 2);
route
% 
% omap.show;
% hold on;
% plot(solnInfo.TreeData(:,1),solnInfo.TreeData(:,2), '.-'); % tree expansion
% plot(pthObj.States(:,1),pthObj.States(:,2),'r-','LineWidth',2); % draw path
% hold off
% pose = [ 0 0 0 1 0 0 0];
% omap = occupancyMap3D;
% omap.FreeThreshold = omap.OccupiedThreshold;
% insertPointCloud(omap,pose,pointcloud,300);
% inflate(omap,1)
% show(omap)