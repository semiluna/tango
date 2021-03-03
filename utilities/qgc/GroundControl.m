classdef GroundControl < handle
    % GroundControl Add summary here
    %
    % This template includes the minimum set of functions required
    % to define a System object with discrete state.

    % Nontunable properties
    properties(Constant)
        GCSPort = 14550
        SystemID = 255
        ComponentID = 190
    end

    % Pre-computed constants
    properties(Access = public)
        IO
        Handler
        
    end
    methods(Access = public)
        function obj = GroundControl()
            % Perform one-time calculations, such as computing constants
            obj.IO = mavlinkio('common.xml', ...
            'SystemID', obj.SystemID, 'ComponentID', obj.ComponentID, ...
            'ComponentType', 'MAV_TYPE_GCS', ...
            'AutopilotType', 'MAV_AUTOPILOT_INVALID');
            obj.IO.connect("UDP", 'LocalPort', obj.GCSPort);
            obj.Handler = GCSHandler(obj.IO);
        end
        
        function rotation = getRotation(obj)
            % Rotation as yaw, pitch, roll
            rotation = obj.Handler.Drone.rotation;
        end
        function position = getPosition(obj)
            % Position as longitude(deg), latitude(deg), altitude(m)
            position = obj.Handler.Drone.position;
        end
        function valid = sendWaypoints(obj, waypoints)
            % Returns: valid - true if the drone is connected to the
            % MAVLink network
            valid = any(listClients(obj.IO).SystemID(:) == 1);
            if(~valid)
                return;
            end
            obj.Handler.sendWaypoints(waypoints);
        end
        function complete = isUploadComplete(obj)
            complete = obj.Handler.isUploadComplete();
        end
        function delete(obj)
            % Disconnects Ground Control from MAVLink network and cleans up
            % subscribers and heartbeat in Handler
            delete(obj.Handler);
            obj.IO.disconnect();
        end
    end
end
