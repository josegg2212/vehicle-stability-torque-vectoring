function report = check_required_logs(out)
%CHECK_REQUIRED_LOGS Checks that all required logged signals exist.
%
% This is useful before replacing the Vehicle Stub with the real vehicle model.

required_signals = [
    "logs_delta"
    "logs_mu"
    "logs_T_driver_total"
    "logs_y_ref"
    "logs_x"
    "logs_y"
    "logs_psi"
    "logs_Vx"
    "logs_Vy"
    "logs_beta"
    "logs_r"
    "logs_ay"
    "logs_Mz_cmd"
    "logs_T_FL"
    "logs_T_FR"
    "logs_T_RL"
    "logs_T_RR"
];

has_signal = false(numel(required_signals), 1);
num_samples = zeros(numel(required_signals), 1);
status = strings(numel(required_signals), 1);

for i = 1:numel(required_signals)

    signal_name = required_signals(i);

    try
        sig = out.get(char(signal_name));

        has_signal(i) = true;

        if isa(sig, "timeseries")
            num_samples(i) = numel(sig.Time);
            status(i) = "OK";
        else
            num_samples(i) = -1;
            status(i) = "EXISTS_BUT_NOT_TIMESERIES";
        end

    catch
        has_signal(i) = false;
        num_samples(i) = 0;
        status(i) = "MISSING";
    end

end

report = table(required_signals(:), has_signal, num_samples, status, ...
    'VariableNames', {'signal_name', 'has_signal', 'num_samples', 'status'});

disp(report);

if all(has_signal)
    disp("All required logged signals are available.");
else
    warning("Some required logged signals are missing.");
end

end