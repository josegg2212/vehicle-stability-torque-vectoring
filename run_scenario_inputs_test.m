%% Run scenario input test
% This script loads one scenario, runs the Simulink test model,
% and plots the generated input signals.

clc;
close all;

%% Select scenario
% Available options:
% "double_lane_change"
% "aggressive_corner"
% "low_mu_lane_change"

%% AQUI CAMBIO ESCENARIO PARA GRAFICAS
selected_scenario = "double_lane_change";

%% Project configuration
config = project_config();
model_name = config.model_name;

%% Load selected scenario
run(fullfile(fileparts(mfilename("fullpath")), "scripts", "init_full_system_scenario.m"));

%% Run Simulink model
out = sim(model_name, "StopTime", "Tend");

%% Plot logged input signals
plot_logged_inputs;
%% Compute input metrics
input_metrics = compute_input_metrics(out, selected_scenario);

disp("Input metrics:");
disp(input_metrics);

%% Save input metrics
if ~exist("results", "dir")
    mkdir("results");
end

metrics_file = fullfile("results", selected_scenario + "_input_metrics.csv");
writetable(input_metrics, metrics_file);

disp("Input metrics saved:");
disp(" - " + metrics_file);

%% Confirmation message
disp("Scenario input test completed:");
disp("Scenario: " + selected_scenario);
