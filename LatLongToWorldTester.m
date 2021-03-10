% Define Paramters
tol = 1.5;

% Test 1: Ensure Centre is centre

world_centre = LatLongToWorld([52.21013497,0.09131685578]);
actual_centre = [-19.78756735,-42.8837797];
assert(abs(world_centre(1)-actual_centre(1)) <= tol, 'Problem with Longitude')
assert(abs(world_centre(2)-actual_centre(2)) <= tol, 'Problem with Latitude')

ground_control = LatLongToWorld([52.20954726481548, 0.09000709627050027])