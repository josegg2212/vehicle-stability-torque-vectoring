function scenario = scenario_library(scenario_name)
%SCENARIO_LIBRARY Defines the simulation scenarios for the vehicle project.
%
% Inputs:
%   scenario_name: name of the selected scenario
%
% Output:
%   scenario: structure with all the scenario parameters

switch scenario_name

    case "double_lane_change"

        scenario.name = "double_lane_change";

        % Simulation settings
        scenario.Tend = 12;      % [s]
        scenario.Ts = 0.01;      % [s]

        % Vehicle initial condition
        scenario.Vx0 = 22;       % [m/s]

        % Steering input
        scenario.t_delta = [0 1 2 3 4 12];          % [s]
        scenario.delta_deg = [0 5 -5 3 0 0];        % [deg]

        % Road friction coefficient
        scenario.t_mu = [0 12];                     % [s]
        scenario.mu = [0.9 0.9];                    % [-]

        % Lateral reference
        scenario.t_y_ref = [0 1 3 5 12];       % [s]
        scenario.y_ref = [0 0 3.5 0 0];        % [m]

        % Longitudinal torque demand
        scenario.T_driver_total = 1200;             % [N*m]
    case "aggressive_corner"

        scenario.name = "aggressive_corner";

        % Simulation settings
        scenario.Tend = 20;      % [s]
        scenario.Ts = 0.01;      % [s]

        % Vehicle initial condition
        scenario.Vx0 = 18;       % [m/s]

        % Steering input
        scenario.t_delta = [0 1 20];          % [s]
        scenario.delta_deg = [0 8 8];         % [deg]

        % Road friction coefficient
        scenario.t_mu = [0 20];               % [s]
        scenario.mu = [0.9 0.9];              % [-]

        % Lateral reference
        scenario.t_y_ref = [0 20];             % [s]
        scenario.y_ref = [0 0];                % [m]

        % Longitudinal torque demand
        scenario.T_driver_total = 1200;       % [N*m]
    case "low_mu_lane_change"

        scenario.name = "low_mu_lane_change";

        % Simulation settings
        scenario.Tend = 12;      % [s]
        scenario.Ts = 0.01;      % [s]

        % Vehicle initial condition
        scenario.Vx0 = 20;       % [m/s]

        % Steering input
        scenario.t_delta = [0 1 2 3 4 12];          % [s]
        scenario.delta_deg = [0 5 -5 3 0 0];        % [deg]

        % Road friction coefficient
        % Drop mu early so the low-friction phase overlaps the lane-change transient.
        scenario.t_mu = [0 1 12];                   % [s]
        scenario.mu = [0.9 0.45 0.45];              % [-]
        
        % Lateral reference
        scenario.t_y_ref = [0 1 3 5 12];       % [s]
        scenario.y_ref = [0 0 3.5 0 0];        % [m]

        % Longitudinal torque demand
        scenario.T_driver_total = 1200;             % [N*m]
    
    otherwise

        error("Unknown scenario name: %s", scenario_name);

end

end
