function metrics = compute_input_metrics(out, selected_scenario, control_case)
%COMPUTE_INPUT_METRICS Computes basic metrics from scenario input signals.

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

%% Read logged signals

delta_ff_deg = rad2deg(get_logged_signal(out, "logs_delta_ff", []));
delta_cmd_deg = rad2deg(get_logged_signal(out, "logs_delta_cmd", []));
mu = out.logs_mu.Data;
T_driver_total = out.logs_T_driver_total.Data;
y_ref = out.logs_y_ref.Data;

t = get_log_time(out, "logs_delta_cmd", "logs_delta_ff");

%% Compute metrics

metrics = table;

metrics.scenario = string(selected_scenario);
metrics.control_case = control_case;
metrics.control_case_name = control_case_name;

metrics.duration_s = t(end) - t(1);

metrics.max_abs_delta_ff_deg = max(abs(delta_ff_deg));
metrics.max_abs_delta_cmd_deg = max(abs(delta_cmd_deg));
metrics.min_mu = min(mu);
metrics.mean_T_driver_total_Nm = mean(T_driver_total);

metrics.max_y_ref_m = max(y_ref);
metrics.min_y_ref_m = min(y_ref);
metrics.max_abs_y_ref_m = max(abs(y_ref));

end


function data = get_logged_signal(out, signal_name, fallback)
if nargin < 3
    fallback = [];
end
try
    data = out.get(signal_name).Data;
catch
    data = fallback;
end
end


function t = get_log_time(out, primary_name, secondary_name)
try
    t = out.get(primary_name).Time;
catch
    t = out.get(secondary_name).Time;
end
end
