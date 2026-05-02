%% Run all vehicle stub scenarios
% This script runs all scenarios and control cases using the current Vehicle Stub.
% Later, the same structure will be used with the real vehicle model.

clc;
close all;

%% Project configuration
config = project_config();
model_name = config.model_name;

%% Scenario list
scenario_list = [
    "double_lane_change"
    "aggressive_corner"
    "low_mu_lane_change"
];

%% Control cases
% 0 = without control
% 1 = stability control
% 2 = torque vectoring

control_case_list = [0 1 2];

%% Results folder

results_folder = fullfile("results", "full_system");

if ~exist(results_folder, "dir")
    mkdir(results_folder);
end

all_vehicle_metrics = table;

%% Run scenarios

for i = 1:numel(scenario_list)

    selected_scenario = scenario_list(i);

    for j = 1:numel(control_case_list)

        control_case = control_case_list(j);

        switch control_case
            case 0
                control_case_name = "without_control";
            case 1
                control_case_name = "stability_control";
            case 2
                control_case_name = "torque_vectoring";
            otherwise
                control_case_name = "unknown_case";
        end

        disp("========================================");
        disp("Running vehicle stub scenario: " + selected_scenario);
        disp("Control case: " + control_case_name);
        disp("========================================");

        %% Load selected scenario
        init_scenario_test;

        %% Send control case to Simulink workspace
        assignin("base", "control_case", control_case);

        %% Run Simulink model
        out = sim(model_name, "StopTime", "Tend");

        %% Compute vehicle metrics
        vehicle_metrics = compute_vehicle_metrics(out, selected_scenario, control_case);
        %% Plot vehicle response only once per scenario
        if control_case == 0
             plot_vehicle_response(out, selected_scenario, control_case);
        end

        %% Save individual metrics
        individual_file = fullfile( ...
            results_folder, ...
            selected_scenario + "_" + control_case_name + "_vehicle_metrics.csv" ...
        );

        writetable(vehicle_metrics, individual_file);

        %% Accumulate metrics
        all_vehicle_metrics = [all_vehicle_metrics; vehicle_metrics];

    end

end

%% Save global metrics table

global_file = fullfile(results_folder, "all_vehicle_stub_metrics.csv");
writetable(all_vehicle_metrics, global_file);

disp("========================================");
disp("All vehicle stub scenarios completed.");
disp("Global vehicle metrics saved:");
disp(" - " + global_file);
disp("========================================");

disp(all_vehicle_metrics);