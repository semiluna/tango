% This script initializes workspace variables for the UAV Toolbox Reference
% Application.

% Set guidance type to Obstacle
guidanceType = 1;

% Configure the drone as a Multicopter
isDroneMulticopter = 1;

% Use photorealistic environment
isPhotoRealisticSim = 2;

% Low fidelity plant model 
plantModelFi = 1;

% Show the Lidar Point Cloud
showLidarPointCloud = 0;

% No show the Video Viewer
showVideoViewer = 0;

% Do not show the UAV Animation as it flies
showUAVAnimation = 0;

% Use heading in the guidance model
useHeading =1;

%Takeoff after 5
startFlightTime = 0.005;

% Use QGroundControl
useQGC = 0;

% No Pacing
set_param('uavPackageDelivery','EnablePacing', 'off');

% Simulation Stop Time
simTime =350;

%Show the CPA Scope
close_system('uavPackageDelivery/On Board Computer/DataProcessing/ProcessSensorData/CPA');