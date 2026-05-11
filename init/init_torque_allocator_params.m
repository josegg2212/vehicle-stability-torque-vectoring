% init_torque_allocator_params.m
% Parámetros del reparto de par

% Distribution of the corrective yaw moment between axles
theta_front = 0.5;      % 50% front axle, 50% rear axle

% Nominal longitudinal torque distribution
front_drive_ratio = 0.5;    % 50% of driver torque to front axle
rear_drive_ratio  = 0.5;    % 50% of driver torque to rear axle

% Torque limits per wheel
Tmax_wheel = 4000;      % Maximum motor torque per wheel [N*m]
Tmin_wheel = -2000;     % Maximum regenerative/braking torque per wheel [N*m]

% Yaw moment saturation
Mz_max = 20000;         % Maximum corrective yaw moment [N*m]
Mz_min = -Mz_max;

% Small numerical protection
tf = 1.65;
tf1 = tf;  % Backward compatibility
tr = 1.65;
rw = 0.363;

