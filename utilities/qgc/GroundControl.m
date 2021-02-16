classdef GroundControl < matlab.System
    % GroundControl Add summary here
    %
    % This template includes the minimum set of functions required
    % to define a System object with discrete state.

    % Nontunable properties
    properties(Nontunable)
        GCSPort = 14550
        SystemID = 255
    end

    % Pre-computed constants
    properties(Access = private)
        IO
        Handler
        
    end
    methods(Access = protected)
        function setupImpl(obj)
            % Perform one-time calculations, such as computing constants
            obj.IO = mavlinkio('common.xml', ...
            'SystemID', obj.SystemID, 'ComponentID', 0, ...
            'ComponentType', 'MAV_TYPE_GCS', ...
            'AutopilotType', 'MAV_AUTOPILOT_INVALID');
            obj.IO.connect("UDP");
            obj.handler = GCSHandler(obj.IO, Drone);
        end

        function [position, rotation] = stepImpl(obj, waypoints)
            % Implement algorithm. Calculate y as a function of input u and
            % discrete states.
            position = obj.Handler.drone.position;
            rotation = obj.Handler.drone.rotation;
            obj.Handler.drone.waypoints = waypoints;
        end

        function releaseImpl(obj)
            % Initialize / reset discrete-state properties
            delete(obj.Handler)
            obj.IO.disconnect();
        end
    end
end
