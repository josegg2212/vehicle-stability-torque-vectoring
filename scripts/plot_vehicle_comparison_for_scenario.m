function plot_vehicle_comparison_for_scenario(selected_scenario)
%PLOT_VEHICLE_COMPARISON_FOR_SCENARIO Runs one scenario in all control cases
% and generates comparison figures.

%% Project configuration
config = project_config();
model_name = config.model_name;

% Ensure all init parameters are available in this function workspace.
run(fullfile(config.project_root, "init", "init_project_final.m"));

%% Control cases
control_case_list = [0 1 2];
control_case_names = [
    "without_control"
    "stability_control"
    "torque_vectoring"
];

%% Storage
results = struct();
yaw_sources = strings(numel(control_case_list), 1);

%% Run cases
for j = 1:numel(control_case_list)

    control_case = control_case_list(j);
    control_case_name = control_case_names(j);

    disp("Running comparison case:");
    disp("Scenario: " + selected_scenario);
    disp("Control case: " + control_case_name);

    %% Load scenario
    run(fullfile(config.project_root, "scripts", "init_full_system_scenario.m"));

    %% Send control case to workspace
    assignin("base", "control_case", control_case);

    %% Run model
    out = sim(model_name, "StopTime", "Tend");

    %% Store output
    results(j).control_case = control_case;
    results(j).control_case_name = control_case_name;
    results(j).out = out;
    yaw_sources(j) = preferred_yaw_signal_name(out);

end

%% Create comparison figure
fig = figure("Name", "Vehicle comparison - " + selected_scenario);

%% 1. Trajectory
subplot(4,2,1)
hold on; grid on;

for j = 1:numel(results)
    out = results(j).out;
    t = out.logs_x.Time(:);
    N = length(t);

    x = get_logged_signal(out, "logs_x", N);
    y = get_logged_signal(out, "logs_y", N);

    plot(x, y, "LineWidth", 1.5);
end

xlabel("x [m]");
ylabel("y [m]");
title("Trajectory x-y");
legend(control_case_names, "Interpreter", "none", "Location", "best");

%% 2. y_ref vs y
subplot(4,2,2)
hold on; grid on;

out0 = results(1).out;
t = out0.logs_x.Time(:);
N = length(t);

y_ref = get_logged_signal(out0, "logs_y_ref", N);
plot(t, y_ref, "k--", "LineWidth", 1.5);

for j = 1:numel(results)
    out = results(j).out;
    y = get_logged_signal(out, "logs_y", N);
    plot(t, y, "LineWidth", 1.5);
end

xlabel("Time [s]");
ylabel("y [m]");
title("Lateral position");
legend(["y_ref"; control_case_names(:)], "Interpreter", "none", "Location", "best");

%% 3. beta
subplot(4,2,3)
hold on; grid on;

for j = 1:numel(results)
    out = results(j).out;
    t = out.logs_x.Time(:);
    N = length(t);

    beta = get_logged_signal(out, "logs_beta", N);

    plot(t, rad2deg(beta), "LineWidth", 1.5);
end

xlabel("Time [s]");
ylabel("beta [deg]");
title("Sideslip angle");
legend(control_case_names, "Interpreter", "none", "Location", "best");

%% 4. yaw rate
subplot(4,2,4)
hold on; grid on;

for j = 1:numel(results)
    out = results(j).out;
    t = out.logs_x.Time(:);
    N = length(t);

    r = get_logged_signal(out, "logs_r", N);

    plot(t, r, "LineWidth", 1.5);
end

xlabel("Time [s]");
ylabel("r [rad/s]");
title("Yaw rate");
legend(control_case_names, "Interpreter", "none", "Location", "best");

%% 5. lateral acceleration
subplot(4,2,5)
hold on; grid on;

for j = 1:numel(results)
    out = results(j).out;
    t = out.logs_x.Time(:);
    N = length(t);

    ay = get_logged_signal(out, "logs_ay", N);

    plot(t, ay, "LineWidth", 1.5);
end

xlabel("Time [s]");
ylabel("a_y [m/s^2]");
title("Lateral acceleration");
legend(control_case_names, "Interpreter", "none", "Location", "best");

%% 6. yaw moment
subplot(4,2,6)
hold on; grid on;

for j = 1:numel(results)
    out = results(j).out;
    t = out.logs_x.Time(:);
    N = length(t);

    Mz = get_logged_signal(out, preferred_yaw_signal_name(out), N);
    plot(t, Mz, "LineWidth", 1.5);
end

xlabel("Time [s]");
ylabel("M_z [N*m]");

if all(yaw_sources == "logs_Mz_to_plant")
    title("Yaw moment applied to plant");
elseif all(yaw_sources == "logs_Mz_cmd")
    title("Requested yaw moment");
else
    title("Yaw moment (to plant preferred)");
end

legend(control_case_names, "Interpreter", "none", "Location", "best");

%% 7. vehicle velocities
subplot(4,2,7)
hold on; grid on;

for j = 1:numel(results)
    out = results(j).out;
    t = out.logs_x.Time(:);
    N = length(t);

    Vx = get_logged_signal(out, "logs_Vx", N);
    Vy = get_logged_signal(out, "logs_Vy", N);

    plot(t, Vx, "LineWidth", 1.5);
    plot(t, Vy, "--", "LineWidth", 1.5);
end

xlabel("Time [s]");
ylabel("Velocity [m/s]");
title("Vehicle velocities");
legend( ...
    "Vx without", "Vy without", ...
    "Vx stability", "Vy stability", ...
    "Vx TVC", "Vy TVC", ...
    "Interpreter", "none", ...
    "Location", "best" ...
);

%% 8. wheel torques
subplot(4,2,8)
hold on; grid on;

for j = 1:numel(results)
    out = results(j).out;
    t = out.logs_x.Time(:);
    N = length(t);

    T_FL = get_logged_signal(out, "logs_T_FL", N);
    T_FR = get_logged_signal(out, "logs_T_FR", N);
    T_RL = get_logged_signal(out, "logs_T_RL", N);
    T_RR = get_logged_signal(out, "logs_T_RR", N);

    plot(t, T_FL, "LineWidth", 1.5);
    plot(t, T_FR, "LineWidth", 1.5);
    plot(t, T_RL, "LineWidth", 1.5);
    plot(t, T_RR, "LineWidth", 1.5);
end

xlabel("Time [s]");
ylabel("Torque [N*m]");
title("Wheel torques");
legend( ...
    "FL without", "FR without", "RL without", "RR without", ...
    "FL stability", "FR stability", "RL stability", "RR stability", ...
    "FL TVC", "FR TVC", "RL TVC", "RR TVC", ...
    "Interpreter", "none", ...
    "Location", "best" ...
);

sgtitle("Vehicle comparison - " + selected_scenario, "Interpreter", "none");

%% Save figure
results_folder = config.vehicle_comparisons_folder;

if ~exist(results_folder, "dir")
    mkdir(results_folder);
end

file_name_png = fullfile(results_folder, char(selected_scenario + "_vehicle_comparison.png"));
file_name_fig = fullfile(results_folder, char(selected_scenario + "_vehicle_comparison.fig"));

exportgraphics(fig, file_name_png, "Resolution", 200);
savefig(fig, file_name_fig);

disp("Vehicle comparison plot saved:");
disp(" - " + string(file_name_png));
disp(" - " + string(file_name_fig));

end


function signal = get_logged_signal(out, signal_name, N)
%GET_LOGGED_SIGNAL Returns signal_name as a column vector of length N.

try
    sig = out.get(char(signal_name));
    signal = normalize_logged_signal(sig.Data, N);
catch
    signal = zeros(N, 1);
end

end


function signal_name = preferred_yaw_signal_name(out)
%PREFERRED_YAW_SIGNAL_NAME Chooses the best yaw-moment signal for plotting.

if has_log(out, "logs_Mz_to_plant")
    signal_name = "logs_Mz_to_plant";
elseif has_log(out, "logs_Mz_applied")
    signal_name = "logs_Mz_applied";
else
    signal_name = "logs_Mz_cmd";
end

end


function tf = has_log(out, signal_name)
%HAS_LOG True when a logged signal exists in SimulationOutput.

try
    out.get(char(signal_name));
    tf = true;
catch
    tf = false;
end

end


function signal = normalize_logged_signal(raw_data, N)
%NORMALIZE_LOGGED_SIGNAL Converts Simulink data to column vector length N.

signal = squeeze(raw_data);
signal = signal(:);

if isempty(signal)
    signal = zeros(N, 1);
elseif length(signal) == 1
    signal = signal * ones(N, 1);
elseif length(signal) < N
    signal = [signal; signal(end) * ones(N - length(signal), 1)];
elseif length(signal) > N
    signal = signal(1:N);
end

end
