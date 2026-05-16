%% export_demo_2D_input_data_from_full_system.m
% Exports one full_system simulation to the input format required by
% demo_2D_from_data.m.

bdclose all;
clearvars;
clc;
close all;

%% Locate project root
script_dir = fileparts(mfilename("fullpath"));
project_root = fileparts(script_dir);

cd(project_root);
addpath(fullfile(project_root, "init"));
addpath(fullfile(project_root, "models"));
addpath(fullfile(project_root, "scripts"));

%% Initialize project
run(fullfile(project_root, "init", "init_project_final.m"));
config = project_config();
model_name = config.model_name;

%% Select demo case
% aggressive_corner + torque_vectoring
selected_scenario = "double_lane_change";
%selected_scenario = "aggressive_corner";
%selected_scenario = "low_mu_lane_change";
%control_case = 0;   % without_control
%control_case = 1;   % stability_control
control_case = 2;   % torque_vectoring

assignin("base", "selected_scenario", selected_scenario);
assignin("base", "control_case", control_case);

%% Load scenario
run(fullfile(project_root, "scripts", "init_full_system_scenario.m"));
assignin("base", "control_case", control_case);

%% Run model
open_system(fullfile(project_root, "full_system.slx"));
set_param(model_name, "SimulationCommand", "update");

out = sim(model_name, "StopTime", "Tend");

%% Check logs
check_required_logs(out);

%% Extract signals
N = length(out.logs_x.Time);
t = out.logs_x.Time(:)';

x = vectorize_signal(out.logs_x.Data, N);
y = vectorize_signal(out.logs_y.Data, N);
psi = vectorize_signal(out.logs_psi.Data, N);
y_ref = vectorize_signal(out.logs_y_ref.Data, N);

Vx = vectorize_signal(out.logs_Vx.Data, N);
beta = vectorize_signal(out.logs_beta.Data, N);
r = vectorize_signal(out.logs_r.Data, N);
ay = vectorize_signal(out.logs_ay.Data, N);

T_driver_total = vectorize_signal(out.logs_T_driver_total.Data, N);
delta_ff = get_log_or_fallback(out, "logs_delta_ff", "logs_delta", N);
delta_cmd = get_log_or_default(out, "logs_delta_cmd", N, delta_ff);

Mz_cmd = vectorize_signal(out.logs_Mz_cmd.Data, N);
Mz_applied = vectorize_signal(out.logs_Mz_applied.Data, N);
Mz_to_plant = vectorize_signal(out.logs_Mz_to_plant.Data, N);

T_FL = vectorize_signal(out.logs_T_FL.Data, N);
T_FR = vectorize_signal(out.logs_T_FR.Data, N);
T_RL = vectorize_signal(out.logs_T_RL.Data, N);
T_RR = vectorize_signal(out.logs_T_RR.Data, N);

T_left_total = T_FL + T_RL;
T_right_total = T_FR + T_RR;
delta_T_lr = T_right_total - T_left_total;

%% Save demo input file
runs_folder = config.runs_folder;

if ~exist(runs_folder, "dir")
    mkdir(runs_folder);
end

output_file = fullfile(runs_folder, "demo_2D_input_data.mat");

save(output_file, ...
    "t", "x", "y", "psi", ...
    "y_ref", ...
    "Vx", "beta", "r", "ay", ...
    "delta_ff", "delta_cmd", ...
    "T_driver_total", ...
    "Mz_cmd", "Mz_applied", "Mz_to_plant", ...
    "T_FL", "T_FR", "T_RL", "T_RR", ...
    "T_left_total", "T_right_total", "delta_T_lr", ...
    "selected_scenario", "control_case");

disp("========================================");
disp("Demo 2D input data exported correctly.");
disp("Scenario: " + selected_scenario);
disp("Control case: " + string(control_case));
disp("File: " + string(output_file));
disp("========================================");

%% Local helper
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
