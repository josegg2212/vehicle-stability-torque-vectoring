% demo_2D_from_data.m
% 2D animation from exported data with fixed road geometry per scenario.

clc;
close all;

%% Paths and parameters
script_dir = fileparts(mfilename("fullpath"));
project_root = fileparts(script_dir);
addpath(fullfile(project_root, "init"));
addpath(fullfile(project_root, "scripts"));

run(fullfile(project_root, "init", "init_demo_params.m"));

%% Load demo data
input_file = fullfile(project_root, "results", "runs", "demo_2D_input_data.mat");
if ~exist(input_file, "file")
    error("Input file not found: %s", input_file);
end
S = load(input_file);

%% Required vectors
t = S.t(:)';
x = S.x(:)';
y = S.y(:)';
psi = S.psi(:)';
Vx = S.Vx(:)';
T_driver_total = S.T_driver_total(:)';
Mz_cmd = S.Mz_cmd(:)';
Mz_applied = S.Mz_applied(:)';
T_FL = S.T_FL(:)';
T_FR = S.T_FR(:)';
T_RL = S.T_RL(:)';
T_RR = S.T_RR(:)';

N = numel(t);
assert_same_length(N, x, y, psi, Vx, T_driver_total, Mz_cmd, Mz_applied, T_FL, T_FR, T_RL, T_RR);

y_ref = get_or_default(S, "y_ref", zeros(1, N));
delta_ff = get_or_default(S, "delta_ff", zeros(1, N));
delta_cmd = get_or_default(S, "delta_cmd", delta_ff);
beta = get_or_default(S, "beta", NaN(1, N));
r = get_or_default(S, "r", NaN(1, N));
ay = get_or_default(S, "ay", NaN(1, N));

if isfield(S, "selected_scenario")
    scenario_name = string(S.selected_scenario);
else
    scenario_name = "double_lane_change";
end

if isfield(S, "control_case")
    control_case_name = control_case_to_name(S.control_case);
else
    control_case_name = "unknown_control";
end

scenario_title = pretty_scenario_name(scenario_name);
control_title = pretty_control_name(control_case_name);

%% Run summary metrics (for presentation/quick interpretation)
e_y = y_ref - y;
rms_e_y = rms(e_y);
max_abs_e_y = max(abs(e_y));
max_abs_beta_deg = safe_max_abs(rad2deg(beta));
max_abs_r = safe_max_abs(r);
max_abs_ay = safe_max_abs(ay);

%% Recompute lateral torque split from wheel torques (single source of truth)
T_left_total = T_FL + T_RL;
T_right_total = T_FR + T_RR;
delta_T_lr = T_right_total - T_left_total;

%% Fixed road + fixed reference from scenario definition
scenario = scenario_library(scenario_name);
if ~exist("use_presentation_axes", "var")
    use_presentation_axes = false;
end
if ~exist("presentation_xlim_straight", "var")
    presentation_xlim_straight = [-10, 320];
end
if ~exist("presentation_ylim_straight", "var")
    presentation_ylim_straight = [-14, 14];
end
if ~exist("presentation_xlim_corner", "var")
    presentation_xlim_corner = [-10, 350];
end
if ~exist("presentation_ylim_corner", "var")
    presentation_ylim_corner = [-15, 80];
end

axis_cfg = build_axis_config( ...
    use_presentation_axes, ...
    presentation_xlim_straight, presentation_ylim_straight, ...
    presentation_xlim_corner, presentation_ylim_corner);
road_scene = build_road_scene(scenario, road_width, axis_cfg);
[x_ref_plot, y_ref_plot] = build_reference_path(scenario, t, y_ref);

%% Static trajectory figure
figures_folder = fullfile(project_root, "results", "figures");
if ~exist(figures_folder, "dir")
    mkdir(figures_folder);
end

fig_static = figure("Color", "w");
ax_static = axes("Parent", fig_static);
draw_road_scene(ax_static, road_scene);
hold(ax_static, "on");
ref_static_h = plot(ax_static, x_ref_plot, y_ref_plot, "m--", "LineWidth", 1.4, "DisplayName", "Reference");
veh_static_h = plot(ax_static, x, y, "b", "LineWidth", 1.6, "DisplayName", "Vehicle path");
legend(ax_static, [ref_static_h, veh_static_h], ...
    "Location", "northwest", "Interpreter", "none", "AutoUpdate", "off");
title(ax_static, "Trajectory - " + scenario_title + " | " + control_title, "Interpreter", "none");
saveas(fig_static, fullfile(figures_folder, "demo_2D_from_data_trajectory.png"));

%% Optional video export
video_writer = [];
if export_video
    video_folder = fullfile(project_root, "results", "demo_2D", "videos");
    if ~exist(video_folder, "dir")
        mkdir(video_folder);
    end
    video_file = fullfile(video_folder, ...
        "demo2D_" + scenario_name + "_" + control_case_name + ".mp4");
    video_writer = VideoWriter(video_file, "MPEG-4");
    video_writer.FrameRate = video_fps;
    open(video_writer);
end

%% Main figure
fig = figure("Name", "Demo 2D", "Color", "w", "Position", [60 40 1500 820]);
axRoad = axes("Parent", fig, "Position", [0.05 0.12 0.63 0.78]);
axInfo = axes("Parent", fig, "Position", [0.72 0.55 0.25 0.35]); axis(axInfo, "off");
axSide = axes("Parent", fig, "Position", [0.74 0.34 0.22 0.14]);
axWheel = axes("Parent", fig, "Position", [0.74 0.12 0.22 0.16]);

draw_road_scene(axRoad, road_scene);
hold(axRoad, "on");
ref_h = plot(axRoad, x_ref_plot, y_ref_plot, "m--", "LineWidth", 1.4, "DisplayName", "Reference");
traj_h = plot(axRoad, x, y, "Color", [0.68 0.68 0.68], "LineWidth", 1.0, "DisplayName", "Vehicle path (full)");
run_h = plot(axRoad, x(1), y(1), "b", "LineWidth", 2.2, "DisplayName", "Vehicle path (run)");
car_h = fill(axRoad, NaN, NaN, [0.10 0.30 0.90], "EdgeColor", "k", "LineWidth", 1.4);
front_h = plot(axRoad, NaN, NaN, "w", "LineWidth", 2.4);
legend(axRoad, [ref_h traj_h run_h], ...
    "Location", "northwest", "Interpreter", "none", "AutoUpdate", "off");

annotation(fig, "textbox", [0.72 0.91 0.26 0.06], ...
    "String", "TORQUE DISTRIBUTION PANEL", "FitBoxToText", "off", ...
    "EdgeColor", "none", "FontWeight", "bold", "FontSize", 16, ...
    "Interpreter", "none", "HorizontalAlignment", "center");

status_box = annotation(fig, "textbox", [0.72 0.02 0.26 0.07], ...
    "String", "", "FitBoxToText", "off", "EdgeColor", [0.20 0.20 0.20], ...
    "LineWidth", 1.2, "BackgroundColor", [0.96 0.96 0.96], "FontSize", 13, ...
    "FontWeight", "bold", "Interpreter", "none", "HorizontalAlignment", "center");

summary_text = sprintf( ...
    "Summary: RMS e_y=%.2f m | Max |e_y|=%.2f m | Max |beta|=%.2f deg | Max |r|=%.2f rad/s | Max |a_y|=%.2f m/s^2", ...
    rms_e_y, max_abs_e_y, max_abs_beta_deg, max_abs_r, max_abs_ay);
annotation(fig, "textbox", [0.70 0.50 0.29 0.05], ...
    "String", summary_text, ...
    "FitBoxToText", "off", ...
    "EdgeColor", [0.20 0.20 0.20], ...
    "LineWidth", 1.0, ...
    "BackgroundColor", [0.96 0.96 0.96], ...
    "FontSize", 9.5, ...
    "FontWeight", "bold", ...
    "Interpreter", "none", ...
    "HorizontalAlignment", "center");

% Paso de animación
target_frames = 70;   % Más bajo = más rápido, más alto = más suave
frame_step = max(1, ceil(N / target_frames));
max_side_torque = 1.2 * max(1, max(abs([T_left_total T_right_total])));
max_wheel_torque = 1.25 * max(1, max(abs([T_FL T_FR T_RL T_RR])));
k_end = get_animation_end_index(x, road_scene);

for k = 1:frame_step:k_end
    [car_color, status_text, status_color] = classify_torque_state(delta_T_lr(k));

    if ~isgraphics(car_h) || ~isgraphics(run_h) || ~isgraphics(front_h) || ~isgraphics(axRoad)
        warning("Demo 2D animation stopped early because figure handles are no longer valid.");
        break;
    end

    car_poly = get_car_polygon(x(k), y(k), psi(k), car_length, car_width);
    try
        set(car_h, "XData", car_poly(1, :), "YData", car_poly(2, :), "FaceColor", car_color);
        set(run_h, "XData", x(1:k), "YData", y(1:k));
    catch
        warning("Demo 2D animation stopped early while updating vehicle graphics.");
        break;
    end

    front_x = x(k) + (car_length/2) * cos(psi(k));
    front_y = y(k) + (car_length/2) * sin(psi(k));
    set(front_h, "XData", [x(k), front_x], "YData", [y(k), front_y]);

    title(axRoad, ...
        "Demo 2D - " + scenario_title + " | " + control_title, ...
        "FontSize", 14, "FontWeight", "bold", "Interpreter", "none");

    cla(axInfo);
    axis(axInfo, [0 1 0 1]);
    axis(axInfo, "off");
    hold(axInfo, "on");
    rectangle(axInfo, "Position", [0.01 0.01 0.98 0.98], ...
        "FaceColor", [0.97 0.97 0.97], "EdgeColor", [0.25 0.25 0.25], "LineWidth", 1.5);

    text(axInfo, 0.05, 0.93, "INSTANT VALUES", ...
        "FontSize", 13, "FontWeight", "bold", "Interpreter", "none");
    text(axInfo, 0.05, 0.88, "Scenario: " + scenario_name, ...
        "FontSize", 9.5, "FontName", "Consolas", "Interpreter", "none");
    text(axInfo, 0.05, 0.84, "Control: " + control_case_name, ...
        "FontSize", 9.5, "FontName", "Consolas", "Interpreter", "none");

    labels = { ...
        "t [s]", "x [m]", "y [m]", "y_ref [m]", ...
        "delta_ff [deg]", "delta_cmd [deg]", ...
        "Vx [m/s]", "beta [rad]", "r [rad/s]", "ay [m/s^2]", ...
        "T_driver_total [N*m]", "Mz_cmd [N*m]", "Mz_applied [N*m]", ...
        "T_FL [N*m]", "T_FR [N*m]", "T_RL [N*m]", "T_RR [N*m]", ...
        "T_left_total [N*m]", "T_right_total [N*m]", "delta_T_lr [N*m]"};

    values = { ...
        sprintf("%.2f", t(k)), sprintf("%.2f", x(k)), sprintf("%.2f", y(k)), sprintf("%.2f", y_ref(k)), ...
        sprintf("%.2f", rad2deg(delta_ff(k))), sprintf("%.2f", rad2deg(delta_cmd(k))), ...
        sprintf("%.2f", Vx(k)), number_or_dash(beta(k), "%.3f"), number_or_dash(r(k), "%.3f"), number_or_dash(ay(k), "%.2f"), ...
        sprintf("%.0f", T_driver_total(k)), sprintf("%.0f", Mz_cmd(k)), sprintf("%.0f", Mz_applied(k)), ...
        sprintf("%.0f", T_FL(k)), sprintf("%.0f", T_FR(k)), sprintf("%.0f", T_RL(k)), sprintf("%.0f", T_RR(k)), ...
        sprintf("%.0f", T_left_total(k)), sprintf("%.0f", T_right_total(k)), sprintf("%.0f", delta_T_lr(k))};

    y0 = 0.79;
    dy = 0.038;
    for i = 1:numel(labels)
        y_text = y0 - (i-1) * dy;
        text(axInfo, 0.05, y_text, labels{i}, "FontSize", 9.2, ...
            "FontName", "Consolas", "FontWeight", "bold", ...
            "Interpreter", "none", "HorizontalAlignment", "left");
        text(axInfo, 0.95, y_text, values{i}, "FontSize", 9.2, ...
            "FontName", "Consolas", "Interpreter", "none", ...
            "HorizontalAlignment", "right", "Color", [0.00 0.20 0.55]);
    end

    cla(axSide);
    side_values = [T_left_total(k), T_right_total(k)];
    bh = barh(axSide, side_values, 0.55);
    bh.FaceColor = [0.12 0.47 0.71];
    xlim(axSide, [-max_side_torque max_side_torque]);
    yticks(axSide, [1 2]);
    yticklabels(axSide, {"Left", "Right"});
    xlabel(axSide, "Torque [N*m]");
    title(axSide, "Lateral split", "FontSize", 12, "FontWeight", "bold", "Interpreter", "none");
    grid(axSide, "on");
    hold(axSide, "on");
    plot(axSide, [0 0], [0.5 2.5], "k", "LineWidth", 1);

    cla(axWheel);
    wheel_values = [T_FL(k), T_FR(k), T_RL(k), T_RR(k)];
    bw = bar(axWheel, wheel_values, 0.6);
    bw.FaceColor = [0.12 0.47 0.71];
    ylim(axWheel, [-max_wheel_torque max_wheel_torque]);
    xticks(axWheel, 1:4);
    xticklabels(axWheel, {"FL", "FR", "RL", "RR"});
    ylabel(axWheel, "Torque [N*m]");
    title(axWheel, "Wheel torques", "FontSize", 12, "FontWeight", "bold", "Interpreter", "none");
    grid(axWheel, "on");
    hold(axWheel, "on");
    plot(axWheel, [0.5 4.5], [0 0], "k", "LineWidth", 1);

    set(status_box, "String", status_text, "BackgroundColor", status_color);
    drawnow limitrate;

    if ~isempty(video_writer)
        writeVideo(video_writer, getframe(fig));
    end
end

if ~isempty(video_writer)
    close(video_writer);
end

disp("Demo 2D completed.");


function out = get_or_default(S, name, fallback)
if isfield(S, name)
    out = reshape(S.(name), 1, []);
else
    out = fallback;
end
end


function assert_same_length(N, varargin)
for i = 1:numel(varargin)
    if numel(varargin{i}) ~= N
        error("All signals must have the same length as t.");
    end
end
end


function [x_ref, y_ref] = build_reference_path(scenario, t_run, y_ref_run)
if isfield(scenario, "x_ref") && isfield(scenario, "y_ref_path")
    x_ref = scenario.x_ref(:)';
    y_ref = scenario.y_ref_path(:)';
else
    x_ref = scenario.Vx0 * t_run(:)';
    y_ref = y_ref_run(:)';
end
end


function axis_cfg = build_axis_config(use_presentation_axes, xlim_straight, ylim_straight, xlim_corner, ylim_corner)
axis_cfg.use_presentation_axes = logical(use_presentation_axes);
axis_cfg.presentation_xlim_straight = xlim_straight;
axis_cfg.presentation_ylim_straight = ylim_straight;
axis_cfg.presentation_xlim_corner = xlim_corner;
axis_cfg.presentation_ylim_corner = ylim_corner;
end


function road_scene = build_road_scene(scenario, road_width, axis_cfg)
cx = scenario.road_x(:)';
cy = scenario.road_y(:)';
[left_x, left_y, right_x, right_y] = offset_polyline(cx, cy, road_width/2);

road_scene.center_x = cx;
road_scene.center_y = cy;
road_scene.left_x = left_x;
road_scene.left_y = left_y;
road_scene.right_x = right_x;
road_scene.right_y = right_y;

if string(scenario.name) == "aggressive_corner"
    if axis_cfg.use_presentation_axes
        road_scene.xlim = axis_cfg.presentation_xlim_corner;
        road_scene.ylim = axis_cfg.presentation_ylim_corner;
    else
        road_scene.xlim = [min([left_x right_x]) - 10, max([left_x right_x]) + 20];
        road_scene.ylim = [min([left_y right_y]) - 10, max([left_y right_y]) + 10];
    end
    road_scene.animation_x_end = min(max(cx), road_scene.xlim(2));
else
    x_start = min(cx);
    x_end = max(cx);
    if isfield(scenario, "low_mu_zone_x")
        x_end = max(x_end, scenario.low_mu_zone_x(2) + 40);
    end
    if axis_cfg.use_presentation_axes
        road_scene.xlim = axis_cfg.presentation_xlim_straight;
        road_scene.ylim = axis_cfg.presentation_ylim_straight;
    else
        road_scene.xlim = [x_start - 10, x_end + 10];
        road_scene.ylim = [-14, 14];
    end
    road_scene.animation_x_end = x_end;
end

if isfield(scenario, "low_mu_zone_x")
    road_scene.low_mu_zone_x = scenario.low_mu_zone_x;
    road_scene.low_mu_zone_value = scenario.low_mu_zone_value;
end
end


function draw_road_scene(ax, road_scene)
cla(ax);
hold(ax, "on");
fill(ax, [road_scene.left_x fliplr(road_scene.right_x)], ...
    [road_scene.left_y fliplr(road_scene.right_y)], ...
    [0.90 0.90 0.90], "EdgeColor", "none");
plot(ax, road_scene.left_x, road_scene.left_y, "k", "LineWidth", 1.2);
plot(ax, road_scene.right_x, road_scene.right_y, "k", "LineWidth", 1.2);
plot(ax, road_scene.center_x, road_scene.center_y, "k--", "LineWidth", 1.0);

if isfield(road_scene, "low_mu_zone_x")
    zx = road_scene.low_mu_zone_x;
    yb = [min(road_scene.right_y), max(road_scene.left_y)];
    patch(ax, [zx(1) zx(2) zx(2) zx(1)], [yb(1) yb(1) yb(2) yb(2)], ...
        [1.00 0.88 0.88], "FaceAlpha", 0.45, ...
        "EdgeColor", [0.75 0.15 0.15], "LineStyle", "--");
    txt = sprintf("Low mu zone, mu = %.2f", road_scene.low_mu_zone_value);
    text(ax, zx(1) + 1.0, yb(2) - 0.5, txt, ...
        "Color", [0.70 0.10 0.10], "FontWeight", "bold", ...
        "FontSize", 10, "Interpreter", "none");
end

xlim(ax, road_scene.xlim);
ylim(ax, road_scene.ylim);
axis(ax, "normal");
grid(ax, "on");
xlabel(ax, "x [m]");
ylabel(ax, "y [m]");
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


function [car_color, status_text, status_color] = classify_torque_state(delta_T_lr)
if delta_T_lr > 100
    car_color = [0.05 0.45 0.85];
    status_text = "More torque on right side";
    status_color = [0.88 0.95 1.00];
elseif delta_T_lr < -100
    car_color = [0.90 0.35 0.10];
    status_text = "More torque on left side";
    status_color = [1.00 0.92 0.86];
else
    car_color = [0.10 0.30 0.90];
    status_text = "Nearly balanced torque split";
    status_color = [0.92 0.97 0.92];
end
end


function out = number_or_dash(value, fmt)
if isnan(value)
    out = "-";
else
    out = sprintf(fmt, value);
end
end


function car_poly = get_car_polygon(xc, yc, psi, Lcar, Wcar)
local_corners = [ ...
     Lcar/2,  Wcar/2;
     Lcar/2, -Wcar/2;
    -Lcar/2, -Wcar/2;
    -Lcar/2,  Wcar/2;
     Lcar/2,  Wcar/2]';
R = [cos(psi), -sin(psi); sin(psi), cos(psi)];
global_corners = R * local_corners;
global_corners(1, :) = global_corners(1, :) + xc;
global_corners(2, :) = global_corners(2, :) + yc;
car_poly = global_corners;
end


function label = pretty_scenario_name(name)
switch string(name)
    case "double_lane_change"
        label = "Double lane change";
    case "aggressive_corner"
        label = "Aggressive corner";
    case "low_mu_lane_change"
        label = "Low mu lane change";
    case "high_speed_low_mu_slalom"
        label = "High-speed low-mu slalom";
    otherwise
        label = "Unknown scenario";
end
end


function label = pretty_control_name(name)
switch string(name)
    case "without_control"
        label = "Without control";
    case "stability_control"
        label = "Stability control";
    case "torque_vectoring"
        label = "Torque vectoring";
    otherwise
        label = "Unknown control";
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


function out = safe_max_abs(v)
v = v(:);
v = v(~isnan(v));
if isempty(v)
    out = NaN;
else
    out = max(abs(v));
end
end


function k_end = get_animation_end_index(x, road_scene)
k_end = numel(x);
if ~isfield(road_scene, "animation_x_end")
    return;
end

idx = find(x <= road_scene.animation_x_end, 1, "last");
if ~isempty(idx) && idx > 20
    k_end = idx;
end
end
