function metrics = compute_vehicle_metrics(out, selected_scenario, control_case)
%COMPUTE_VEHICLE_METRICS Computes vehicle response metrics.

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

if N < 2
    error("The logged time vector has less than 2 samples.");
end

%% Read and normalize logged signals

x      = normalize_logged_signal(out.logs_x.Data, N);
y      = normalize_logged_signal(out.logs_y.Data, N);
y_ref  = normalize_logged_signal(out.logs_y_ref.Data, N);

psi    = normalize_logged_signal(out.logs_psi.Data, N);
Vx     = normalize_logged_signal(out.logs_Vx.Data, N);
Vy     = normalize_logged_signal(out.logs_Vy.Data, N);

beta   = normalize_logged_signal(out.logs_beta.Data, N);
r      = normalize_logged_signal(out.logs_r.Data, N);
ay     = normalize_logged_signal(out.logs_ay.Data, N);
Mz_cmd = normalize_logged_signal(out.logs_Mz_cmd.Data, N);

T_FL   = normalize_logged_signal(out.logs_T_FL.Data, N);
T_FR   = normalize_logged_signal(out.logs_T_FR.Data, N);
T_RL   = normalize_logged_signal(out.logs_T_RL.Data, N);
T_RR   = normalize_logged_signal(out.logs_T_RR.Data, N);

%% Tracking error

y_error = y_ref - y;

%% Torque values

torque_matrix = [T_FL, T_FR, T_RL, T_RR];

total_wheel_torque = T_FL + T_FR + T_RL + T_RR;

left_torque = T_FL + T_RL;
right_torque = T_FR + T_RR;
torque_difference_right_left = right_torque - left_torque;

%% Metrics table

metrics = table;

metrics.scenario = string(selected_scenario);
metrics.control_case = control_case;
metrics.control_case_name = control_case_name;

metrics.duration_s = t(end) - t(1);

%% Trajectory metrics

metrics.final_x_m = x(end);
metrics.final_y_m = y(end);
metrics.final_psi_deg = rad2deg(psi(end));

metrics.max_abs_y_error_m = max(abs(y_error));
metrics.rms_y_error_m = sqrt(mean(y_error.^2));

%% Velocity metrics

metrics.mean_Vx_m_s = mean(Vx);
metrics.max_abs_Vy_m_s = max(abs(Vy));

%% Stability metrics

metrics.max_abs_beta_deg = max(abs(rad2deg(beta)));
metrics.max_abs_r_rad_s = max(abs(r));
metrics.max_abs_ay_m_s2 = max(abs(ay));

%% Control effort metrics

metrics.max_abs_Mz_cmd_Nm = max(abs(Mz_cmd));
metrics.control_effort_Mz_Nm_s = trapz(t, abs(Mz_cmd));

%% Wheel torque metrics

metrics.mean_total_wheel_torque_Nm = mean(total_wheel_torque);
metrics.max_abs_wheel_torque_Nm = max(abs(torque_matrix), [], "all");

metrics.max_abs_T_FL_Nm = max(abs(T_FL));
metrics.max_abs_T_FR_Nm = max(abs(T_FR));
metrics.max_abs_T_RL_Nm = max(abs(T_RL));
metrics.max_abs_T_RR_Nm = max(abs(T_RR));

metrics.max_abs_torque_difference_RL_Nm = max(abs(torque_difference_right_left));

%% Time with beta over safety threshold

beta_limit_rad = deg2rad(3);
over_limit = abs(beta) > beta_limit_rad;

dt = mean(diff(t));
metrics.time_beta_over_3deg_s = sum(over_limit) * dt;

end


function signal = normalize_logged_signal(raw_data, N)
%NORMALIZE_LOGGED_SIGNAL Converts logged Simulink data into a column vector.
% If the signal is scalar, it is expanded to match the simulation time vector.

signal = squeeze(raw_data);
signal = signal(:);

if isempty(signal)
    signal = zeros(N, 1);

elseif length(signal) == 1
    signal = signal * ones(N, 1);

elseif length(signal) < N
    last_value = signal(end);
    signal = [signal; last_value * ones(N - length(signal), 1)];

elseif length(signal) > N
    signal = signal(1:N);
end

end
