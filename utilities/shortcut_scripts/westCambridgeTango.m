% This script initializes workspace variables for the UAV Toolbox Reference
% Application.

% Ground control station coordinates
% droneStartLocation = [52.20954726481548, 0.09000709627050027, 17.0364];

% Set guidance type to Full Guidance
guidanceType = 1;

% Configure the drone as a Multicopter
isDroneMulticopter = 1;

% Use photorealistic environment
isPhotoRealisticSim = 0;

% Low fidelity plant model 
plantModelFi = 0;

% Do not show the Lidar Point Cloud
showLidarPointCloud = 0;

% Show the Video Viewer
showVideoViewer = 1;

% Show the UAV Animation as it flies
showUAVAnimation = 1;

% Use heading in the guidance model
useHeading = 1;

%Takeoff after 5
startFlightTime = 5;

% Use ourUI
useQGC = 1;

% No pacing
set_param('uavPackageDelivery','EnablePacing', 'off');

% Simulation Stop Time
simTime =inf;

%open UI
app1;

%Show the CPA Scope
close_system('uavPackageDelivery/On Board Computer/DataProcessing/ProcessSensorData/CPA');