% Define Paramters
tol = 1.5;

% Test 1: Ensure Centre is centre

latlong_centre = WorldToLatLong([-19.78756735,-42.8837797]);
actual_centre = [52.21013497,0.09131685578];
assert(abs(latlong_centre(1)-actual_centre(1)) <= tol, 'Problem with Longitude')
assert(abs(latlong_centre(2)-actual_centre(2)) <= tol, 'Problem with Latitude')