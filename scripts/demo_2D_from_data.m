% demo_2D_from_data.m
% Visualiza una demo 2D usando datos ya exportados desde full_system.
% Adapta titulos/paneles al escenario y modo de control del archivo cargado.
% Dibuja una carretera alineada con la trayectoria para casos rectos y curvos.

clc;
close all;

%% Robust project paths
script_dir = fileparts(mfilename("fullpath"));
project_root = fileparts(script_dir);

addpath(fullfile(project_root, "init"));
addpath(fullfile(project_root, "scripts"));

run(fullfile(project_root, "init", "init_demo_params.m"));

%% Load input data
input_file = fullfile(project_root, "results", "runs", "demo_2D_input_data.mat");
if ~exist(input_file, "file")
    error("No se ha encontrado el archivo de entrada: %s", input_file);
end

load(input_file);

disp("Datos cargados correctamente para la demo 2D.");
disp("Archivo: " + string(input_file));

%% Required signals
required_vars = { ...
    "t", "x", "y", "psi", ...
    "Vx", "T_driver_total", ...
    "Mz_cmd", "Mz_applied", ...
    "T_FL", "T_FR", "T_RL", "T_RR", ...
    "T_left_total", "T_right_total", "delta_T_lr"};

for i = 1:numel(required_vars)
    if ~exist(required_vars{i}, "var")
        error("Falta la variable obligatoria: %s", required_vars{i});
    end
end

%% Normalize vector shape
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

if ~exist("beta", "var"), beta = NaN(size(t)); else, beta = beta(:)'; end
if ~exist("r", "var"), r = NaN(size(t)); else, r = r(:)'; end
if ~exist("ay", "var"), ay = NaN(size(t)); else, ay = ay(:)'; end

N = length(t);

signals_to_check = {x, y, psi, Vx, T_driver_total, Mz_cmd, Mz_applied, ...
                    T_FL, T_FR, T_RL, T_RR, T_left_total, T_right_total, delta_T_lr};
for i = 1:numel(signals_to_check)
    if length(signals_to_check{i}) ~= N
        error("Todas las senales deben tener la misma longitud que t.");
    end
end

%% Scenario/control metadata
scenario_name = "unknown_scenario";
if exist("selected_scenario", "var")
    scenario_name = string(selected_scenario);
end

control_case_name = "unknown_control";
if exist("control_case", "var")
    control_case_name = control_case_to_name(control_case);
end

scenario_label = scenario_to_spanish_label(scenario_name);
control_label = control_to_spanish_label(control_case_name);

main_title = "Demo 2D - " + scenario_label + " | " + control_label;
subtitle_case = "Caso: " + scenario_name + " | control_case: " + control_case_name;

%% Output folders and static trajectory figure
figures_folder = fullfile(project_root, "results", "figures");
if ~exist(figures_folder, "dir")
    mkdir(figures_folder);
end

figure;
plot(x, y, "LineWidth", 1.5);
grid on;
xlabel("x [m]");
ylabel("y [m]");
title("Trayectoria - " + scenario_label + " (" + control_case_name + ")");
axis equal;

saveas(gcf, fullfile(figures_folder, "demo_2D_from_data_trajectory.png"));

%% Visual configuration
if ~exist("road_width", "var"), road_width = 7.0; end
if ~exist("car_length", "var"), car_length = 4.7; end
if ~exist("car_width", "var"), car_width = 1.9; end

frame_step = 5;

max_side_torque = max([abs(T_left_total), abs(T_right_total)]) * 1.20;
max_wheel_torque = max(abs([T_FL, T_FR, T_RL, T_RR])) * 1.25;
if max_side_torque == 0, max_side_torque = 1; end
if max_wheel_torque == 0, max_wheel_torque = 1; end

road_color = [0.90 0.90 0.90];
lane_color = [0.18 0.18 0.18];
trajectory_color = [0.65 0.65 0.65];
car_color_neutral = [0.10 0.30 0.90];
car_color_right = [0.05 0.45 0.85];
car_color_left = [0.90 0.35 0.10];
bar_color = [0.12 0.47 0.71];

%% Fixed scenario road (independent from vehicle trajectory)
road_params = struct();
road_params.road_width = road_width;
road_params.x_data = x;
road_params.y_data = y;
road_params.project_root = project_root;

road_scene = drawScenarioRoad([], scenario_name, road_params, true);

%% Main animation figure
fig = figure("Name", "Demo 2D - Reparto de par", ...
    "Color", "w", ...
    "Position", [60 40 1500 820]);

axRoad = axes("Parent", fig, "Position", [0.05 0.12 0.63 0.78]);
axInfo = axes("Parent", fig, "Position", [0.72 0.55 0.25 0.35]); axis(axInfo, "off");
axSideTorque = axes("Parent", fig, "Position", [0.74 0.34 0.22 0.14]);
axWheelTorque = axes("Parent", fig, "Position", [0.74 0.12 0.22 0.16]);

status_box = annotation(fig, "textbox", [0.72 0.02 0.26 0.07], ...
    "String", "", ...
    "FitBoxToText", "off", ...
    "EdgeColor", [0.20 0.20 0.20], ...
    "LineWidth", 1.2, ...
    "BackgroundColor", [0.96 0.96 0.96], ...
    "FontSize", 13, ...
    "FontWeight", "bold", ...
    "FontName", "Arial", ...
    "Interpreter", "none", ...
    "VerticalAlignment", "middle", ...
    "HorizontalAlignment", "center");

annotation(fig, "textbox", [0.72 0.91 0.26 0.06], ...
    "String", "PANEL DE REPARTO DE PAR", ...
    "FitBoxToText", "off", ...
    "EdgeColor", "none", ...
    "BackgroundColor", "none", ...
    "FontWeight", "bold", ...
    "FontSize", 16, ...
    "FontName", "Arial", ...
    "Interpreter", "none", ...
    "HorizontalAlignment", "center");

% Draw complete fixed road once before animation
axes(axRoad); %#ok<LAXES>
road_scene = drawScenarioRoad(axRoad, scenario_name, road_params, false);
hold(axRoad, "on");

%% Animation loop
traj_full_h = plot(axRoad, x, y, "Color", trajectory_color, "LineWidth", 1.1, ...
    "DisplayName", "Trayectoria real total");
traj_run_h = plot(axRoad, x(1), y(1), "b", "LineWidth", 2.2, ...
    "DisplayName", "Trayectoria recorrida");
car_h = fill(axRoad, NaN, NaN, car_color_neutral, "EdgeColor", "k", "LineWidth", 1.4);
front_h = plot(axRoad, NaN, NaN, "w", "LineWidth", 2.5);

legend(axRoad, [traj_full_h, traj_run_h], "Location", "northwest");

for k = 1:frame_step:N
    if delta_T_lr(k) > 100
        reparto_estado = "Mas par en lado derecho";
        car_color = car_color_right;
        status_color = [0.88 0.95 1.00];
    elseif delta_T_lr(k) < -100
        reparto_estado = "Mas par en lado izquierdo";
        car_color = car_color_left;
        status_color = [1.00 0.92 0.86];
    else
        reparto_estado = "Reparto casi equilibrado";
        car_color = car_color_neutral;
        status_color = [0.92 0.97 0.92];
    end

    car_poly = get_car_polygon(x(k), y(k), psi(k), car_length, car_width);
    set(car_h, "XData", car_poly(1, :), "YData", car_poly(2, :), "FaceColor", car_color);
    set(traj_run_h, "XData", x(1:k), "YData", y(1:k));

    front_x = x(k) + (car_length/2) * cos(psi(k));
    front_y = y(k) + (car_length/2) * sin(psi(k));
    set(front_h, "XData", [x(k), front_x], "YData", [y(k), front_y]);

    title(axRoad, {char(main_title), char(subtitle_case)}, "FontSize", 14, "FontWeight", "bold");

    cla(axInfo);
    axis(axInfo, [0 1 0 1]);
    axis(axInfo, "off");
    hold(axInfo, "on");

    rectangle(axInfo, "Position", [0.01 0.01 0.98 0.98], ...
        "FaceColor", [0.97 0.97 0.97], ...
        "EdgeColor", [0.25 0.25 0.25], ...
        "LineWidth", 1.5);

    text(axInfo, 0.05, 0.93, "VALORES INSTANTANEOS", ...
        "FontSize", 13, "FontWeight", "bold", "FontName", "Arial", "Interpreter", "none");
    text(axInfo, 0.05, 0.88, "Escenario: " + scenario_name, ...
        "FontSize", 9.5, "FontName", "Consolas", "Interpreter", "none");
    text(axInfo, 0.05, 0.84, "Control: " + control_case_name, ...
        "FontSize", 9.5, "FontName", "Consolas", "Interpreter", "none");

    beta_text = number_or_dash(beta(k), "%.3f");
    r_text = number_or_dash(r(k), "%.3f");
    ay_text = number_or_dash(ay(k), "%.2f");

    labels = { ...
        "Tiempo [s]", "Vx [m/s]", "beta [rad]", "r [rad/s]", "ay [m/s^2]", ...
        "T_driver_total [N*m]", "Mz_cmd [N*m]", "Mz_applied [N*m]", ...
        "T_FL [N*m]", "T_FR [N*m]", "T_RL [N*m]", "T_RR [N*m]", ...
        "T_left_total [N*m]", "T_right_total [N*m]", "Delta_T_LR [N*m]"};

    values = { ...
        sprintf("%.2f", t(k)), sprintf("%.2f", Vx(k)), beta_text, r_text, ay_text, ...
        sprintf("%.0f", T_driver_total(k)), sprintf("%.0f", Mz_cmd(k)), sprintf("%.0f", Mz_applied(k)), ...
        sprintf("%.0f", T_FL(k)), sprintf("%.0f", T_FR(k)), sprintf("%.0f", T_RL(k)), sprintf("%.0f", T_RR(k)), ...
        sprintf("%.0f", T_left_total(k)), sprintf("%.0f", T_right_total(k)), sprintf("%.0f", delta_T_lr(k))};

    y0 = 0.78;
    dy_text = 0.048;
    for i = 1:numel(labels)
        y_text = y0 - (i-1) * dy_text;
        text(axInfo, 0.05, y_text, labels{i}, "FontSize", 9.6, "FontName", "Consolas", ...
            "FontWeight", "bold", "Interpreter", "none", "HorizontalAlignment", "left");
        text(axInfo, 0.95, y_text, values{i}, "FontSize", 9.6, "FontName", "Consolas", ...
            "Interpreter", "none", "HorizontalAlignment", "right", "Color", [0.00 0.20 0.55]);
    end

    cla(axSideTorque);
    side_values = [T_left_total(k), T_right_total(k)];
    bh = barh(axSideTorque, side_values, 0.55);
    bh.FaceColor = bar_color;
    xlim(axSideTorque, [-max_side_torque max_side_torque]);
    yticks(axSideTorque, [1 2]);
    yticklabels(axSideTorque, {"Izq.", "Der."});
    xlabel(axSideTorque, "Par total [N*m]");
    title(axSideTorque, "Reparto lateral", "FontSize", 12, "FontWeight", "bold");
    grid(axSideTorque, "on");
    hold(axSideTorque, "on");
    plot(axSideTorque, [0 0], [0.5 2.5], "k", "LineWidth", 1);

    cla(axWheelTorque);
    wheel_values = [T_FL(k), T_FR(k), T_RL(k), T_RR(k)];
    bw = bar(axWheelTorque, wheel_values, 0.6);
    bw.FaceColor = bar_color;
    ylim(axWheelTorque, [-max_wheel_torque max_wheel_torque]);
    xticks(axWheelTorque, 1:4);
    xticklabels(axWheelTorque, {"FL", "FR", "RL", "RR"});
    ylabel(axWheelTorque, "Par [N*m]");
    title(axWheelTorque, "Par por rueda", "FontSize", 12, "FontWeight", "bold");
    grid(axWheelTorque, "on");
    hold(axWheelTorque, "on");
    plot(axWheelTorque, [0.5 4.5], [0 0], "k", "LineWidth", 1);

    set(status_box, "String", char(reparto_estado), "BackgroundColor", status_color);
    drawnow;
end

disp("Demo 2D desde datos completada correctamente.");
disp("Figura de trayectoria guardada en results/figures.");

%% Local helpers
function out = number_or_dash(value, fmt)
if isnan(value)
    out = "-";
else
    out = sprintf(fmt, value);
end
end

function label = scenario_to_spanish_label(name)
switch string(name)
    case "double_lane_change"
        label = "Doble cambio de carril";
    case "aggressive_corner"
        label = "Curva sostenida agresiva";
    case "low_mu_lane_change"
        label = "Cambio de carril con baja adherencia";
    otherwise
        label = "Escenario no identificado";
end
end

function label = control_to_spanish_label(control_case_name)
switch string(control_case_name)
    case "without_control"
        label = "Sin control";
    case "stability_control"
        label = "Control de estabilidad";
    case "torque_vectoring"
        label = "Torque vectoring";
    otherwise
        label = "Modo no identificado";
end
end

function control_case_name = control_case_to_name(control_case)
switch control_case
    case 0
        control_case_name = "without_control";
    case 1
        control_case_name = "stability_control";
    case 2
        control_case_name = "torque_vectoring";
    otherwise
        control_case_name = "unknown_control";
end
end

function car_poly = get_car_polygon(xc, yc, psi, Lcar, Wcar)
local_corners = [ ...
     Lcar/2,  Wcar/2;
     Lcar/2, -Wcar/2;
    -Lcar/2, -Wcar/2;
    -Lcar/2,  Wcar/2;
     Lcar/2,  Wcar/2]';

R = [cos(psi), -sin(psi);
     sin(psi),  cos(psi)];

global_corners = R * local_corners;
global_corners(1, :) = global_corners(1, :) + xc;
global_corners(2, :) = global_corners(2, :) + yc;

car_poly = global_corners;
end

function road_scene = drawScenarioRoad(ax, scenario_name, params, dry_run)
if nargin < 4
    dry_run = false;
end

road_width = params.road_width;
x_data = params.x_data;
y_data = params.y_data;

x_min_data = min(x_data) - 20;
x_max_data = max(x_data) + 40;
y_min_data = min(y_data) - 20;
y_max_data = max(y_data) + 20;

switch string(scenario_name)
    case {"double_lane_change", "low_mu_lane_change"}
        cx = linspace(x_min_data, x_max_data, 400);
        cy = zeros(size(cx));

        left_x = cx;
        left_y = cy + road_width/2;
        right_x = cx;
        right_y = cy - road_width/2;

        road_scene.center_x = cx;
        road_scene.center_y = cy;
        road_scene.left_x = left_x;
        road_scene.left_y = left_y;
        road_scene.right_x = right_x;
        road_scene.right_y = right_y;
        road_scene.xlim = [x_min_data, x_max_data];
        road_scene.ylim = [min([right_y y_min_data])-2, max([left_y y_max_data])+2];

        if dry_run
            return;
        end

        hold(ax, "on");
        fill(ax, [left_x fliplr(right_x)], [left_y fliplr(right_y)], [0.90 0.90 0.90], "EdgeColor", "none");
        plot(ax, left_x, left_y, "k", "LineWidth", 1.3);
        plot(ax, right_x, right_y, "k", "LineWidth", 1.3);
        plot(ax, cx, cy, "k--", "LineWidth", 1.0);

        % Optional fixed reference path (from scenario definition)
        try
            scenario = scenario_library(string(scenario_name));
            x_ref = scenario.Vx0 * scenario.t_y_ref;
            y_ref = scenario.y_ref;
            plot(ax, x_ref, y_ref, "m--", "LineWidth", 1.4, "DisplayName", "Referencia y_ref");
        catch
            % Keep compatibility even if scenario_library is unavailable.
        end

        if string(scenario_name) == "low_mu_lane_change"
            zone_x0 = x_min_data + 0.30 * (x_max_data - x_min_data);
            zone_x1 = x_min_data + 0.75 * (x_max_data - x_min_data);
            zone_y0 = -road_width/2;
            zone_y1 = road_width/2;
            patch(ax, [zone_x0 zone_x1 zone_x1 zone_x0], [zone_y0 zone_y0 zone_y1 zone_y1], ...
                [1.00 0.88 0.88], "FaceAlpha", 0.40, "EdgeColor", [0.75 0.15 0.15], "LineStyle", "--");
            text(ax, zone_x0 + 1.0, zone_y1 - 0.6, "low \mu zone", ...
                "Color", [0.70 0.10 0.10], "FontWeight", "bold", "FontSize", 11);
        end

    case "aggressive_corner"
        L1 = 35;
        R = 45;
        theta_max = deg2rad(70);
        L2 = 50;

        n1 = 120; n2 = 180; n3 = 120;
        s1 = linspace(0, L1, n1);
        x1 = x_min_data + s1;
        y1 = zeros(size(x1));

        theta = linspace(0, theta_max, n2);
        xc = x1(end);
        yc = -R;
        x2 = xc + R * sin(theta);
        y2 = yc + R * (1 - cos(theta));

        x3 = x2(end) + linspace(0, L2, n3) * cos(theta_max);
        y3 = y2(end) + linspace(0, L2, n3) * sin(theta_max);

        cx = [x1, x2(2:end), x3(2:end)];
        cy = [y1, y2(2:end), y3(2:end)];

        [left_x, left_y, right_x, right_y] = offset_polyline(cx, cy, road_width/2);

        road_scene.center_x = cx;
        road_scene.center_y = cy;
        road_scene.left_x = left_x;
        road_scene.left_y = left_y;
        road_scene.right_x = right_x;
        road_scene.right_y = right_y;
        road_scene.xlim = [min([left_x right_x x_min_data]), max([left_x right_x x_max_data])];
        road_scene.ylim = [min([left_y right_y y_min_data]), max([left_y right_y y_max_data])];

        if dry_run
            return;
        end

        hold(ax, "on");
        fill(ax, [left_x fliplr(right_x)], [left_y fliplr(right_y)], [0.90 0.90 0.90], "EdgeColor", "none");
        plot(ax, left_x, left_y, "k", "LineWidth", 1.3);
        plot(ax, right_x, right_y, "k", "LineWidth", 1.3);
        plot(ax, cx, cy, "k--", "LineWidth", 1.0);

    otherwise
        error("Escenario no soportado para dibujo de carretera: %s", scenario_name);
end

if ~dry_run
    xlim(ax, road_scene.xlim);
    ylim(ax, road_scene.ylim);
    axis(ax, "equal");
    grid(ax, "on");
    xlabel(ax, "x [m]");
    ylabel(ax, "y [m]");
end
end

function [left_x, left_y, right_x, right_y] = offset_polyline(cx, cy, offset)
dx = gradient(cx);
dy = gradient(cy);
nrm = sqrt(dx.^2 + dy.^2);
nrm(nrm < 1e-6) = 1.0;
nx = -dy ./ nrm;
ny = dx ./ nrm;

left_x = cx + offset * nx;
left_y = cy + offset * ny;
right_x = cx - offset * nx;
right_y = cy - offset * ny;
end
