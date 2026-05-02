% demo_2D_from_data.m
% Demo 2D final alimentada desde un archivo .mat con datos ya generados.
% Esta versión está preparada para integración con el modelo completo del grupo.
% No calcula la trayectoria ni el reparto de par: solo carga señales y las visualiza.
%
% Archivo de entrada esperado:
%   ../results/runs/demo_2D_input_data.mat
%
% Variables mínimas esperadas:
%   t, x, y, psi
%   Vx
%   T_driver_total
%   Mz_cmd, Mz_applied
%   T_FL, T_FR, T_RL, T_RR
%   T_left_total, T_right_total, delta_T_lr
%
% Variables opcionales:
%   beta, r, ay

clear; clc; close all;

% Inicializar el proyecto
run('../init/init_project.m');

%% Cargar datos de entrada

input_file = '../results/runs/demo_2D_input_data.mat';

if ~exist(input_file, 'file')
    error(['No se ha encontrado el archivo de entrada: ', input_file, ...
           newline, ...
           'Ejecuta primero create_demo_2D_input_from_synthetic.m o genera el archivo con datos reales.']);
end

load(input_file);

disp('Datos cargados correctamente para la demo 2D.');
disp(['Archivo: ', input_file]);

%% Comprobación de variables obligatorias

required_vars = { ...
    't', 'x', 'y', 'psi', ...
    'Vx', ...
    'T_driver_total', ...
    'Mz_cmd', 'Mz_applied', ...
    'T_FL', 'T_FR', 'T_RL', 'T_RR', ...
    'T_left_total', 'T_right_total', 'delta_T_lr'};

for i = 1:length(required_vars)
    if ~exist(required_vars{i}, 'var')
        error(['Falta la variable obligatoria: ', required_vars{i}]);
    end
end

%% Asegurar formato de vectores fila

t = t(:)';
x = x(:)';
y = y(:)';
psi = psi(:)';

Vx = Vx(:)';

T_driver_total = T_driver_total(:)';

Mz_cmd = Mz_cmd(:)';
Mz_applied = Mz_applied(:)';

T_FL = T_FL(:)';
T_FR = T_FR(:)';
T_RL = T_RL(:)';
T_RR = T_RR(:)';

T_left_total = T_left_total(:)';
T_right_total = T_right_total(:)';
delta_T_lr = delta_T_lr(:)';

% Variables opcionales de estabilidad.
% Si no existen, se crean como NaN para que la demo no falle.
if ~exist('beta', 'var')
    beta = NaN * ones(size(t));
else
    beta = beta(:)';
end

if ~exist('r', 'var')
    r = NaN * ones(size(t));
else
    r = r(:)';
end

if ~exist('ay', 'var')
    ay = NaN * ones(size(t));
else
    ay = ay(:)';
end

%% Comprobar longitud común

N = length(t);

signals_to_check = {x, y, psi, Vx, T_driver_total, Mz_cmd, Mz_applied, ...
                    T_FL, T_FR, T_RL, T_RR, ...
                    T_left_total, T_right_total, delta_T_lr};

for i = 1:length(signals_to_check)
    if length(signals_to_check{i}) ~= N
        error('Todas las señales deben tener la misma longitud que t.');
    end
end

%% Crear carpetas de resultados si no existen

if ~exist('../results/figures', 'dir')
    mkdir('../results/figures');
end

%% Guardar figura estática de trayectoria

figure;
plot(x, y, 'LineWidth', 1.5);
grid on;
xlabel('x [m]');
ylabel('y [m]');
title('Trayectoria cargada para la demo 2D');
axis equal;

saveas(gcf, '../results/figures/demo_2D_from_data_trajectory.png');

%% Crear figura principal de animación

fig = figure('Name', 'Demo 2D desde datos - Reparto de par', ...
    'Color', 'w', ...
    'Position', [60 40 1500 820]);

% Eje principal de carretera y animación
axRoad = axes('Parent', fig, 'Position', [0.05 0.12 0.63 0.78]);

% Eje exclusivo para texto del panel
axInfo = axes('Parent', fig, 'Position', [0.72 0.55 0.25 0.35]);
axis(axInfo, 'off');

% Eje para barras de reparto lateral
axSideTorque = axes('Parent', fig, 'Position', [0.74 0.34 0.22 0.14]);

% Eje para barras de par por rueda
axWheelTorque = axes('Parent', fig, 'Position', [0.74 0.12 0.22 0.16]);

% Caja de estado inferior
status_box = annotation(fig, 'textbox', [0.72 0.02 0.26 0.07], ...
    'String', '', ...
    'FitBoxToText', 'off', ...
    'EdgeColor', [0.20 0.20 0.20], ...
    'LineWidth', 1.2, ...
    'BackgroundColor', [0.96 0.96 0.96], ...
    'FontSize', 15, ...
    'FontWeight', 'bold', ...
    'FontName', 'Arial', ...
    'Interpreter', 'none', ...
    'VerticalAlignment', 'middle', ...
    'HorizontalAlignment', 'center');

% Título del panel lateral
annotation(fig, 'textbox', [0.72 0.91 0.26 0.05], ...
    'String', 'PANEL DE REPARTO DE PAR', ...
    'FitBoxToText', 'off', ...
    'EdgeColor', 'none', ...
    'BackgroundColor', 'none', ...
    'FontWeight', 'bold', ...
    'FontSize', 18, ...
    'FontName', 'Arial', ...
    'Interpreter', 'none', ...
    'HorizontalAlignment', 'center');

%% Configuración visual

% Si road_width, car_length o car_width no vinieran del init, se fijan valores de respaldo
if ~exist('road_width', 'var')
    road_width = 7.0;
end

if ~exist('car_length', 'var')
    car_length = 4.7;
end

if ~exist('car_width', 'var')
    car_width = 1.9;
end

% Límites verticales de la ventana
y_margin = 3.0;
y_min = min(y) - y_margin;
y_max = max(y) + y_margin;

% Evitar límites demasiado estrechos
if (y_max - y_min) < 10
    y_center = 0.5 * (y_max + y_min);
    y_min = y_center - 5;
    y_max = y_center + 5;
end

% Paso de animación
frame_step = 5;

% Límites de barras
max_side_torque = max([abs(T_left_total), abs(T_right_total)]) * 1.20;
max_wheel_torque = max(abs([T_FL, T_FR, T_RL, T_RR])) * 1.25;

% Protección por si todas las señales fueran cero
if max_side_torque == 0
    max_side_torque = 1;
end

if max_wheel_torque == 0
    max_wheel_torque = 1;
end

% Colores
road_color = [0.92 0.92 0.92];
trajectory_color = [0.70 0.70 0.70];

car_color_neutral = [0.10 0.30 0.90];
car_color_right   = [0.05 0.45 0.85];
car_color_left    = [0.90 0.35 0.10];

bar_color = [0.12 0.47 0.71];

%% Bucle de animación

for k = 1:frame_step:N

    %% Determinar estado del reparto

    if delta_T_lr(k) > 100
        reparto_estado = 'Más par en lado derecho';
        car_color = car_color_right;
        status_color = [0.88 0.95 1.00];
    elseif delta_T_lr(k) < -100
        reparto_estado = 'Más par en lado izquierdo';
        car_color = car_color_left;
        status_color = [1.00 0.92 0.86];
    else
        reparto_estado = 'Reparto casi equilibrado';
        car_color = car_color_neutral;
        status_color = [0.92 0.97 0.92];
    end

    %% Ventana móvil de la carretera

    x_window_min = x(k) - 25;
    x_window_max = x(k) + 35;

    %% Dibujar escena principal

    cla(axRoad);
    hold(axRoad, 'on');

    % Fondo de carretera
    fill(axRoad, ...
        [x_window_min x_window_max x_window_max x_window_min], ...
        [-road_width/2 -road_width/2 road_width/2 road_width/2], ...
        road_color, 'EdgeColor', 'none');

    % Línea central y bordes de carretera
    plot(axRoad, [x_window_min x_window_max], [0 0], 'k--', 'LineWidth', 1);
    plot(axRoad, [x_window_min x_window_max], [road_width/2 road_width/2], 'k', 'LineWidth', 1.2);
    plot(axRoad, [x_window_min x_window_max], [-road_width/2 -road_width/2], 'k', 'LineWidth', 1.2);

    % Trayectoria total y trayectoria recorrida
    plot(axRoad, x, y, 'Color', trajectory_color, 'LineWidth', 1.1);
    plot(axRoad, x(1:k), y(1:k), 'b', 'LineWidth', 2.2);

    % Dibujar coche como rectángulo orientado
    car_poly = get_car_polygon(x(k), y(k), psi(k), car_length, car_width);
    fill(axRoad, car_poly(1, :), car_poly(2, :), car_color, ...
        'EdgeColor', 'k', 'LineWidth', 1.4);

    % Marca frontal de orientación
    front_x = x(k) + (car_length/2) * cos(psi(k));
    front_y = y(k) + (car_length/2) * sin(psi(k));
    plot(axRoad, [x(k) front_x], [y(k) front_y], 'w', 'LineWidth', 2.5);

    % Configuración del eje principal
    axis(axRoad, 'equal');
    xlim(axRoad, [x_window_min x_window_max]);
    ylim(axRoad, [y_min y_max]);
    xlabel(axRoad, 'x [m]');
    ylabel(axRoad, 'y [m]');
    title(axRoad, 'Demo 2D desde datos: vehículo con reparto de par', ...
        'FontSize', 16, 'FontWeight', 'bold');
    grid(axRoad, 'on');

    %% Panel de información textual

    cla(axInfo);
    axis(axInfo, [0 1 0 1]);
    axis(axInfo, 'off');
    hold(axInfo, 'on');

    % Fondo del panel
    rectangle(axInfo, 'Position', [0.01 0.01 0.98 0.98], ...
        'FaceColor', [0.97 0.97 0.97], ...
        'EdgeColor', [0.25 0.25 0.25], ...
        'LineWidth', 1.5);

    % Título interior del panel
    text(axInfo, 0.05, 0.93, 'VALORES INSTANTÁNEOS', ...
        'FontSize', 14, ...
        'FontWeight', 'bold', ...
        'FontName', 'Arial', ...
        'Interpreter', 'none', ...
        'Color', [0.1 0.1 0.1]);

    % Valores opcionales de estabilidad como texto
    if isnan(beta(k))
        beta_text = '-';
    else
        beta_text = sprintf('%.3f', beta(k));
    end

    if isnan(r(k))
        r_text = '-';
    else
        r_text = sprintf('%.3f', r(k));
    end

    if isnan(ay(k))
        ay_text = '-';
    else
        ay_text = sprintf('%.2f', ay(k));
    end

    % Etiquetas y valores del panel
    % Se usa Interpreter = 'none' para evitar que "_" se interprete como subíndice.
    labels = { ...
        'Tiempo [s]', ...
        'Vx [m/s]', ...
        'beta [rad]', ...
        'r [rad/s]', ...
        'ay [m/s^2]', ...
        'T_driver_total [N*m]', ...
        'Mz_cmd [N*m]', ...
        'Mz_applied [N*m]', ...
        'T_FL [N*m]', ...
        'T_FR [N*m]', ...
        'T_RL [N*m]', ...
        'T_RR [N*m]', ...
        'T_left_total [N*m]', ...
        'T_right_total [N*m]', ...
        'Delta_T_LR [N*m]'};

    values = { ...
        sprintf('%.2f', t(k)), ...
        sprintf('%.2f', Vx(k)), ...
        beta_text, ...
        r_text, ...
        ay_text, ...
        sprintf('%.0f', T_driver_total(k)), ...
        sprintf('%.0f', Mz_cmd(k)), ...
        sprintf('%.0f', Mz_applied(k)), ...
        sprintf('%.0f', T_FL(k)), ...
        sprintf('%.0f', T_FR(k)), ...
        sprintf('%.0f', T_RL(k)), ...
        sprintf('%.0f', T_RR(k)), ...
        sprintf('%.0f', T_left_total(k)), ...
        sprintf('%.0f', T_right_total(k)), ...
        sprintf('%.0f', delta_T_lr(k))};

    y0 = 0.86;
    dy_text = 0.052;

    for i = 1:length(labels)

        y_text = y0 - (i-1) * dy_text;

        % Etiqueta de la variable
        text(axInfo, 0.05, y_text, labels{i}, ...
            'FontSize', 10.2, ...
            'FontName', 'Consolas', ...
            'FontWeight', 'bold', ...
            'Interpreter', 'none', ...
            'HorizontalAlignment', 'left', ...
            'VerticalAlignment', 'middle', ...
            'Color', [0.10 0.10 0.10]);

        % Valor numérico
        text(axInfo, 0.95, y_text, values{i}, ...
            'FontSize', 10.2, ...
            'FontName', 'Consolas', ...
            'Interpreter', 'none', ...
            'HorizontalAlignment', 'right', ...
            'VerticalAlignment', 'middle', ...
            'Color', [0.00 0.20 0.55]);

    end

    %% Barras de reparto lateral

    cla(axSideTorque);

    side_values = [T_left_total(k), T_right_total(k)];
    bh = barh(axSideTorque, side_values, 0.55);
    bh.FaceColor = bar_color;

    xlim(axSideTorque, [-max_side_torque max_side_torque]);
    yticks(axSideTorque, [1 2]);
    yticklabels(axSideTorque, {'Izq.', 'Der.'});
    xlabel(axSideTorque, 'Par total [N*m]');
    title(axSideTorque, 'Reparto lateral', 'FontSize', 13, 'FontWeight', 'bold');
    grid(axSideTorque, 'on');
    hold(axSideTorque, 'on');

    % Línea vertical en cero
    plot(axSideTorque, [0 0], [0.5 2.5], 'k', 'LineWidth', 1);

    %% Barras de par por rueda

    cla(axWheelTorque);

    wheel_values = [T_FL(k), T_FR(k), T_RL(k), T_RR(k)];
    bw = bar(axWheelTorque, wheel_values, 0.6);
    bw.FaceColor = bar_color;

    ylim(axWheelTorque, [-max_wheel_torque max_wheel_torque]);
    xticks(axWheelTorque, 1:4);
    xticklabels(axWheelTorque, {'FL', 'FR', 'RL', 'RR'});
    ylabel(axWheelTorque, 'Par [N*m]');
    title(axWheelTorque, 'Par por rueda', 'FontSize', 13, 'FontWeight', 'bold');
    grid(axWheelTorque, 'on');
    hold(axWheelTorque, 'on');

    % Línea horizontal en cero
    plot(axWheelTorque, [0.5 4.5], [0 0], 'k', 'LineWidth', 1);

    %% Actualizar caja de estado

    set(status_box, ...
        'String', reparto_estado, ...
        'BackgroundColor', status_color);

    drawnow;

end

disp('Demo 2D desde datos completada correctamente.');
disp('Figura de trayectoria guardada en results/figures.');

%% Función local: polígono del coche

function car_poly = get_car_polygon(xc, yc, psi, Lcar, Wcar)
% Calcula las esquinas de un rectángulo orientado que representa el coche.
%
% Entradas:
%   xc, yc : posición del centro del coche [m]
%   psi    : orientación del coche [rad]
%   Lcar   : longitud del coche [m]
%   Wcar   : anchura del coche [m]
%
% Salida:
%   car_poly : matriz 2x5 con el contorno cerrado del coche

    % Esquinas del coche en coordenadas locales
    local_corners = [ ...
         Lcar/2,  Wcar/2;
         Lcar/2, -Wcar/2;
        -Lcar/2, -Wcar/2;
        -Lcar/2,  Wcar/2;
         Lcar/2,  Wcar/2]';

    % Matriz de rotación
    R = [cos(psi), -sin(psi);
         sin(psi),  cos(psi)];

    % Transformar a coordenadas globales
    global_corners = R * local_corners;

    global_corners(1, :) = global_corners(1, :) + xc;
    global_corners(2, :) = global_corners(2, :) + yc;

    car_poly = global_corners;

end