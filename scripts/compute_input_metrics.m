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

delta_deg = rad2deg(out.logs_delta.Data);
mu = out.logs_mu.Data;
T_driver_total = out.logs_T_driver_total.Data;
y_ref = out.logs_y_ref.Data;

t = out.logs_delta.Time;

%% Compute metrics

metrics = table;

metrics.scenario = string(selected_scenario);
metrics.control_case = control_case;
metrics.control_case_name = control_case_name;

metrics.duration_s = t(end) - t(1);

metrics.max_abs_delta_deg = max(abs(delta_deg));
metrics.min_mu = min(mu);
metrics.mean_T_driver_total_Nm = mean(T_driver_total);

metrics.max_y_ref_m = max(y_ref);
metrics.min_y_ref_m = min(y_ref);
metrics.max_abs_y_ref_m = max(abs(y_ref));

end