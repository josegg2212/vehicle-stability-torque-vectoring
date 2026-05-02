%% Run all vehicle comparison plots
% This script generates comparison plots for all official scenarios.

clc;
close all;

%% Scenario list
scenario_list = [
    "double_lane_change"
    "aggressive_corner"
    "low_mu_lane_change"
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
disp("========================================");