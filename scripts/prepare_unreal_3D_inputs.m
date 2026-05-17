% prepare_unreal_3D_inputs.m
% Prepare 3D input signals from the exported 2D run data.

clearvars; clc; close all;

%% Project paths
script_dir = fileparts(mfilename("fullpath"));
project_root = fileparts(script_dir);
cd(project_root);

addpath(fullfile(project_root, "init"));
addpath(fullfile(project_root, "scripts"));
addpath(fullfile(project_root, "models"));

run(fullfile(project_root, "init", "init_project_final.m"));

%% Load source data
input_file = fullfile(project_root, "results", "runs", "demo_2D_input_data.mat");
if ~exist(input_file, "file")
    error("Missing input file: %s", input_file);
end
S = load(input_file);

required_vars = ["t", "x", "y", "psi"];
for i = 1:numel(required_vars)
    v = required_vars(i);
    if ~isfield(S, v)
        error("Variable %s was not found in %s", v, input_file);
    end
end

t = S.t(:);
x = S.x(:);
y = S.y(:);
psi = S.psi(:);

%% Resampling config for Unreal
Ts_unreal = 1/60;
t_unreal = (t(1):Ts_unreal:t(end))';

position_scale = 1.0;

if exist("flip_y", "var")
    flip_y_cfg = logical(flip_y);
else
    flip_y_cfg = false;
end

if exist("flip_yaw", "var")
    flip_yaw_cfg = logical(flip_yaw);
else
    flip_yaw_cfg = false;
end

%% Interpolate signals
X_ego = interp1(t, x, t_unreal, "linear", "extrap") * position_scale;
Y_ego = interp1(t, y, t_unreal, "linear", "extrap") * position_scale;
Yaw_ego = interp1(t, unwrap(psi), t_unreal, "linear", "extrap");

if flip_y_cfg
    Y_ego = -Y_ego;
end
if flip_yaw_cfg
    Yaw_ego = -Yaw_ego;
end

%% Create timeseries
X_ego_ts = timeseries(X_ego, t_unreal);
Y_ego_ts = timeseries(Y_ego, t_unreal);
Yaw_ego_ts = timeseries(Yaw_ego, t_unreal);

%% Send to base workspace (used by 3D launcher/model)
assignin("base", "X_ego_ts", X_ego_ts);
assignin("base", "Y_ego_ts", Y_ego_ts);
assignin("base", "Yaw_ego_ts", Yaw_ego_ts);
assignin("base", "X_ego", X_ego);
assignin("base", "Y_ego", Y_ego);
assignin("base", "Yaw_ego", Yaw_ego);
assignin("base", "t_unreal", t_unreal);
assignin("base", "Ts_unreal", Ts_unreal);
assignin("base", "Tend_unreal", t_unreal(end));

%% Save prepared data
output_file = fullfile(project_root, "results", "runs", "demo_3D_unreal_input_data.mat");
save(output_file, ...
    "t_unreal", "Ts_unreal", ...
    "X_ego", "Y_ego", "Yaw_ego", ...
    "X_ego_ts", "Y_ego_ts", "Yaw_ego_ts");

disp("========================================");
disp("3D input signals prepared.");
disp("File: " + string(output_file));
disp("========================================");
