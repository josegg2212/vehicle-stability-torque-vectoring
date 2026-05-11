%% Backward-compatibility wrapper
% Use scripts/init_full_system_scenario.m in new flows.

run(fullfile(fileparts(mfilename("fullpath")), "init_full_system_scenario.m"));
