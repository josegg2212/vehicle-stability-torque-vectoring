% Auto-generated launcher for case: double_lane_change_stability_control
clearvars; clc; close all;
project_root = 'C:\Users\GLORIA\Desktop\glole\Uni\masterus\controlveh\proyecto_nuevo\vehicle-stability-torque-vectoring';
data_3d_file = 'C:\Users\GLORIA\Desktop\glole\Uni\masterus\controlveh\proyecto_nuevo\vehicle-stability-torque-vectoring\results\runs\demos_3D\double_lane_change\double_lane_change_stability_control_demo_3D_unreal_input_data.mat';
if ~exist(data_3d_file, 'file')
    error('3D case file not found: %s', data_3d_file);
end
load(data_3d_file);
assignin('base','X_ego_ts',X_ego_ts);
assignin('base','Y_ego_ts',Y_ego_ts);
assignin('base','Yaw_ego_ts',Yaw_ego_ts);
assignin('base','Ts_unreal',Ts_unreal);
assignin('base','Tend_unreal',Tend_unreal);
model_file = fullfile(project_root, 'models', 'demo_3D_unreal.slx');
load_system(model_file);
[~, model_name, ~] = fileparts(model_file);
set_param(model_name, 'SolverType', 'Fixed-step');
set_param(model_name, 'Solver', 'ode4');
set_param(model_name, 'FixedStep', '1/60');
set_param(model_name, 'StopTime', 'Tend_unreal');
open_system(model_name);
disp('3D case loaded: double_lane_change_stability_control');
disp('Press Run in Simulink to launch Unreal 3D visualization.');
