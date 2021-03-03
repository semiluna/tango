% Get omap

if ~exist('omap', 'var')
    disp("Omapping")
    omap = createOccupancyMap();
end
disp("got omap")




% Example 1 Preparation

start = [300,-300]
goal = [-500,500]

% Get route vector
route = computeRRTStarRoute(start, goal)

% Test 1: Start is correct

assert(isequal(route(1,1:2),start), "Start is wrong")

% Test 2: Goal is correct

assert(isequal(int32(route(end,1:2)),goal), "Goal is wrong")

% Test 3: Check if points along the route are in buildings

occupancy = getOccupancy(omap,route);
sz = size(occupancy);
assert(isequal(occupancy,zeros(sz)))




% Example 2 Preparation

start = [-410,210]
goal = [150,150]

% Get route vector
route = computeRRTStarRoute(start, goal)

% Test 1: Start is correct

assert(isequal(route(1,1:2),start), "Start is wrong")

% Test 2: Goal is correct

assert(isequal(int32(route(end,1:2)),goal), "Goal is wrong")

% Test 3: Check if points along the route are in buildings

occupancy = getOccupancy(omap,route);
sz = size(occupancy);
assert(isequal(occupancy,zeros(sz)))



% Example 3 Preparation

start = [-250,-250]
goal = [500,-300]

% Get route vector
route = computeRRTStarRoute(start, goal)

% Test 1: Start is correct

assert(isequal(route(1,1:2),start), "Start is wrong")

% Test 2: Goal is correct

assert(isequal(int32(route(end,1:2)),goal), "Goal is wrong")

% Test 3: Check if points along the route are in buildings

occupancy = getOccupancy(omap,route);
sz = size(occupancy);
assert(isequal(occupancy,zeros(sz)))



% Example 4 Preparation

start = [-250,-250]
goal = [500,-300]

% Get route vector
route = computeRRTStarRoute(start, goal)

% Test 1: Start is correct

assert(isequal(route(1,1:2),start), "Start is wrong")

% Test 2: Goal is correct

assert(isequal(int32(route(end,1:2)),goal), "Goal is wrong")

% Test 3: Check if points along the route are in buildings

occupancy = getOccupancy(omap,route);
sz = size(occupancy);
assert(isequal(occupancy,zeros(sz)))



% Example 5 Preparation

start = [-250,-250]
goal = [500,-300]

% Get route vector
route = computeRRTStarRoute(start, goal)

% Test 1: Start is correct

assert(isequal(route(1,1:2),start), "Start is wrong")

% Test 2: Goal is correct

assert(isequal(int32(route(end,1:2)),goal), "Goal is wrong")

% Test 3: Check if points along the route are in buildings

occupancy = getOccupancy(omap,route);
sz = size(occupancy);
assert(isequal(occupancy,zeros(sz)))