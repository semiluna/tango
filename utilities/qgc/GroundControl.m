classdef GroundControl < matlab.System
    % GroundControl Add summary here
    %
    % This template includes the minimum set of functions required
    % to define a System object with discrete state.

    % Nontunable properties
    properties(Nontunable)
        GCSPort = 14550
    end

    % Pre-computed constants
    properties(Access = private)
        Drones
        IO
        
    end
    methods(Access = protected)
        function setupImpl(obj)
            % Perform one-time calculations, such as computing constants
            obj.IO = mavlinkio("common.xml");
            obj.IO.connect("UDP");
        end

        function y = stepImpl(obj,u)
            % Implement algorithm. Calculate y as a function of input u and
            % discrete states.
            y = u;
        end

        function releaseImpl(obj)
            % Initialize / reset discrete-state properties
            obj.IO.disconnect();
        end
    end
end
