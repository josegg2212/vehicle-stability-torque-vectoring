function [input_contract, output_contract] = vehicle_interface_contract()
%VEHICLE_INTERFACE_CONTRACT Defines the signal contract for integration.
%
% This file documents the signals exchanged between:
% Scenario Inputs -> Vehicle Interface -> Output Logging

%% Input contract: signals provided by Scenario Inputs

input_signal = [
    "delta"
    "mu"
    "T_driver_total"
    "y_ref"
];

input_unit = [
    "rad"
    "-"
    "N*m"
    "m"
];

input_description = [
    "Steering angle input for the manoeuvre"
    "Road friction coefficient"
    "Total driver torque demand"
    "Lateral reference trajectory"
];

input_contract = table(input_signal, input_unit, input_description);

%% Output contract: signals expected from Vehicle Interface

output_signal = [
    "x"
    "y"
    "psi"
    "Vx"
    "Vy"
    "beta"
    "r"
    "ay"
    "Mz_cmd"
    "T_FL"
    "T_FR"
    "T_RL"
    "T_RR"
];

output_unit = [
    "m"
    "m"
    "rad"
    "m/s"
    "m/s"
    "rad"
    "rad/s"
    "m/s^2"
    "N*m"
    "N*m"
    "N*m"
    "N*m"
    "N*m"
];

output_description = [
    "Global longitudinal position"
    "Global lateral position"
    "Vehicle heading angle"
    "Longitudinal vehicle speed"
    "Lateral vehicle speed"
    "Vehicle sideslip angle"
    "Yaw rate"
    "Lateral acceleration"
    "Corrective yaw moment command"
    "Front-left wheel torque"
    "Front-right wheel torque"
    "Rear-left wheel torque"
    "Rear-right wheel torque"
];

output_contract = table(output_signal, output_unit, output_description);

%% Display

disp("========================================");
disp("VEHICLE INTERFACE INPUT CONTRACT");
disp("========================================");
disp(input_contract);

disp("========================================");
disp("VEHICLE INTERFACE OUTPUT CONTRACT");
disp("========================================");
disp(output_contract);

%% Save tables

if ~exist("results", "dir")
    mkdir("results");
end

writetable(input_contract, fullfile("results", "vehicle_interface_input_contract.csv"));
writetable(output_contract, fullfile("results", "vehicle_interface_output_contract.csv"));

disp("Interface contract saved in results folder.");

end