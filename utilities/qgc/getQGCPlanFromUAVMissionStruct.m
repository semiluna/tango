function qgcMission = getQGCPlanFromUAVMissionStruct (uavMissionPlanStruct, homeLocation, plotFig, QGCPlanName)
%GETQGCPLANFROMUAVMISSIONSTRUCT
% usage: getQGCPlanFromUAVMissionStruct(baseMission, [uavIC_latLon 0], 1, 'baseMission.plan')

qgcPlan = struct;
qgcPlan.fileType = 'Plan';
qgcPlan.geoFence = struct;
qgcPlan.geoFence.circles = [];
qgcPlan.geoFence.polygons = [];
qgcPlan.geoFence.version = 2;
qgcPlan.groundStation = 'QGroundControl';
qgcPlan.version = 1;

qgcPlan.mission = struct;
qgcPlan.mission.cruiseSpeed = 15;
qgcPlan.mission.firmwareType = 0;
qgcPlan.mission.hoverSpeed = 5;
qgcPlan.mission.items = struct;

qgcPlan.mission.plannedHomePosition = homeLocation;
qgcPlan.mission.vehicleType = 2;
qgcPlan.mission.version = 2;

qgcPlan.rallyPoints = struct;
qgcPlan.rallyPoints.points = [];
qgcPlan.rallyPoints.version = 2;


nwps = size(uavMissionPlanStruct,1);

if (plotFig)
    clf
    figure(1);
    hold on
end
for ii = 1:nwps
    lpos = uavMissionPlanStruct(ii).position';
    gpos = flat2lla(lpos,homeLocation(1:2), 0, homeLocation(3)).*[1 1 -1];
    
    if (plotFig)
        plot(lpos(2), lpos(1), '*');
    end
    
    qgcPlan.mission.items(ii, 1).AMSLAltAboveTerrain = gpos(3);
    qgcPlan.mission.items(ii, 1).Altitude = gpos(3);
    qgcPlan.mission.items(ii, 1).AltitudeMode = 1;
    qgcPlan.mission.items(ii, 1).autoContinue = true;
    qgcPlan.mission.items(ii, 1).command = structToMAVLinkType(uavMissionPlanStruct(ii).mode);% uavMissionPlanStruct(ii).mode;
    qgcPlan.mission.items(ii, 1).doJumpId = ii;
    qgcPlan.mission.items(ii, 1).frame = 3;
    qgcPlan.mission.items(ii, 1).params = [uavMissionPlanStruct(ii).params' gpos];
    qgcPlan.mission.items(ii, 1).type = 'SimpleItem';
    
end


qgcMission = jsonencode(qgcPlan);
fid=fopen(QGCPlanName, 'w');
fprintf(fid,'%s', qgcMission);
fclose(fid);


end

function missionType =  structToMAVLinkType (structType)
% see enum name="MAV_CMD" in common.xml for values.
    switch structType
        case 2 %MAV_CMD_NAV_WAYPOINT
            missionType = uint8(16);
        case 3 %MAV_CMD_NAV_LOITER_TURNS
            missionType = uint8(18);
        case 4 %MAV_CMD_NAV_LAND
            missionType = uint8(21);
        case 1 %MAV_CMD_NAV_TAKEOFF
            missionType = uint8(22);
        otherwise %this will likely error out to signal something unexpected
            missionType = uint8(0);
    end
end