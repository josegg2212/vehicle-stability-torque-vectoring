% init_path_tracking_controller.m
% Simple lateral path-tracking parameters.
%
% Controller law implemented in Simulink:
%   delta_fb = K_y_active * (y_ref - y) - K_psi_active * psi
%   delta_cmd = sat(rate(delta_ff + delta_fb))

path_tracking_enabled = true;

% Gains for lane-change scenarios.
K_y_lane = 0.050;     % [rad/m]
K_psi_lane = 0.45;    % [rad/rad]

% Gains for aggressive-corner scenario.
K_y_corner = 0.040;   % [rad/m]
K_psi_corner = 0.16;  % [rad/rad]

% Gains for high-speed low-mu slalom scenario.
K_y_slalom = 0.050;
K_psi_slalom = 0.68;  % [rad/rad]

% Active gains are selected in init_full_system_scenario.m
K_y_active = K_y_lane;
K_psi_active = K_psi_lane;

% In without_control (control_case=0), reduce path-tracking authority.
path_tracking_case0_scale = 0.25;

% Clamp lateral error before gain.
e_y_limit_m = 5.0;

% Steering saturation
delta_max_deg = 25;
delta_max_rad = deg2rad(delta_max_deg);

% Optional steering rate limiter
delta_rate_up_deg_s = 140;
delta_rate_down_deg_s = -140;  % Rate Limiter expects <= 0
delta_rate_up_rad_s = deg2rad(delta_rate_up_deg_s);
delta_rate_down_rad_s = deg2rad(delta_rate_down_deg_s);
