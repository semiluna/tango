classdef GCSHandler < handle
    %GCSHandler Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        MaxMissionLength = 42
    end
    properties(Access=public)
        IO
        Heartbeat
        Drone = struct('position', [0 0 0], ...
            'rotation', [0 0 0], ...
            'onGround', true, ...
            'waypoints', [], ...
            'missionLength', 0, ...
            'systemID', 1, ...
            'uploadComplete', false, ...
            'lastHeartbeat', clock);
        MissionRequestSubscriber
        MissionAckSubscriber
        HeartbeatSubscriber
        UAVPositionSubscriber
    end
    
    methods
        function obj = GCSHandler(io)
            %GCSHandler Construct an instance of this class
            %   Detailed explanation goes here
            obj.IO = io;
            obj.MissionRequestSubscriber = mavlinksub(io, 'MISSION_REQUEST_INT', ...
                'BufferSize', 1, ...
                'NewMessageFcn', ...
                @(~, msg) GCSHandler.missionRequestCallback(msg, obj));
            obj.MissionAckSubscriber = mavlinksub(io, 'MISSION_ACK', ...
                'BufferSize', 1, ...
                'NewMessageFcn', ...
                @(~, msg) GCSHandler.missionAckCallback(msg, obj));
            obj.HeartbeatSubscriber = mavlinksub(io, 'HEARTBEAT', ...
                'BufferSize', 1, ...
                'NewMessageFcn', ...
                @(~, msg) GCSHandler.heartbeatCallback(msg, obj));
            obj.UAVPositionSubscriber = mavlinksub(io, 'GPS_RAW_INT', ...
                'BufferSize', 1,...
                'NewMessageFcn', ...
                @(~, msg) GCSHandler.uavPositionCallback(msg, obj));
            
                heartbeatmsg = io.Dialect.createmsg('HEARTBEAT');
                heartbeatmsg.Payload.autopilot(:) = uint8(io.Dialect.enum2num('MAV_AUTOPILOT', 'MAV_AUTOPILOT_INVALID'));
                heartbeatmsg.Payload.type(:) = uint8(io.Dialect.enum2num('MAV_TYPE', 'MAV_TYPE_GCS'));
                heartbeatmsg.Payload.system_status(:) = uint8(io.Dialect.enum2num('MAV_STATE', 'MAV_STATE_ACTIVE'));
                heartbeatmsg.Payload.base_mode(:) = uint8(bitor(io.Dialect.enum2num('MAV_MODE_FLAG', 'MAV_MODE_FLAG_GUIDED_ENABLED'),  ...
                io.Dialect.enum2num('MAV_MODE_FLAG', 'MAV_MODE_FLAG_SAFETY_ARMED'))) ;

                obj.Heartbeat = timer;
                obj.Heartbeat.ExecutionMode = 'fixedRate';
                obj.Heartbeat.Period = 2;
                obj.Heartbeat.StartDelay = 0;
                obj.Heartbeat.TimerFcn = @(~,~) io.sendmsg(heartbeatmsg);
                start(obj.Heartbeat);
        end
        
        function sendWaypoints(obj, waypoints)
            obj.Drone.waypoints = waypoints;
            obj.Drone.uploadComplete = false;
            obj.Drone.missionLength = length(obj.Drone.waypoints);
            dialect = obj.IO.Dialect;
            client = mavlinkclient(obj.IO, 1, 1);
            msg = dialect.createmsg('MISSION_COUNT');
            msg.Payload.target_system(:) = 1;
            msg.Payload.target_component(:) = 1;
            msg.Payload.count(:) = length(obj.Drone.waypoints);
            msg.Payload.mission_type(:) = enum2num(dialect, 'MAV_MISSION_TYPE',"MAV_MISSION_TYPE_MISSION");
            obj.IO.sendmsg(msg, client);
        end
        function complete = isUploadComplete(obj)
            complete = obj.Drone.uploadComplete;
        end
        function active = isDroneActive(obj)
            elapsed = etime(clock, obj.Drone.lastHeartbeat);
            active = elapsed < 2;
        end
        function delete(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            delete(obj.MissionRequestSubscriber);
            delete(obj.MissionAckSubscriber);
            delete(obj.HeartbeatSubscriber);
            delete(obj.UAVPositionSubscriber);
            stop(obj.Heartbeat);
            delete(obj.Heartbeat);
            
        end
    end

    methods(Static)
        function missionRequestCallback(msg, handler)
            %TODO: RESEND MESSAGE IF TIMEOUT
            dialect = handler.IO.Dialect;
            client = mavlinkclient(handler.IO, msg.SystemID, msg.ComponentID);
            outMsg = dialect.createmsg('MISSION_ITEM_INT');
            
            outMsg.Payload.target_system(:) = 1;
            
            outMsg.Payload.target_component(:) = 1;
            outMsg.Payload.seq(:) = msg.Payload.seq;
            outMsg.Payload.frame(:) = enum2num(handler.IO.Dialect,'MAV_FRAME',"MAV_FRAME_GLOBAL");
            %TODO: ENTER VALUES FOR PARAM1,..., PARAM4
            if msg.Payload.seq == 0 
                outMsg.Payload.command(:) = enum2num(handler.IO.Dialect,'MAV_CMD',"MAV_CMD_NAV_TAKEOFF");
                outMsg.Payload.param1(:) = 0;
                outMsg.Payload.param4(:) = nan;
            else
                if msg.Payload.seq == handler.Drone.missionLength - 1
                    outMsg.Payload.command(:) = enum2num(handler.IO.Dialect, 'MAV_CMD', "MAV_CMD_NAV_LAND");
                else
                    outMsg.Payload.command(:) = enum2num(handler.IO.Dialect, 'MAV_CMD', "MAV_CMD_NAV_WAYPOINT");
                end 
            end
            
            outMsg.Payload.current(:) = 0;
            outMsg.Payload.autocontinue(:) = 1;
            if(isempty(handler.Drone.waypoints))
                disp("Empty")
            else
            outMsg.Payload.x(:) = handler.Drone.waypoints(msg.Payload.seq + 1, 1) * 10^7;
            outMsg.Payload.y(:) = handler.Drone.waypoints(msg.Payload.seq + 1, 2) * 10^7;
            outMsg.Payload.z(:) = handler.Drone.waypoints(msg.Payload.seq + 1, 3);
            outMsg.Payload.mission_type(:) = enum2num(handler.IO.Dialect, 'MAV_MISSION_TYPE', "MAV_MISSION_TYPE_MISSION"); 
            end
            handler.IO.sendmsg(outMsg, client);
        end
        function missionAckCallback(msg, handler)
            handler.Drone.uploadComplete = true;
        end
        function heartbeatCallback(msg, handler)
            %TODO: ADD TIMER TO DETECT IF DRONE IS STILL ACTIVE
            handler.Drone.lastHeartbeat = clock;
        end
        function uavPositionCallback(msg, handler)
            handler.Drone.position = [double(msg.Payload.lat)/10^7 ...
                double(msg.Payload.lon)/10^7 ...
                double(msg.Payload.alt) /1000];
        end
        
    end
end

