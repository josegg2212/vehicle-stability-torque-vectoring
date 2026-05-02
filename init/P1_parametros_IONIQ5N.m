% =========================================================================
% PARÁMETROS DEL VEHÍCULO: HYUNDAI IONIQ 5 N
% Adaptación de Práctica 1 - Dinámica longitudinal del vehículo
% =========================================================================

% --- Parámetros de masa y gravedad ---
m = 2230;          % Masa del vehículo [kg]
g = 9.81;          % Aceleración de la gravedad [m/s^2]

% --- Parámetros aerodinámicos ---
rho = 1.202;       % Densidad del aire [kg/m^3]
Cd = 0.313;        % Coeficiente aerodinámico [adimensional]

% Cálculo del área frontal (A = 0.9 * ancho * alto)
ancho = 1.940;     % Ancho del vehículo [m]
alto  = 1.585;     % Alto del vehículo [m]
A = 0.9 * ancho * alto;   % Área frontal estimada [m^2]

% --- Parámetros de rodadura ---
f = 0.015;         % Coeficiente de resistencia a la rodadura [adimensional]

% --- Parámetros adicionales útiles para el proyecto ---
L = 3.000;         % Distancia entre ejes [m]
track_f = 1.667;   % Vía delantera [m]
track_r = 1.6722;  % Vía trasera [m]

% Neumático 275/35R21
rw = ((21 * 25.4) + 2 * (275 * 0.35)) / 2000;   % Radio aproximado de rueda [m]

% Par total máximo útil como referencia de proyecto
T_driver_max = 740;    % [Nm] par total nominal
