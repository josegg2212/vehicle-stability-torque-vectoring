%% Run all scenario input tests
% This script runs all available scenario input tests and saves plots and metrics.

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
if ~exist("results", "dir")
    mkdir("results");
end

all_input_metrics = table;

%% Run scenarios and control cases
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
        end

        disp("========================================");
        disp("Running scenario: " + selected_scenario);
        disp("Control case: " + control_case_name);
        disp("========================================");

        %% Load selected scenario
        run(fullfile(fileparts(mfilename("fullpath")), "init_full_system_scenario.m"));

        %% Send control case to Simulink workspace
        assignin("base", "control_case", control_case);

        %% Run Simulink model
        out = sim(model_name, "StopTime", "Tend");

       %% Plot and save input signals only once per scenario
        if control_case == 0
            plot_logged_inputs;
        end
        %% Compute metrics
        input_metrics = compute_input_metrics(out, selected_scenario, control_case);

        %% Save individual metrics
        individual_metrics_file = fullfile( ...
            "results", ...
            selected_scenario + "_" + control_case_name + "_input_metrics.csv" ...
        );

        writetable(input_metrics, individual_metrics_file);

        %% Accumulate metrics
        all_input_metrics = [all_input_metrics; input_metrics];

    end

end

%% Save global metrics table
global_metrics_file = fullfile("results", "all_input_metrics.csv");
writetable(all_input_metrics, global_metrics_file);

disp("========================================");
disp("All input scenarios completed.");
disp("Global metrics saved:");
disp(" - " + global_metrics_file);
disp("========================================");

disp(all_input_metrics);
