%% Load full-system scenario inputs
% If selected_scenario exists in workspace, it is used.
% Otherwise, double_lane_change is loaded by default.

if exist("selected_scenario", "var")
    scenario_name = selected_scenario;
else
    scenario_name = "double_lane_change";
end

%% Load scenario data
scenario = scenario_library(scenario_name);

%% Time vector
Tend = scenario.Tend;
Ts = scenario.Ts;
t = (0:Ts:Tend)';

%% Steering angle delta(t)
delta_deg = interp1( ...
    scenario.t_delta, ...
    scenario.delta_deg, ...
    t, ...
    "previous" ...
);

delta_rad = deg2rad(delta_deg);

%% Road friction coefficient mu(t)
mu_values = interp1( ...
    scenario.t_mu, ...
    scenario.mu, ...
    t, ...
    "previous" ...
);

%% Total driver torque demand
T_driver_total_values = scenario.T_driver_total * ones(size(t));

%% Lateral reference y_ref(t)
y_ref_values = interp1( ...
    scenario.t_y_ref, ...
    scenario.y_ref, ...
    t, ...
    "linear" ...
);

%% Create timeseries for Simulink
delta_ts = timeseries(delta_rad, t);
mu_ts = timeseries(mu_values, t);
T_driver_total_ts = timeseries(T_driver_total_values, t);
y_ref_ts = timeseries(y_ref_values, t);

%% Variables for Simulink
Vx0 = scenario.Vx0;

%% Send variables to base workspace
assignin("base", "scenario", scenario);
assignin("base", "scenario_name", scenario_name);
assignin("base", "delta_ts", delta_ts);
assignin("base", "mu_ts", mu_ts);
assignin("base", "T_driver_total_ts", T_driver_total_ts);
assignin("base", "y_ref_ts", y_ref_ts);
assignin("base", "Tend", Tend);
assignin("base", "Ts", Ts);
assignin("base", "Vx0", Vx0);

%% Confirmation message
disp("Scenario loaded correctly:");
disp("Scenario name: " + scenario.name);
disp(" - delta_ts");
disp(" - mu_ts");
disp(" - T_driver_total_ts");
disp(" - Tend");
disp(" - Ts");
disp(" - Vx0");
disp(" - y_ref_ts");
