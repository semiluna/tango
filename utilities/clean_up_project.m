function clean_up_project()
%clean_up_project   Clean up local customizations of the task
% 
%   Clean up the task for the current project. This function undoes
%   the settings applied in "set_up_project". It is set to Run at Shutdown.
%   Copyright 2018 The MathWorks, Inc.

%% Clean up Variables
if evalin('base','exist(''setupVars'')')
    for i=1: evalin('base','length(setupVars)')
        evalin('base', ['clear(setupVars{' num2str(i) '});']) 
    end
end

evalin('base', 'clear setupVars');

%% Reset the location where generated code and other temporary files are
% created (slprj) to the default:
Simulink.fileGenControl('reset');

end
