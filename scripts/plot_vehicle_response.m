function plot_vehicle_response(out, selected_scenario, control_case)
%PLOT_VEHICLE_RESPONSE Plots vehicle response signals for full_system runs.

if nargin < 3
    control_case = 0;
end

switch control_case
    case 0
        control_case_name = "without_control";
    case 1
        control_case_name = "stability_control";
    case 2
        control_case_name = "torque_vectoring";
    otherwise
        control_case_name = "unknown_case";
end

%% Time vector
t = out.logs_x.Time(:);
N = length(t);

%% Read signals (robust to scalar logs and missing channels)
x = get_logged_signal(out, "logs_x", N);
y = get_logged_signal(out, "logs_y", N);
y_ref = get_logged_signal(out, "logs_y_ref", N);

Vx = get_logged_signal(out, "logs_Vx", N);
Vy = get_logged_signal(out, "logs_Vy", N);
psi = get_logged_signal(out, "logs_psi", N); %#ok<NASGU>

beta = get_logged_signal(out, "logs_beta", N);
r = get_logged_signal(out, "logs_r", N);
ay = get_logged_signal(out, "logs_ay", N);

delta = get_logged_signal(out, "logs_delta", N); %#ok<NASGU>
mu = get_logged_signal(out, "logs_mu", N); %#ok<NASGU>
T_driver_total = get_logged_signal(out, "logs_T_driver_total", N);

T_FL = get_logged_signal(out, "logs_T_FL", N);
T_FR = get_logged_signal(out, "logs_T_FR", N);
T_RL = get_logged_signal(out, "logs_T_RL", N);
T_RR = get_logged_signal(out, "logs_T_RR", N);
T_left_total = get_logged_signal(out, "logs_T_left_total", N);
T_right_total = get_logged_signal(out, "logs_T_right_total", N);
delta_T_lr = get_logged_signal(out, "logs_delta_T_lr", N);

Mz_cmd = get_logged_signal(out, "logs_Mz_cmd", N);
Mz_applied = get_logged_signal(out, "logs_Mz_applied", N);

%% Create figure
fig = figure("Name", "Vehicle response - " + selected_scenario);

subplot(5,2,1)
plot(x, y, "LineWidth", 1.5)
grid on
xlabel("x [m]")
ylabel("y [m]")
title("Trajectory x-y")

subplot(5,2,2)
plot(t, y_ref, "--", "LineWidth", 1.5)
hold on
plot(t, y, "LineWidth", 1.5)
grid on
xlabel("Time [s]")
ylabel("y [m]")
title("Lateral position")
legend("y_ref", "y", "Location", "best")

subplot(5,2,3)
plot(t, rad2deg(beta), "LineWidth", 1.5)
grid on
xlabel("Time [s]")
ylabel("beta [deg]")
title("Sideslip angle")

subplot(5,2,4)
plot(t, r, "LineWidth", 1.5)
grid on
xlabel("Time [s]")
ylabel("r [rad/s]")
title("Yaw rate")

subplot(5,2,5)
plot(t, ay, "LineWidth", 1.5)
grid on
xlabel("Time [s]")
ylabel("a_y [m/s^2]")
title("Lateral acceleration")

subplot(5,2,6)
plot(t, Mz_cmd, "LineWidth", 1.5)
hold on
plot(t, Mz_applied, "--", "LineWidth", 1.5)
grid on
xlabel("Time [s]")
ylabel("M_z [N*m]")
title("Yaw moment command vs applied")
legend("M_z,cmd", "M_z,applied", "Location", "best")

subplot(5,2,7)
plot(t, Vx, "LineWidth", 1.5)
hold on
plot(t, Vy, "LineWidth", 1.5)
grid on
xlabel("Time [s]")
ylabel("Velocity [m/s]")
title("Vehicle velocities")
legend("V_x", "V_y", "Location", "best")

subplot(5,2,8)
plot(t, T_FL, "LineWidth", 1.5)
hold on
plot(t, T_FR, "LineWidth", 1.5)
plot(t, T_RL, "LineWidth", 1.5)
plot(t, T_RR, "LineWidth", 1.5)
grid on
xlabel("Time [s]")
ylabel("Torque [N*m]")
title("Wheel torques")
legend("T_FL", "T_FR", "T_RL", "T_RR", "Location", "best")

subplot(5,2,9)
yyaxis left
plot(t, T_driver_total, "LineWidth", 1.5)
ylabel("T_driver,total [N*m]")
yyaxis right
plot(t, mu, "--", "LineWidth", 1.5)
grid on
xlabel("Time [s]")
ylabel("mu [-]")
title("Driver total torque and road friction")
legend("T_driver,total", "mu", "Location", "best")

subplot(5,2,10)
plot(t, T_left_total, "LineWidth", 1.5)
hold on
plot(t, T_right_total, "LineWidth", 1.5)
plot(t, delta_T_lr, "--", "LineWidth", 1.5)
grid on
xlabel("Time [s]")
ylabel("Torque [N*m]")
title("Left/right total torque and delta")
legend("T_left_total", "T_right_total", "delta_T_lr", "Location", "best")

sgtitle("Vehicle response - " + selected_scenario + " - " + control_case_name, ...
    "Interpreter", "none")

%% Save figure
config = project_config();
results_folder = config.vehicle_plots_folder;

if ~exist(results_folder, "dir")
    mkdir(results_folder);
end

file_name_png = fullfile(results_folder, ...
    char(selected_scenario + "_" + control_case_name + "_vehicle_response.png"));

file_name_fig = fullfile(results_folder, ...
    char(selected_scenario + "_" + control_case_name + "_vehicle_response.fig"));

exportgraphics(fig, file_name_png, "Resolution", 200);
savefig(fig, file_name_fig);

disp("Vehicle response plot saved:");
disp(" - " + string(file_name_png));
disp(" - " + string(file_name_fig));

end


function signal = get_logged_signal(out, signal_name, N)
%GET_LOGGED_SIGNAL Returns a column vector with length N.

try
    sig = out.get(char(signal_name));
    signal = normalize_logged_signal(sig.Data, N);
catch
    signal = zeros(N, 1);
end

end


function tf = has_log(out, signal_name)
%HAS_LOG True when a logged signal is available in SimulationOutput.

try
    out.get(char(signal_name));
    tf = true;
catch
    tf = false;
end

end


function signal = normalize_logged_signal(raw_data, N)
%NORMALIZE_LOGGED_SIGNAL Converts Simulink data into a column vector length N.

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
