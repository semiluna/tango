classdef GCSHandler < handle
    %GCSHandler Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        MaxMissionLength = 42
    end
    properties
        Drone = struct('position', [0 0 0], ...
            'rotation', [0 0 0], ...
            'home', [0 0 0], ...
            'active', false, ...
            'onGround', true, ...
            'waypoints', zeros(1, GCSHandler.MaxMissionLength), ...
            'missionLength', 0);
        MissionRequestSubscriber
        MissionAckSubscriber
        HeartbeatSubscriber
        UAVPositionSubscriber
    end
    
    methods
        function obj = GCSHandler(io, drone)
            %GCSHandler Construct an instance of this class
            %   Detailed explanation goes here
            obj.Drone = drone;
            obj.MissionRequestSubscriber = mavlinksub(io, 'MISSION_REQUEST_INT', ...
                'BufferSize', 30, ...
                'NewMessageFcn', ...
                @(~, msg) GCSHandler.missionRequestCallback(msg, io));
            obj.MissionAckSubscriber = mavlinksub(io, 'MISSION_ACK', ...
                'BufferSize', 3, ...
                'NewMessageFcn', ...
                @(~, msg) GCSHandler.missionAckCallback(msg, io));
            obj.HeartbeatSubscriber = mavlinksub(io, 'HEARTBEAT', ...
                'BufferSize', 1, ...
                'NewMessageFcn', ...
                @(~, msg) GCSHandler.heartbeatCallback(msg, io));
            obj.UAVPositionSubscriber = mavlinksub(io, 'GPS_RAW_INT', ...
                'BufferSize', 5,...
                'NewMessageFcn', ...
                @(~, msg) GCSHandler.uavPositionCallback(msg, io, obj));
        end
        
        
        
        function delete(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            delete(obj.MissionRequestSubscriber);
            delete(obj.MissionAckSubscriber);
            delete(obj.HeartbeatSubscriber);
            delete(obj.UAVPositionSubscriber);
        end
    end

    methods(Static)
        function missionRequestCallback(msg, io, handler)
            dialect = io.Dialect
            client = mavlinkclient(io, msg.SystemID, msg.ComponentID)
        end
        function missionAckCallback(msg, io, handler)
        end
        function heartbeatCallback(msg, io, handler)
            handler.drone.active = true;
        end
        function uavPositionCallback(msg, io, handler)
            handler.drone.position = [msg.Payload.lat msg.Payload.lon msg.Pyaload.alt];
        end
    end
end

