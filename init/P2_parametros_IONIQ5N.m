% % =========================================================================
% % PRÁCTICA 2 / PROYECTO: Dinámica lateral del vehículo
% % Vehículo adaptado: Hyundai IONIQ 5 N
% % =========================================================================
% 
% % Parámetros del vehículo
% m  = 2230;          % [kg]
% Iz = 4200;          % [kg*m^2] estimación inicial razonable para el proyecto
% L  = 3.000;         % [m]
% 
% % Posición del centro de gravedad (estimación inicial)
% a = 1.45;           % [m] distancia CG -> eje delantero
% b = L - a;          % [m] distancia CG -> eje trasero
% 
% % Rigideces de deriva por neumático (estimaciones iniciales)
% Caf = 85000;        % [N/rad] delantera por rueda
% Car = 95000;        % [N/rad] trasera por rueda
% 
% % En el modelo de bicicleta se agrupan las ruedas del mismo eje
% Cf = 2 * Caf;       % [N/rad] eje delantero
% Cr = 2 * Car;       % [N/rad] eje trasero
% 
% % -------------------------------------------------------------------------
% % VELOCIDAD LONGITUDINAL DE TRABAJO
% % -------------------------------------------------------------------------
% % Para la primera versión del proyecto te recomiendo usar una velocidad
% % constante como en P5. Más adelante, si acoplas la dinámica longitudinal
% % real al modelo lateral, tendrás que recalcular estas matrices con Vx en
% % tiempo real o rehacer el bloque con integradores.
% Vx = 16;            % [m/s] velocidad de trabajo recomendada para arrancar
% 
% % Si quieres probar como en la práctica 2:
% % Vx_kmh = 115;
% % Vx = Vx_kmh / 3.6;
% 
% % Matrices del espacio de estados
% % Estados: x = [beta ; r]
% % Entrada: u = [delta]
% 
% A11 = -(Cf + Cr) / (m * Vx);
% A12 = (b * Cr - a * Cf) / (m * Vx^2) - 1;
% A21 = (b * Cr - a * Cf) / Iz;
% A22 = -(a^2 * Cf + b^2 * Cr) / (Iz * Vx);
% A = [A11, A12;
%      A21, A22];
% 
% B1 = Cf / (m * Vx);
% B2 = (a * Cf) / Iz;
% B  = [B1;
%       B2];
% 
% % Salidas:
% % 1) Vy = Vx * beta
% % 2) r  = r
% % 3) ay = Vx * (beta_dot + r)
% C = [Vx, 0;
%      0, 1;
%      Vx * A11, Vx * (A12 + 1)];
% 
% D = [0;
%      0;
%      Vx * B1];
% 
% % -------------------------------------------------------------------------
% % PARÁMETROS EXTRA DEL PROYECTO (por si los quieres ya en workspace)
% % -------------------------------------------------------------------------
% delta_max_deg = 30;         % [deg] valor razonable de volante equivalente
% Mz_max = 6000;              % [Nm] saturación inicial de momento corrector
% track_f = 1.667;            % [m]
% track_r = 1.6722;           % [m]
% track_mean = (track_f + track_r)/2;

% =========================================================================
% PROYECTO: dinámica lateral base con Mz
% Estados: [beta ; r]
% Entradas: [delta ; Mz]
% Salidas: [Vy ; r ; ay ; beta]
% =========================================================================

m  = 2230;      % kg
Iz = 4200;      % kg*m^2
L  = 3.000;     % m

a = 1.45;       % m
b = L - a;      % m

Caf = 85000;    % N/rad
Car = 95000;    % N/rad

Cf = 2*Caf;
Cr = 2*Car;
% Caf and Car are defined per wheel, so axle values are doubled.
Cf_axle = 2*Caf;
Cr_axle = 2*Car;
Vx_min = 1.0;   % m/s, numerical protection for low speed

Vx = 16;        % m/s

A11 = -(Cf + Cr) / (m * Vx);
A12 = (b * Cr - a * Cf) / (m * Vx^2) - 1;
A21 = (b * Cr - a * Cf) / Iz;
A22 = -(a^2 * Cf + b^2 * Cr) / (Iz * Vx);

A = [A11, A12;
     A21, A22];

B = [Cf/(m*Vx),   0;
     a*Cf/Iz,   1/Iz];

C = [Vx, 0;                 % Vy = Vx*beta
     0, 1;                  % r
     Vx*A11, Vx*(A12 + 1);  % ay = Vx*(beta_dot + r)
     1, 0];                 % beta

D = [0, 0;
     0, 0;
     Vx*B(1,1), 0;
     0, 0];
m = 2230;
g = 9.81;
rho = 1.202;
Cd = 0.313;
ancho = 1.940;
alto  = 1.585;
Af = 0.9 * ancho * alto;
f = 0.015;
Vx = 16;
