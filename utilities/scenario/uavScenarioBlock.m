classdef uavScenarioBlock < matlab.System & matlab.system.mixin.Propagates & matlab.system.mixin.SampleTime
    %This function is for internal use only. It may be removed in the future.
    
    %uavScenarioBlock Incorporates a city block scenario in Simulink
    %simulation
    
    %   Copyright 2020 The MathWorks, Inc.
    
    properties(Nontunable)
        InitialPosition = [0 0 0]
        InitialOrientation = [0 0 0]
    end

    properties (Access = private)
        Scenario
        Lidar
        Platform
    end
    
    
    
    
    methods(Access = protected)
        function pts = stepImpl(obj, position, orientation)
            % return point cloud based on input pose
            
            obj.Scenario.advance();
            obj.Platform.move([position, zeros(1,6), eul2quat(orientation), zeros(1,3)]);
            obj.Scenario.updateSensors();
            [~, ~, ptCloud] = obj.Lidar.read();
            pts = ptCloud.Location;
            pts(:, 1:size(pts,2),:) = pts(:,size(pts,2):-1:1,:);
        end
        
        function setupImpl(obj)
            % Perform one-time calculations, such as computing constants
            obj.refresh();
        end
        
        function resetImpl(obj)
            % Initialize / reset discrete-state properties
            obj.refresh();
        end

        function out = getOutputSizeImpl(~)
            % Return size for each output port
            out = [32 1083 3];

            % Example: inherit size from first input port
            % out = propagatedInputSize(obj,1);
        end

        function out = getOutputDataTypeImpl(~)
            % Return data type for each output port
            out = "double";

            % Example: inherit data type from first input port
            % out = propagatedInputDataType(obj,1);
        end

        function out = isOutputComplexImpl(~)
            % Return true for each output port with complex data
            out = false;

            % Example: inherit complexity from first input port
            % out = propagatedInputComplexity(obj,1);
        end

        function out = isOutputFixedSizeImpl(~)
            % Return true for each output port with fixed size
            out = true;

            % Example: inherit fixed-size status from first input port
            % out = propagatedInputFixedSize(obj,1);
        end

        function sts = getSampleTimeImpl(obj)
            % Define sample time type and parameters
            sts = obj.createSampleTime("Type", "Discrete", ...
                "SampleTime", 0.5);
        end
    end

    methods(Access = protected, Static)
        function simMode = getSimulateUsingImpl
            % Return only allowed simulation mode in System block dialog
            simMode = "Interpreted execution";
        end
    end
    
    methods (Access = private)
        function refresh(obj)
            scene = uavScenario("UpdateRate", 2, "ReferenceLocation", [75 -46 0]);
            % floor
            scene.addMesh("polygon", {[-150 -250; -150 200; 180 200; 180 -250], [-4 0]}, 0.651*ones(1,3));
            % buildings
            waypointData = load("blockbuildingdata.mat");
            buildingDataNED = waypointData.wayPoints1;
            buildingDataENU = buildingDataNED;
            for idx = 1:numel(buildingDataNED)
                buildingDataENU{idx}(:,1) = buildingDataNED{idx}(:,2)-10.5;
                buildingDataENU{idx}(:,2) = buildingDataNED{idx}(:,1);
            end
            scene.addMesh("polygon", {buildingDataENU{1}(4:-1:1,:), [0 30]}, [0.3922 0.8314 0.0745]);
            scene.addMesh("polygon", {buildingDataENU{2}(2:5,:), [0 30]}, [0.3922 0.8314 0.0745]);
            scene.addMesh("polygon", {buildingDataENU{3}(2:10,:), [0 30]}, [0.3922 0.8314 0.0745]);
            scene.addMesh("polygon", {buildingDataENU{4}(2:9,:), [0 30]}, [0.3922 0.8314 0.0745]);
            scene.addMesh("polygon", {buildingDataENU{5}(1:end-1,:), [0 30]}, [0.3922 0.8314 0.0745]);
            scene.addMesh("polygon", {buildingDataENU{6}(1:end-1,:), [0 15]}, [0.3922 0.8314 0.0745]);
            scene.addMesh("polygon", {buildingDataENU{7}(1:end-1,:), [0 30]}, [0.3922 0.8314 0.0745]);
            scene.addMesh("polygon", {buildingDataENU{8}(2:end-1,:), [0 10]}, [0.3922 0.8314 0.0745]);
            scene.addMesh("polygon", {buildingDataENU{9}(1:end-1,:), [0 15]}, [0.3922 0.8314 0.0745]);
            scene.addMesh("polygon", {buildingDataENU{10}(1:end-1,:), [0 30]}, [0.3922 0.8314 0.0745]);
            scene.addMesh("polygon", {buildingDataENU{11}(1:end-2,:), [0 30]}, [0.3922 0.8314 0.0745]);
            obj.Scenario = scene;
            
            plat = uavPlatform("UAV", scene, "ReferenceFrame", "NED", ....
                "InitialPosition", obj.InitialPosition, "InitialOrientation", eul2quat(obj.InitialOrientation));
            plat.updateMesh("quadrotor", {3}, [1 0 0], eul2tform([0 0 pi]));
            obj.Platform = plat;
            
            lidarmodel = uavLidarPointCloudGenerator(...
                "AzimuthResolution", 0.3324099, "ElevationLimits", [-20 20],...
                "ElevationResolution", 1.25, "MaxRange", 90, ...
                "HasOrganizedOutput", true, "UpdateRate", 2);
            obj.Lidar = uavSensor("Lidar", plat, lidarmodel, "MountingLocation", [0,0,-0.4], "MountingAngles", [0 0 180]);
            
            setup(scene);
        end
        
    end
end
