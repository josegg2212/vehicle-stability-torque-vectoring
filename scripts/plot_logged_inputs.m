%% Plot logged scenario input signals
% This script plots the signals saved from Simulink in the variable "out".

if ~exist("out", "var")
    error("The variable 'out' does not exist. Run the Simulink model first.");
end

if ~exist("selected_scenario", "var")
    selected_scenario = "unknown_scenario";
end

%% Create figure

fig = figure("Name", "Scenario input signals", "Visible", "on");

subplot(4,1,1)
[t_delta, delta_ff] = get_logged_data(out, "logs_delta_ff", "logs_delta");
plot(t_delta, rad2deg(delta_ff), "LineWidth", 1.5)
hold on
try
    plot(out.logs_delta_cmd.Time, rad2deg(out.logs_delta_cmd.Data), "--", "LineWidth", 1.2)
    legend("\delta_{ff}", "\delta_{cmd}", "Interpreter", "none", "Location", "best");
catch
end
grid on
ylabel("\delta [deg]")
title("Scenario input signals - " + selected_scenario, "Interpreter", "none")

subplot(4,1,2)
plot(out.logs_mu.Time, out.logs_mu.Data, "LineWidth", 1.5)
grid on
ylabel("\mu [-]")

subplot(4,1,3)
plot(out.logs_T_driver_total.Time, out.logs_T_driver_total.Data, "LineWidth", 1.5)
grid on
ylabel("T_{driver,total} [N·m]")

subplot(4,1,4)
plot(out.logs_y_ref.Time, out.logs_y_ref.Data, "LineWidth", 1.5)
grid on
ylabel("y_{ref} [m]")
xlabel("Time [s]")

%% Save figure

if ~exist("results", "dir")
    mkdir("results");
end

results_folder = fullfile("results", "input_checks");

if ~exist(results_folder, "dir")
    mkdir(results_folder);
end

file_name_png = fullfile(results_folder, char(selected_scenario + "_input_signals.png"));
file_name_fig = fullfile(results_folder, char(selected_scenario + "_input_signals.fig"));

exportgraphics(fig, file_name_png, "Resolution", 200);
savefig(fig, file_name_fig);

disp("Input signal plots saved:");
disp(" - " + string(file_name_png));
disp(" - " + string(file_name_fig));


function [t, data] = get_logged_data(out, preferred_signal, fallback_signal)
try
    sig = out.get(preferred_signal);
catch
    sig = out.get(fallback_signal);
end
t = sig.Time;
data = sig.Data;
end
