function route = planRRTStarPath(start, goal)

%load occupancy map if not already defined
if ~exist('omap', 'var')
    omap = load("work/omap.mat").omap;
end

%create the state space and validator, needed for the planner
ss = stateSpaceSE2;
ss.StateBounds = [omap.XWorldLimits; omap.YWorldLimits; [-pi pi]];
sv = validatorOccupancyMap(ss);
sv.Map = omap;
sv.ValidationDistance = 0.01;

%create rrt star planner and plan the route
planner = plannerRRTStar(ss, sv);
planner.ContinueAfterGoalReached = true;
planner.MaxIterations = 500;
planner.MaxConnectionDistance = 50;

maxTries = 10;
while maxTries > 0
    
    %plan the route
    try
        pthObj = plan(planner,start,goal);
    catch
        %bad input inside building
        route = -1;
        disp("Start or goal state was inside a building");
        return;
    end
    
    %if we found a path, great
    if pthObj.NumStates > 0
        break
    end
    
    %otherwise try again with more iterations 
    %and maybe higher connection distance
    planner.MaxIterations = round(planner.MaxIterations * 1.5);
    maxTries = maxTries - 1;
    if maxTries <= 3
        planner.MaxConnectionDistance = planner.MaxConnectionDistance + 10;
    end
        
end

%if we couldn't find a path
if pthObj.NumStates == 0
    route = -2;
    disp("Couldn't find a valid path before timeout");
    return;
end

%smooth the route, removing unnecassary waypoints
if pthObj.NumStates > 2
    pthObj = ExampleHelperUAVPathSmoothing(ss,sv,pthObj);
end

route = pthObj;
