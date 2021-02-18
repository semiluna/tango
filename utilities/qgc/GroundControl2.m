classdef GroundControl2 < handle
    % GroundControl Add summary here
    %
    % This template includes the minimum set of functions required
    % to define a System object with discrete state.

    % Nontunable properties
    properties(Constant)
        GCSPort = 14550
        SystemID = 255
    end

    % Pre-computed constants
    properties(Access = public)
        IO
        Handler
        
    end
    methods(Access = public)
        function obj = GroundControl2()
            % Perform one-time calculations, such as computing constants
            obj.IO = mavlinkio('common.xml', ...
            'SystemID', obj.SystemID, 'ComponentID', 190, ...
            'ComponentType', 'MAV_TYPE_GCS', ...
            'AutopilotType', 'MAV_AUTOPILOT_INVALID');
            obj.IO.connect("UDP", 'LocalPort', obj.GCSPort);
            obj.Handler = GCSHandler(obj.IO);
        end
        
        function [position, rotation] = getPosRot(obj)
            % Implement algorithm. Calculate y as a function of input u and
            % discrete states.
            position = obj.Handler.Drone.position;
            rotation = obj.Handler.Drone.rotation;
            
        end
        function sendWaypoints(obj, waypoints)
            
            %TEMP
            while(height(listClients(obj.IO)) <2) 
            end
%            pause(5);
            disp(listClients(obj.IO));
            %
            obj.Handler.Drone.waypoints = waypoints;
            obj.Handler.sendWaypoints();
        end
        function delete(obj)
            % Initialize / reset discrete-state properties
            disp("Destructor");
            delete(obj.Handler);
            obj.IO.disconnect();
        end
    end
end
