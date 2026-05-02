function [T_FL, T_FR, T_RL, T_RR, Mz_applied] = torque_vectoring_logic(T_driver_total, Mz_cmd, theta_front, tf, tr, rw, Tmax_wheel, Tmin_wheel, Mz_max)
%TORQUE_VECTORING_LOGIC Distributes total driver torque and corrective yaw moment.
%
% Inputs:
%   T_driver_total : total longitudinal torque demand [N*m]
%   Mz_cmd         : requested corrective yaw moment [N*m]
%   theta_front    : fraction of Mz assigned to front axle [-]
%   tf             : front track width [m]
%   tr             : rear track width [m]
%   rw             : wheel radius [m]
%   Tmax_wheel     : maximum torque per wheel [N*m]
%   Tmin_wheel     : minimum torque per wheel [N*m]
%   Mz_max         : yaw moment saturation [N*m]
%
% Outputs:
%   T_FL, T_FR, T_RL, T_RR : wheel torques [N*m]
%   Mz_applied             : yaw moment actually applied after saturation [N*m]

    % Saturate requested yaw moment
    Mz_cmd = min(max(Mz_cmd, -Mz_max), Mz_max);

    % Nominal symmetric torque distribution
    T_nom = T_driver_total / 4;

    T_FL_nom = T_nom;
    T_FR_nom = T_nom;
    T_RL_nom = T_nom;
    T_RR_nom = T_nom;

    % Split yaw moment between front and rear axle
    Mz_front = theta_front * Mz_cmd;
    Mz_rear  = (1 - theta_front) * Mz_cmd;

    % Convert yaw moment into left-right torque difference.
    % Positive Mz: add torque to right wheels and subtract from left wheels.
    dT_front = (Mz_front * rw) / tf;
    dT_rear  = (Mz_rear  * rw) / tr;

    T_FL = T_FL_nom - dT_front;
    T_FR = T_FR_nom + dT_front;
    T_RL = T_RL_nom - dT_rear;
    T_RR = T_RR_nom + dT_rear;

    % Wheel torque saturation
    T_FL = min(max(T_FL, Tmin_wheel), Tmax_wheel);
    T_FR = min(max(T_FR, Tmin_wheel), Tmax_wheel);
    T_RL = min(max(T_RL, Tmin_wheel), Tmax_wheel);
    T_RR = min(max(T_RR, Tmin_wheel), Tmax_wheel);

    % Estimate actually generated yaw moment after saturation
    Fx_FL = T_FL / rw;
    Fx_FR = T_FR / rw;
    Fx_RL = T_RL / rw;
    Fx_RR = T_RR / rw;

    Mz_front_applied = (Fx_FR - Fx_FL) * tf / 2;
    Mz_rear_applied  = (Fx_RR - Fx_RL) * tr / 2;

    Mz_applied = Mz_front_applied + Mz_rear_applied;
end