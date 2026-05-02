function plot_vehicle_response(out, selected_scenario, control_case)
%PLOT_VEHICLE_RESPONSE Plots vehicle response signals.
%
% This works now with the Vehicle Stub and later with the real vehicle model.

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

%% Read signals

x      = expand_signal(out.logs_x.Data, N);
y      = expand_signal(out.logs_y.Data, N);
y_ref  = expand_signal(out.logs_y_ref.Data, N);

psi    = expand_signal(out.logs_psi.Data, N);
Vx     = expand_signal(out.logs_Vx.Data, N);
Vy     = expand_signal(out.logs_Vy.Data, N);

beta   = expand_signal(out.logs_beta.Data, N);
r      = expand_signal(out.logs_r.Data, N);
ay     = expand_signal(out.logs_ay.Data, N);
Mz_cmd = expand_signal(out.logs_Mz_cmd.Data, N);

T_FL   = expand_signal(out.logs_T_FL.Data, N);
T_FR   = expand_signal(out.logs_T_FR.Data, N);
T_RL   = expand_signal(out.logs_T_RL.Data, N);
T_RR   = expand_signal(out.logs_T_RR.Data, N);

%% Create figure

fig = figure("Name", "Vehicle response - " + selected_scenario);

subplot(4,2,1)
plot(x, y, "LineWidth", 1.5)
grid on
xlabel("x [m]")
ylabel("y [m]")
title("Trajectory x-y")

subplot(4,2,2)
plot(t, y_ref, "--", "LineWidth", 1.5)
hold on
plot(t, y, "LineWidth", 1.5)
grid on
xlabel("Time [s]")
ylabel("y [m]")
title("Lateral position")
legend("y_{ref}", "y", "Location", "best")

subplot(4,2,3)
plot(t, rad2deg(beta), "LineWidth", 1.5)
grid on
xlabel("Time [s]")
ylabel("\beta [deg]")
title("Sideslip angle")

subplot(4,2,4)
plot(t, r, "LineWidth", 1.5)
grid on
xlabel("Time [s]")
ylabel("r [rad/s]")
title("Yaw rate")

subplot(4,2,5)
plot(t, ay, "LineWidth", 1.5)
grid on
xlabel("Time [s]")
ylabel("a_y [m/s^2]")
title("Lateral acceleration")

subplot(4,2,6)
plot(t, Mz_cmd, "LineWidth", 1.5)
grid on
xlabel("Time [s]")
ylabel("M_z [N·m]")
title("Corrective yaw moment")

subplot(4,2,7)
plot(t, Vx, "LineWidth", 1.5)
hold on
plot(t, Vy, "LineWidth", 1.5)
grid on
xlabel("Time [s]")
ylabel("Velocity [m/s]")
title("Vehicle velocities")
legend("V_x", "V_y", "Location", "best")

subplot(4,2,8)
plot(t, T_FL, "LineWidth", 1.5)
hold on
plot(t, T_FR, "LineWidth", 1.5)
plot(t, T_RL, "LineWidth", 1.5)
plot(t, T_RR, "LineWidth", 1.5)
grid on
xlabel("Time [s]")
ylabel("Torque [N·m]")
title("Wheel torques")
legend("T_{FL}", "T_{FR}", "T_{RL}", "T_{RR}", "Location", "best")

sgtitle("Vehicle response - " + selected_scenario + " - " + control_case_name, ...
    "Interpreter", "none")

%% Save figure

results_folder = fullfile("results", "full_system", "plots");

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


function signal = expand_signal(raw_data, N)
%EXPAND_SIGNAL Makes scalar signals compatible with time vector length.

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