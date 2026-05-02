function config = project_config()
%PROJECT_CONFIG Central configuration for the vehicle control project.
%
% Change only this file when switching from the Vehicle Stub model
% to the real integrated vehicle model.

%% Simulink model

config.model_name = "scenario_test";

%% Results folders

config.results_root = "results";

config.input_checks_folder = fullfile(config.results_root, "input_checks");
config.vehicle_stub_folder = fullfile(config.results_root, "vehicle_stub");
config.vehicle_plots_folder = fullfile(config.vehicle_stub_folder, "plots");
config.vehicle_comparisons_folder = fullfile(config.vehicle_stub_folder, "comparisons");

%% Current model mode

config.using_vehicle_stub = true;

end