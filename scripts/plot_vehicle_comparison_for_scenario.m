function plot_vehicle_comparison_for_scenario(selected_scenario)
%PLOT_VEHICLE_COMPARISON_FOR_SCENARIO Runs one scenario in all control cases
% and plots comparison figures.
%
% This works now with the Vehicle Stub.
% Later, it will be used with the real vehicle model.

%% Project configuration

config = project_config();
model_name = config.model_name;
%% Control cases

control_case_list = [0 1 2];
control_case_names = [
    "without_control"
    "stability_control"
    "torque_vectoring"
];

%% Storage

results = struct();

%% Run cases

for j = 1:numel(control_case_list)

    control_case = control_case_list(j);
    control_case_name = control_case_names(j);

    disp("Running comparison case:");
    disp("Scenario: " + selected_scenario);
    disp("Control case: " + control_case_name);

    %% Load scenario
    init_scenario_test;

    %% Send control case to workspace
    assignin("base", "control_case", control_case);

    %% Run model
    out = sim(model_name, "StopTime", "Tend");

    %% Store output
    results(j).control_case = control_case;
    results(j).control_case_name = control_case_name;
    results(j).out = out;

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

    x = vectorize_signal(out.logs_x.Data, N);
    y = vectorize_signal(out.logs_y.Data, N);

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

y_ref = vectorize_signal(out0.logs_y_ref.Data, N);

plot(t, y_ref, "k--", "LineWidth", 1.5);

for j = 1:numel(results)
    out = results(j).out;
    y = vectorize_signal(out.logs_y.Data, N);
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

    beta = vectorize_signal(out.logs_beta.Data, N);

    plot(t, rad2deg(beta), "LineWidth", 1.5);
end

xlabel("Time [s]");
ylabel("\beta [deg]");
title("Sideslip angle");
legend(control_case_names, "Interpreter", "none", "Location", "best");

%% 4. yaw rate

subplot(4,2,4)
hold on; grid on;

for j = 1:numel(results)
    out = results(j).out;
    t = out.logs_x.Time(:);
    N = length(t);

    r = vectorize_signal(out.logs_r.Data, N);

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

    ay = vectorize_signal(out.logs_ay.Data, N);

    plot(t, ay, "LineWidth", 1.5);
end

xlabel("Time [s]");
ylabel("a_y [m/s^2]");
title("Lateral acceleration");
legend(control_case_names, "Interpreter", "none", "Location", "best");

%% 6. corrective yaw moment

subplot(4,2,6)
hold on; grid on;

for j = 1:numel(results)
    out = results(j).out;
    t = out.logs_x.Time(:);
    N = length(t);

    Mz_cmd = vectorize_signal(out.logs_Mz_cmd.Data, N);

    plot(t, Mz_cmd, "LineWidth", 1.5);
end

xlabel("Time [s]");
ylabel("M_z [N·m]");
title("Corrective yaw moment");
legend(control_case_names, "Interpreter", "none", "Location", "best");

%% 7. vehicle velocities

subplot(4,2,7)
hold on; grid on;

for j = 1:numel(results)
    out = results(j).out;
    t = out.logs_x.Time(:);
    N = length(t);

    Vx = vectorize_signal(out.logs_Vx.Data, N);
    Vy = vectorize_signal(out.logs_Vy.Data, N);

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

    T_FL = vectorize_signal(out.logs_T_FL.Data, N);
    T_FR = vectorize_signal(out.logs_T_FR.Data, N);
    T_RL = vectorize_signal(out.logs_T_RL.Data, N);
    T_RR = vectorize_signal(out.logs_T_RR.Data, N);

    plot(t, T_FL, "LineWidth", 1.5);
    plot(t, T_FR, "LineWidth", 1.5);
    plot(t, T_RL, "LineWidth", 1.5);
    plot(t, T_RR, "LineWidth", 1.5);
end

xlabel("Time [s]");
ylabel("Torque [N·m]");
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

results_folder = fullfile("results", "vehicle_stub", "comparisons");

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


function signal = vectorize_signal(raw_data, N)
%VECTORIZE_SIGNAL Converts Simulink logged data to a column vector.

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