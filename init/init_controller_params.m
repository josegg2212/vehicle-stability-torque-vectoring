% init_controller_params.m
% Stability controller parameters

% Axle mass split
mf = m * b / L;
mr = m * a / L;

% Understeer gradient
Kv = mf / (2 * Caf) - mr / (2 * Car);

% Yaw-rate reference gain from steering input
% r_ref = G_rref * delta
G_rref = Vx / (L + Kv * Vx^2);

% PI gains for yaw-rate loop
Kp_r = 9000;
Ki_r = 15000;

% PI gains for sideslip loop
Kp_beta = 2.4e5;
Ki_beta = 3.6e5;

% Sideslip reference
beta_ref = 0;   % rad

% Override thresholds
beta_on_deg  = 0.8;
beta_off_deg = 0.2;
beta_on_rad  = deg2rad(beta_on_deg);
beta_off_rad = deg2rad(beta_off_deg);

% Corrective yaw moment saturation
Mz_max = 2.0e4;     % N*m
Mz_min = -2.0e4;    % N*m

% Testbench mode selector
% 0 -> without control
% 1 -> yaw controller with fixed reference
% 2 -> yaw controller with computed reference
% 3 -> override
control_mode = 0;

% Optional fixed yaw-rate reference for quick checks
r_ref_fixed = 0.7;  % rad/s

disp("init_controller_params.m loaded.");
