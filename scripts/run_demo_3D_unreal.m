% run_demo_3D_unreal.m
% Lanza la demo 3D basada en Unreal/Simulation 3D.
%
% Flujo:
%   1. Inicializa el proyecto.
%   2. Exporta datos del sistema completo a demo_2D_input_data.mat.
%   3. Prepara X_ego_ts, Y_ego_ts y Yaw_ego_ts.
%   4. Abre el modelo demo_3D_unreal.slx.
%   5. Configura solver y tiempo de simulación.
%
% La demo 3D no modifica full_system.slx.
% Solo visualiza los datos generados por el sistema completo.

clearvars; clc; close all;

%% Localizar raíz del proyecto

script_dir = fileparts(mfilename("fullpath"));
project_root = fileparts(script_dir);

cd(project_root);

addpath(fullfile(project_root, "init"));
addpath(fullfile(project_root, "models"));
addpath(fullfile(project_root, "scripts"));

%% Inicializar proyecto

run(fullfile(project_root, "init", "init_project_final.m"));

%% Exportar datos desde full_system

disp("========================================");
disp("Exportando datos del sistema completo...");
disp("========================================");

run(fullfile(project_root, "scripts", "export_demo_2D_input_data_from_full_system.m"));

%% Preparar señales para Unreal

disp("========================================");
disp("Preparando señales para Unreal...");
disp("========================================");

run(fullfile(project_root, "scripts", "prepare_unreal_3D_inputs.m"));

%% Abrir modelo 3D

model_file = fullfile(project_root, "models", "demo_3D_unreal.slx");

if ~exist(model_file, "file")
    error("No se ha encontrado el modelo 3D: " + string(model_file));
end

[~, model_name, ~] = fileparts(model_file);

load_system(model_file);

%% Configurar solver del modelo 3D

% Los bloques Simulation 3D trabajan normalmente a 60 Hz.
% El modelo contiene estados continuos, por eso usamos un solver continuo
% en paso fijo en lugar de FixedStepDiscrete.
set_param(model_name, "SolverType", "Fixed-step");
set_param(model_name, "Solver", "ode4");
set_param(model_name, "FixedStep", "1/60");

% Usamos la duración de las señales preparadas.
set_param(model_name, "StopTime", "Tend_unreal");

%% Abrir modelo para ejecutar manualmente

open_system(model_name);

disp("========================================");
disp("Modelo 3D preparado.");
disp("Pulsa Run en Simulink para lanzar la demo 3D.");
disp("========================================");
