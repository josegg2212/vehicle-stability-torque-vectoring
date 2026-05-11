% Root folder
project_root = fileparts(fileparts(mfilename('fullpath')));
init_folder = fullfile(project_root, 'init');
scripts_folder = fullfile(project_root, 'scripts');
models_folder = fullfile(project_root, 'models');

cd(project_root);

% Add paths
addpath(init_folder);
addpath(scripts_folder);
addpath(models_folder, '-end');

% Create result folders if they do not exist
if ~exist(fullfile(project_root, 'results'), 'dir')
    mkdir(fullfile(project_root, 'results'));
end

if ~exist(fullfile(project_root, 'results', 'runs'), 'dir')
    mkdir(fullfile(project_root, 'results', 'runs'));
end

if ~exist(fullfile(project_root, 'results', 'figures'), 'dir')
    mkdir(fullfile(project_root, 'results', 'figures'));
end

if ~exist(fullfile(project_root, 'results', 'input_checks'), 'dir')
    mkdir(fullfile(project_root, 'results', 'input_checks'));
end

if ~exist(fullfile(project_root, 'results', 'full_system'), 'dir')
    mkdir(fullfile(project_root, 'results', 'full_system'));
end

if ~exist(fullfile(project_root, 'results', 'full_system', 'plots'), 'dir')
    mkdir(fullfile(project_root, 'results', 'full_system', 'plots'));
end

if ~exist(fullfile(project_root, 'results', 'full_system', 'comparisons'), 'dir')
    mkdir(fullfile(project_root, 'results', 'full_system', 'comparisons'));
end

if ~exist(fullfile(project_root, 'results', 'full_system', 'metrics'), 'dir')
    mkdir(fullfile(project_root, 'results', 'full_system', 'metrics'));
end

% Load parameter scripts
run(fullfile(init_folder, 'init_vehicle_params.m'));
run(fullfile(init_folder, 'init_controller_params.m'));
run(fullfile(init_folder, 'init_torque_allocator_params.m'));
run(fullfile(init_folder, 'init_demo_params.m'));

% Main Simulink model
model_name = 'full_system';

if ~bdIsLoaded(model_name)
    load_system(model_name);
end

% Default scenario data so model update works immediately after init.
if ~evalin('base', 'exist(''Tend'', ''var'')')
    selected_scenario = "double_lane_change"; %#ok<NASGU>
    run(fullfile(scripts_folder, 'init_full_system_scenario.m'));
end

if ~evalin('base', 'exist(''control_case'', ''var'')')
    control_case = 0; %#ok<NASGU>
    assignin('base', 'control_case', control_case);
end
