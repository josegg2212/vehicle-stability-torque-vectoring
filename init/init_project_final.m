clearvars;
clc;
close all;

% Root folder
project_root = fileparts(fileparts(mfilename('fullpath')));

% Add paths
addpath(fullfile(project_root, 'init'));
addpath(fullfile(project_root, 'models'));
addpath(fullfile(project_root, 'scripts'));

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

if ~exist(fullfile(project_root, 'results', 'tables'), 'dir')
    mkdir(fullfile(project_root, 'results', 'tables'));
end

if ~exist(fullfile(project_root, 'results', 'comparisons'), 'dir')
    mkdir(fullfile(project_root, 'results', 'comparisons'));
end

% Load parameter scripts
run('init_vehicle_params.m');
run('init_controller_params.m');
run('init_torque_allocator_params.m');
run('init_demo_params.m');

% Main Simulink model
model_name = 'full_system';