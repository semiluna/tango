classdef GCSHandler < handle
    %GCSHandler Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        UAVInfo
        MissionRequestSubscriber
        MissionAckSubscriber
        HeartbeatSubscriber
    end
    
    methods
        function obj = GCSHandler(io)
            %GCSHandler Construct an instance of this class
            %   Detailed explanation goes here
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
        end
        
        function delete(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            delete(obj.MissionRequestSubscriber);
            delete(obj.MissionAckSubscriber);
            delete(obj.HeartbeatSubscriber);
        end
    end

    methods(Static)
        function missionRequestCallback(msg, io)
            dialect = io.Dialect
            client = mavlinkclient(io, msg.SystemID, msg.ComponentID)
        end
        function missionAckCallback(msg, io)
        end
        function heartbeatCallback(msg, io)
        end
    end
end

