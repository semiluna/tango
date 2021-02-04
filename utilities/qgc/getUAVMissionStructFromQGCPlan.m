function xyzMission = getUAVMissionStructFromQGCPlan (missionPlan, homeLocation, plotFig)

qgcMission = jsondecode(fileread(missionPlan));

baseStruct = struct('mode', uint8(2), 'position', single([0; 0; 0]), 'params', single([0; 0; 0; 0]));
nwps = size(qgcMission.mission.items,1);
xyzMission = repmat(baseStruct,nwps,1);

if (plotFig)
    clf
    figure(1);
    hold on
end
for ii = 1:nwps
    gPos = qgcMission.mission.items(ii).params(5:7)';
    lPos = lla2flat (gPos, homeLocation(1:2), 0, homeLocation(3));
    lPos(3) = lPos(3) * single(-1);
    if (plotFig)
        plot(lPos(2), lPos(1), '*');
    end
    xyzMission(ii).position = single(lPos');
    xyzMission(ii).mode = uint8(mavlinkToPlannerType(qgcMission.mission.items(ii).command));
    y = isnan(qgcMission.mission.items(ii).params);
    xyzMission(ii).params = single(qgcMission.mission.items(ii).params(1:4));
    if sum(y)>0
        xyzMission(ii).params(y) = single(0);
    end
    
end

end

function plannerType =  mavlinkToPlannerType (mavlinkType)
% see enum name="MAV_CMD" in common.xml for values.
switch mavlinkType
    case 16 %MAV_CMD_NAV_WAYPOINT
        plannerType = uint8(2);
    case 18 %MAV_CMD_NAV_LOITER_TURNS
        plannerType = uint8(3);
    case 21 %MAV_CMD_NAV_LAND
        plannerType = uint8(4);
    case 22 %MAV_CMD_NAV_TAKEOFF
        plannerType = uint8(1);
    otherwise %this will likely error out to signal something unexpected
        plannerType = uint8(0);
end
end
