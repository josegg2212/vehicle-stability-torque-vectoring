%% Run all full-system scenarios
% Executes all official scenarios under all control modes for full_system.

clc;
close all;

%% Locate project root and initialize
this_script = mfilename("fullpath");
project_root = fileparts(this_script);

cd(project_root);
addpath(fullfile(project_root, "scripts"));

run(fullfile(project_root, "init", "init_project_final.m"));

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
% 0 = without_control
% 1 = stability_control
% 2 = torque_vectoring
control_case_list = [0 1 2];

%% Ensure results folders exist
result_folders = {
    config.runs_folder
    config.full_system_folder
    config.vehicle_metrics_folder
    config.vehicle_plots_folder
};

for i = 1:numel(result_folders)
    folder = result_folders{i};
    if ~exist(folder, "dir")
        mkdir(folder);
    end
end

all_vehicle_metrics = table;

%% Run scenarios
for i = 1:numel(scenario_list)

    selected_scenario = scenario_list(i);
    assignin("base", "selected_scenario", selected_scenario);
    run(fullfile(project_root, "scripts", "init_full_system_scenario.m"));

    for j = 1:numel(control_case_list)

        control_case = control_case_list(j);
        control_case_name = control_case_to_name(control_case);

        disp("========================================");
        disp("Running full_system scenario: " + selected_scenario);
        disp("Control case: " + control_case_name);
        disp("========================================");

        %% Send control case to Simulink workspace
        assignin("base", "control_case", control_case);

        %% Run Simulink model
        out = sim(model_name, "StopTime", "Tend");

        %% Save simulation run
        run_file = fullfile( ...
            config.runs_folder, ...
            char(selected_scenario + "_" + control_case_name + "_full_system_run.mat") ...
        );

        save(run_file, "out", "selected_scenario", "control_case", "control_case_name");

        %% Compute vehicle metrics
        vehicle_metrics = compute_vehicle_metrics(out, selected_scenario, control_case);

        %% Plot vehicle response
        plot_vehicle_response(out, selected_scenario, control_case);

        %% Save individual metrics
        individual_file = fullfile( ...
            config.vehicle_metrics_folder, ...
            char(selected_scenario + "_" + control_case_name + "_vehicle_metrics.csv") ...
        );

        writetable(vehicle_metrics, individual_file);

        %% Accumulate metrics
        all_vehicle_metrics = [all_vehicle_metrics; vehicle_metrics]; %#ok<AGROW>

    end
end

%% Save global metrics table
global_file = fullfile(config.vehicle_metrics_folder, "all_full_system_metrics.csv");
writetable(all_vehicle_metrics, global_file);

disp("========================================");
disp("All full system scenarios completed.");
disp("Global vehicle metrics saved:");
disp(" - " + string(global_file));
disp("========================================");

disp(all_vehicle_metrics);


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
