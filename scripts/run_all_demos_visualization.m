%% run_all_demos_visualization.m
% Batch visualization runner for the 9 official demo cases.
%
% What it does:
%   1) Reads results/runs/demo_cases_manifest.csv
%   2) Runs the 2D visualization for each case
%   3) Stores a case-specific trajectory image
%   4) Generates a per-case 3D launcher script
%
% Notes:
% - 2D animation windows are still shown by demo_2D_from_data.m.
% - 3D launchers load one case into base workspace and open demo_3D_unreal.slx.

bdclose all;
clearvars;
clc;
close all;

%% Locate project root
script_dir = fileparts(mfilename("fullpath"));
project_root = fileparts(script_dir);

cd(project_root);
addpath(fullfile(project_root, "scripts"));

%% Config and paths
config = project_config();

manifest_file = fullfile(config.runs_folder, "demo_cases_manifest.csv");
if ~exist(manifest_file, "file")
    error("Manifest not found: %s. Run scripts/prepare_all_demos_2D_3D.m first.", manifest_file);
end

opts = detectImportOptions(manifest_file, "Delimiter", ",");
opts = setvartype(opts, "string");
opts.VariableNamingRule = "preserve";
manifest = readtable(manifest_file, opts);

figures_2d_root = fullfile(config.figures_folder, "demos_2D");
launchers_3d_root = fullfile(config.runs_folder, "demos_3D", "launchers");

if ~exist(figures_2d_root, "dir")
    mkdir(figures_2d_root);
end

if ~exist(launchers_3d_root, "dir")
    mkdir(launchers_3d_root);
end

%% Run all 2D demos and generate 3D launchers
default_2d_input = fullfile(config.runs_folder, "demo_2D_input_data.mat");
default_2d_trajectory = fullfile(config.figures_folder, "demo_2D_from_data_trajectory.png");

for i = 1:height(manifest)
    scenario = get_manifest_col(manifest, "scenario", 1);
    control_case_name = get_manifest_col(manifest, "control_case_name", 3);
    file_2d = get_manifest_col(manifest, "demo_2d_file", 5);
    file_3d = get_manifest_col(manifest, "demo_3d_file", 6);

    scenario = scenario(i);
    control_case_name = control_case_name(i);
    file_2d = file_2d(i);
    file_3d = file_3d(i);

    case_id = scenario + "_" + control_case_name;

    disp("========================================");
    disp("Visualizing case: " + case_id);
    disp("========================================");

    if ~exist(file_2d, "file")
        warning("2D file missing, skipping: %s", file_2d);
    else
        s = load(file_2d);
        save(default_2d_input, "-struct", "s");

        run(fullfile(project_root, "scripts", "demo_2D_from_data.m"));
        close all;

        scenario_figure_folder = fullfile(figures_2d_root, char(scenario));
        if ~exist(scenario_figure_folder, "dir")
            mkdir(scenario_figure_folder);
        end

        case_trajectory_file = fullfile( ...
            scenario_figure_folder, ...
            char(case_id + "_trajectory.png") ...
        );

        if exist(default_2d_trajectory, "file")
            copyfile(default_2d_trajectory, case_trajectory_file);
        else
            warning("2D trajectory figure was not generated for case: %s", case_id);
        end
    end

    if ~exist(file_3d, "file")
        warning("3D file missing, launcher not generated: %s", file_3d);
    else
        generate_3d_launcher(launchers_3d_root, scenario, control_case_name, file_3d, project_root);
    end
end

disp("========================================");
disp("Batch visualization flow completed.");
disp("2D figures folder: " + string(figures_2d_root));
disp("3D launchers folder: " + string(launchers_3d_root));
disp("========================================");


function generate_3d_launcher(launchers_root, scenario, control_case_name, file_3d, project_root)
case_id = scenario + "_" + control_case_name;
launcher_name = case_id + "_launch_3D.m";
launcher_path = fullfile(launchers_root, char(launcher_name));

fid = fopen(launcher_path, "w");
if fid < 0
    error("Cannot create 3D launcher: %s", launcher_path);
end

cleaner = onCleanup(@() fclose(fid)); %#ok<NASGU>

fprintf(fid, "%% Auto-generated launcher for case: %s\n", case_id);
fprintf(fid, "clearvars; clc; close all;\n");
fprintf(fid, "project_root = '%s';\n", strrep(project_root, "'", "''"));
fprintf(fid, "data_3d_file = '%s';\n", strrep(file_3d, "'", "''"));
fprintf(fid, "if ~exist(data_3d_file, 'file')\n");
fprintf(fid, "    error('3D case file not found: %%s', data_3d_file);\n");
fprintf(fid, "end\n");
fprintf(fid, "load(data_3d_file);\n");
fprintf(fid, "assignin('base','X_ego_ts',X_ego_ts);\n");
fprintf(fid, "assignin('base','Y_ego_ts',Y_ego_ts);\n");
fprintf(fid, "assignin('base','Yaw_ego_ts',Yaw_ego_ts);\n");
fprintf(fid, "assignin('base','Ts_unreal',Ts_unreal);\n");
fprintf(fid, "assignin('base','Tend_unreal',Tend_unreal);\n");
fprintf(fid, "model_file = fullfile(project_root, 'models', 'demo_3D_unreal.slx');\n");
fprintf(fid, "load_system(model_file);\n");
fprintf(fid, "[~, model_name, ~] = fileparts(model_file);\n");
fprintf(fid, "set_param(model_name, 'SolverType', 'Fixed-step');\n");
fprintf(fid, "set_param(model_name, 'Solver', 'ode4');\n");
fprintf(fid, "set_param(model_name, 'FixedStep', '1/60');\n");
fprintf(fid, "set_param(model_name, 'StopTime', 'Tend_unreal');\n");
fprintf(fid, "open_system(model_name);\n");
fprintf(fid, "disp('3D case loaded: %s');\n", case_id);
fprintf(fid, "disp('Press Run in Simulink to launch Unreal 3D visualization.');\n");
end


function col = get_manifest_col(tbl, preferred_name, fallback_idx)
if any(strcmp(tbl.Properties.VariableNames, preferred_name))
    col = string(tbl.(preferred_name));
else
    col = string(tbl{:, fallback_idx});
end
end
