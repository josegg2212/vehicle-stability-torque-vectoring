function config = project_config()

%PROJECT_CONFIG Central configuration for the integrated vehicle control project.

% Scripts folder and project root
scripts_folder = fileparts(mfilename("fullpath"));
project_root = fileparts(scripts_folder);

%% Simulink model
config.model_name = "full_system";

%% Results folders
config.project_root = project_root;
config.results_root = fullfile(project_root, "results");
config.runs_folder = fullfile(config.results_root, "runs");
config.figures_folder = fullfile(config.results_root, "figures");

config.input_checks_folder = fullfile(config.results_root, "input_checks");

config.full_system_folder = fullfile(config.results_root, "full_system");
config.vehicle_plots_folder = fullfile(config.full_system_folder, "plots");
config.vehicle_comparisons_folder = fullfile(config.full_system_folder, "comparisons");
config.vehicle_metrics_folder = fullfile(config.full_system_folder, "metrics");

end
