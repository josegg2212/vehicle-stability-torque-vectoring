%% prepare_all_demos_2D_3D.m
% Generates all demo inputs (2D and 3D) for:
%   4 scenarios x 3 control modes = 12 demo cases.
%
% Outputs:
%   results/runs/demos_2D/<scenario>/<scenario>_<case>_demo_2D_input_data.mat
%   results/runs/demos_3D/<scenario>/<scenario>_<case>_demo_3D_unreal_input_data.mat
%
% Also writes a manifest:
%   results/runs/demo_cases_manifest.csv

bdclose all;
clearvars;
clc;
close all;

%% Locate project root
script_dir = fileparts(mfilename("fullpath"));
project_root = fileparts(script_dir);

cd(project_root);
addpath(fullfile(project_root, "init"));
addpath(fullfile(project_root, "scripts"));

%% Initialize
run(fullfile(project_root, "init", "init_project_final.m"));
config = project_config();
model_name = config.model_name;

%% Cases
scenario_list = [
    "double_lane_change"
    "aggressive_corner"
    "low_mu_lane_change"
    "high_speed_low_mu_slalom"
];

control_case_list = [0 1 2];

%% Output folders
runs_root = config.runs_folder;
demos_2d_root = fullfile(runs_root, "demos_2D");
demos_3d_root = fullfile(runs_root, "demos_3D");

if ~exist(demos_2d_root, "dir")
    mkdir(demos_2d_root);
end

if ~exist(demos_3d_root, "dir")
    mkdir(demos_3d_root);
end

manifest = table();

%% Run all demo cases
for i = 1:numel(scenario_list)
    selected_scenario = scenario_list(i);
    assignin("base", "selected_scenario", selected_scenario);
    run(fullfile(project_root, "scripts", "init_full_system_scenario.m"));

    scenario_2d_folder = fullfile(demos_2d_root, char(selected_scenario));
    scenario_3d_folder = fullfile(demos_3d_root, char(selected_scenario));

    if ~exist(scenario_2d_folder, "dir")
        mkdir(scenario_2d_folder);
    end

    if ~exist(scenario_3d_folder, "dir")
        mkdir(scenario_3d_folder);
    end

    for j = 1:numel(control_case_list)
        control_case = control_case_list(j);
        control_case_name = control_case_to_name(control_case);

        disp("========================================");
        disp("Preparing demo case:");
        disp("  scenario: " + selected_scenario);
        disp("  control : " + control_case_name);
        disp("========================================");

        assignin("base", "control_case", control_case);

        out = sim(model_name, "StopTime", "Tend");
        check_required_logs(out);

        [data_2d, N] = build_demo_2d_data_struct(out, selected_scenario, control_case);

        case_base = char(selected_scenario + "_" + control_case_name);
        file_2d = fullfile(scenario_2d_folder, case_base + "_demo_2D_input_data.mat");
        save(file_2d, "-struct", "data_2d");

        % Build 3D data from the 2D fields (same conversion used by Unreal input flow).
        data_3d = build_demo_3d_data_struct(data_2d.t, data_2d.x, data_2d.y, data_2d.psi);
        file_3d = fullfile(scenario_3d_folder, case_base + "_demo_3D_unreal_input_data.mat");
        save(file_3d, "-struct", "data_3d");

        manifest = [manifest; table( ...
            string(selected_scenario), ...
            control_case, ...
            string(control_case_name), ...
            N, ...
            string(file_2d), ...
            string(file_3d), ...
            'VariableNames', { ...
                'scenario', ...
                'control_case', ...
                'control_case_name', ...
                'num_samples', ...
                'demo_2d_file', ...
                'demo_3d_file' ...
            })]; %#ok<AGROW>
    end
end

manifest_file = fullfile(runs_root, "demo_cases_manifest.csv");
writetable(manifest, manifest_file);

disp("========================================");
disp("All 12 demo datasets prepared successfully.");
disp("Manifest: " + string(manifest_file));
disp("========================================");


function [data_2d, N] = build_demo_2d_data_struct(out, selected_scenario, control_case)
N = length(out.logs_x.Time);

data_2d.t = out.logs_x.Time(:)';
data_2d.x = vectorize_signal(out.logs_x.Data, N);
data_2d.y = vectorize_signal(out.logs_y.Data, N);
data_2d.psi = vectorize_signal(out.logs_psi.Data, N);
data_2d.y_ref = vectorize_signal(out.logs_y_ref.Data, N);

data_2d.Vx = vectorize_signal(out.logs_Vx.Data, N);
data_2d.beta = vectorize_signal(out.logs_beta.Data, N);
data_2d.r = vectorize_signal(out.logs_r.Data, N);
data_2d.ay = vectorize_signal(out.logs_ay.Data, N);

data_2d.T_driver_total = vectorize_signal(out.logs_T_driver_total.Data, N);
data_2d.delta_ff = get_log_or_fallback(out, "logs_delta_ff", "logs_delta", N);
data_2d.delta_cmd = get_log_or_default(out, "logs_delta_cmd", N, data_2d.delta_ff);

data_2d.Mz_cmd = vectorize_signal(out.logs_Mz_cmd.Data, N);
data_2d.Mz_applied = vectorize_signal(out.logs_Mz_applied.Data, N);
data_2d.Mz_to_plant = vectorize_signal(out.logs_Mz_to_plant.Data, N);

data_2d.T_FL = vectorize_signal(out.logs_T_FL.Data, N);
data_2d.T_FR = vectorize_signal(out.logs_T_FR.Data, N);
data_2d.T_RL = vectorize_signal(out.logs_T_RL.Data, N);
data_2d.T_RR = vectorize_signal(out.logs_T_RR.Data, N);

data_2d.T_left_total = data_2d.T_FL + data_2d.T_RL;
data_2d.T_right_total = data_2d.T_FR + data_2d.T_RR;
data_2d.delta_T_lr = data_2d.T_right_total - data_2d.T_left_total;

data_2d.selected_scenario = selected_scenario;
data_2d.control_case = control_case;
end


function data_3d = build_demo_3d_data_struct(t, x, y, psi)
t = t(:);
x = x(:);
y = y(:);
psi = psi(:);

Ts_unreal = 1/60;
t_unreal = (t(1):Ts_unreal:t(end))';

X_ego = interp1(t, x, t_unreal, "linear", "extrap");
Y_ego = interp1(t, y, t_unreal, "linear", "extrap");
Yaw_ego = interp1(t, unwrap(psi), t_unreal, "linear", "extrap");

X_ego_ts = timeseries(X_ego, t_unreal);
Y_ego_ts = timeseries(Y_ego, t_unreal);
Yaw_ego_ts = timeseries(Yaw_ego, t_unreal);

data_3d.t_unreal = t_unreal;
data_3d.Ts_unreal = Ts_unreal;
data_3d.Tend_unreal = t_unreal(end);

data_3d.X_ego = X_ego;
data_3d.Y_ego = Y_ego;
data_3d.Yaw_ego = Yaw_ego;

data_3d.X_ego_ts = X_ego_ts;
data_3d.Y_ego_ts = Y_ego_ts;
data_3d.Yaw_ego_ts = Yaw_ego_ts;
end


function control_case_name = control_case_to_name(control_case)
switch control_case
    case 0
        control_case_name = "without_control";
    case 1
        control_case_name = "stability_control";
    case 2
        control_case_name = "torque_vectoring";
    otherwise
        error("Unsupported control_case value: %d", control_case);
end
end


function signal = vectorize_signal(raw_data, N)
signal = squeeze(raw_data);
signal = signal(:)';

if isempty(signal)
    signal = zeros(1, N);
elseif length(signal) == 1
    signal = signal * ones(1, N);
elseif length(signal) < N
    signal = [signal, signal(end) * ones(1, N - length(signal))];
elseif length(signal) > N
    signal = signal(1:N);
end
end


function signal = get_log_or_fallback(out, primary_name, fallback_name, N)
try
    signal = vectorize_signal(out.get(primary_name).Data, N);
catch
    signal = vectorize_signal(out.get(fallback_name).Data, N);
end
end


function signal = get_log_or_default(out, signal_name, N, default_signal)
try
    signal = vectorize_signal(out.get(signal_name).Data, N);
catch
    signal = default_signal;
end
end
