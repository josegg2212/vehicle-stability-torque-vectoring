% init_torque_allocator_params.m
% Torque allocator parameters

% Distribution of the corrective yaw moment between axles
theta_front = 0.40;     % Balanced front/rear yaw support with robust low-mu behavior

% Nominal longitudinal torque distribution
front_drive_ratio = 0.5;    % 50% of driver torque to front axle
rear_drive_ratio  = 0.5;    % 50% of driver torque to rear axle

% Torque limits per wheel
Tmax_wheel = 4000;      % Maximum motor torque per wheel [N*m]
% Negative torque represents braking/regenerative torque.
Tmin_wheel = -2000;     % Minimum wheel torque [N*m]

% Yaw moment saturation
Mz_max = 12000;         % Maximum corrective yaw moment [N*m]
Mz_min = -Mz_max;

% Small numerical protection
tf = 1.65;
tf1 = tf;  % Backward compatibility
tr = 1.65;
rw = 0.363;

