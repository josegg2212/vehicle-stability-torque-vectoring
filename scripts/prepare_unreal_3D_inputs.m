% prepare_unreal_3D_inputs.m
% Prepara las señales necesarias para mover el vehículo 3D en Unreal/Simulation 3D.
%
% Este script toma los datos ya exportados por:
%   export_demo_2D_input_data_from_full_system.m
%
% Archivo de entrada:
%   results/runs/demo_2D_input_data.mat
%
% Señales que genera:
%   X_ego_ts
%   Y_ego_ts
%   Yaw_ego_ts
%
% Estas señales se usan como entradas del modelo:
%   models/demo_3D_unreal.slx

clearvars; clc; close all;

%% Localizar la raíz del proyecto

script_dir = fileparts(mfilename("fullpath"));
project_root = fileparts(script_dir);

cd(project_root);

addpath(fullfile(project_root, "init"));
addpath(fullfile(project_root, "models"));
addpath(fullfile(project_root, "scripts"));

%% Inicializar proyecto

run(fullfile(project_root, "init", "init_project_final.m"));

%% Cargar datos exportados del sistema completo

input_file = fullfile(project_root, "results", "runs", "demo_2D_input_data.mat");

if ~exist(input_file, "file")
    error("No se ha encontrado demo_2D_input_data.mat. Ejecuta primero export_demo_2D_input_data_from_full_system.m");
end

load(input_file);

%% Comprobar variables necesarias

required_vars = ["t", "x", "y", "psi"];

for i = 1:length(required_vars)
    if ~exist(required_vars(i), "var")
        error("Falta la variable obligatoria: " + required_vars(i));
    end
end

%% Asegurar formato columna

t = t(:);
x = x(:);
y = y(:);
psi = psi(:);

%% Configuración de señales para Unreal

% Los bloques Simulation 3D suelen funcionar a 60 Hz.
% Por eso re-muestreamos las señales a 1/60 s.
Ts_unreal = 1/60;
t_unreal = (t(1):Ts_unreal:t(end))';

% Factor de escala de posición.
% Déjalo a 1.0 si la escena se ve bien.
% Si el coche aparece demasiado lejos, prueba 0.2 o 0.5.
position_scale = 1.0;

% Ajustes de signo.
% Si el coche se desplaza al lado contrario, cambiar flip_y a true.
% Si el coche gira al revés, cambiar flip_yaw a true.
flip_y = false;
flip_yaw = false;

%% Interpolar señales al tiempo de Unreal

X_ego = interp1(t, x, t_unreal, "linear", "extrap") * position_scale;
Y_ego = interp1(t, y, t_unreal, "linear", "extrap") * position_scale;

% unwrap evita saltos de ángulo si psi cruza pi/-pi.
psi_unwrapped = unwrap(psi);
Yaw_ego = interp1(t, psi_unwrapped, t_unreal, "linear", "extrap");

%% Aplicar ajustes de signo si hiciera falta

if flip_y
    Y_ego = -Y_ego;
end

if flip_yaw
    Yaw_ego = -Yaw_ego;
end

%% Crear señales timeseries para Simulink

X_ego_ts = timeseries(X_ego, t_unreal);
Y_ego_ts = timeseries(Y_ego, t_unreal);
Yaw_ego_ts = timeseries(Yaw_ego, t_unreal);

%% Enviar variables al Workspace base

assignin("base", "X_ego_ts", X_ego_ts);
assignin("base", "Y_ego_ts", Y_ego_ts);
assignin("base", "Yaw_ego_ts", Yaw_ego_ts);

assignin("base", "X_ego", X_ego);
assignin("base", "Y_ego", Y_ego);
assignin("base", "Yaw_ego", Yaw_ego);

assignin("base", "t_unreal", t_unreal);
assignin("base", "Ts_unreal", Ts_unreal);
assignin("base", "Tend_unreal", t_unreal(end));

%% Guardar datos preparados para la demo 3D

output_file = fullfile(project_root, "results", "runs", "demo_3D_unreal_input_data.mat");

save(output_file, ...
    "t_unreal", "Ts_unreal", ...
    "X_ego", "Y_ego", "Yaw_ego", ...
    "X_ego_ts", "Y_ego_ts", "Yaw_ego_ts");

disp("========================================");
disp("Señales para demo 3D preparadas correctamente.");
disp("Archivo: " + string(output_file));
disp("Variables creadas en Workspace base:");
disp("  X_ego_ts");
disp("  Y_ego_ts");
disp("  Yaw_ego_ts");
disp("  Ts_unreal");
disp("  Tend_unreal");
disp("========================================");