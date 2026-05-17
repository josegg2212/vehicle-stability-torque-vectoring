%% Run all vehicle comparison plots
% This script generates comparison plots for all configured scenarios.

clc;
close all;

%% Locate project root and initialize
this_script = mfilename("fullpath");
scripts_folder = fileparts(this_script);
project_root = fileparts(scripts_folder);

cd(project_root);
addpath(scripts_folder);

run(fullfile(project_root, "init", "init_project_final.m"));

%% Scenario list
scenario_list = [
    "double_lane_change"
    "aggressive_corner"
    "low_mu_lane_change"
    "high_speed_low_mu_slalom"
];

%% Run comparisons

for i = 1:numel(scenario_list)

    selected_scenario = scenario_list(i);

    disp("========================================");
    disp("Generating comparison for scenario: " + selected_scenario);
    disp("========================================");

    plot_vehicle_comparison_for_scenario(selected_scenario);

end

disp("========================================");
disp("All vehicle comparison plots generated.");
disp("Saved in: " + string(fullfile(project_root, "results", "full_system", "comparisons")));
disp("========================================");
