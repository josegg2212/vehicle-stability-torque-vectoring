function scenario = scenario_library(scenario_name)
%SCENARIO_LIBRARY Defines simulation scenarios and fixed road/reference data.

switch string(scenario_name)

    case "double_lane_change"
        scenario.name = "double_lane_change";
        scenario.Tend = 12;
        scenario.Ts = 0.01;
        scenario.Vx0 = 23;
        scenario.y0 = 3.0;

        % Double lane change between lanes: left -> right -> left.
        scenario.t_delta = [0 1.0 2.0 3.0 4.3 12.0];
        scenario.delta_deg = [0 -3.8 4.6 -2.5 0 0];

        scenario.t_mu = [0 12];
        scenario.mu = [0.9 0.9];

        [scenario.t_y_ref, scenario.y_ref] = build_double_lane_change_between_lanes_reference( ...
            scenario.Tend, scenario.Ts, 3.0, 1.1, 2.4, 3.1, 4.9);

        scenario.T_driver_total = 1200;

        scenario.x_ref = scenario.Vx0 * scenario.t_y_ref;
        scenario.y_ref_path = scenario.y_ref;
        scenario.road_x = linspace(0, scenario.Vx0 * scenario.Tend + 40, 800);
        scenario.road_y = zeros(size(scenario.road_x));
        scenario.road_type = "straight";

    case "low_mu_lane_change"
        scenario.name = "low_mu_lane_change";
        scenario.Tend = 12;
        scenario.Ts = 0.01;
        scenario.Vx0 = 21;
        scenario.y0 = 3.0;

        scenario.t_delta = [0 1.1 2.2 3.2 12.0];
        scenario.delta_deg = [0 -3.2 3.8 0 0];
    
        scenario.t_mu = [0 2.0 3.8 8.5 12.0];
        scenario.mu = [0.9 0.9 0.45 0.45 0.9];
    
        [scenario.t_y_ref, scenario.y_ref] = build_single_lane_change_between_lanes_reference( ...
            scenario.Tend, scenario.Ts, 3.0, 1.1, 2.4);
    
        scenario.T_driver_total = 1200;
    
        scenario.x_ref = scenario.Vx0 * scenario.t_y_ref;
        scenario.y_ref_path = scenario.y_ref;
        scenario.road_x = linspace(0, scenario.Vx0 * scenario.Tend + 40, 800);
        scenario.road_y = zeros(size(scenario.road_x));
        scenario.road_type = "straight";
        scenario.low_mu_zone_x = [scenario.Vx0 * 3.6, scenario.Vx0 * 8.5];
        scenario.low_mu_zone_value = 0.45;

    case "aggressive_corner"
        scenario.name = "aggressive_corner";
        scenario.Tend = 14;
        scenario.Ts = 0.01;
        scenario.Vx0 = 24;

        scenario.t_delta = [0 1.2 2.8 5.0 14.0];
        scenario.delta_deg = [0 1.4 2.7 3.2 3.2];

        scenario.t_mu = [0 14];
        scenario.mu = [0.9 0.9];

        [t_ref, y_ref, x_ref] = build_aggressive_corner_reference( ...
            scenario.Tend, scenario.Ts, scenario.Vx0);
        scenario.t_y_ref = t_ref;
        scenario.y_ref = y_ref;

        scenario.T_driver_total = 1200;

        scenario.x_ref = x_ref;
        scenario.y_ref_path = y_ref;
        % Keep a fully curved road for the whole scenario to avoid a
        % curve-then-straight visual transition.
        scenario.road_x = x_ref;
        scenario.road_y = y_ref;
        scenario.road_type = "curved";

    case "high_speed_low_mu_slalom"
        scenario.name = "high_speed_low_mu_slalom";
        scenario.Tend = 13;
        scenario.Ts = 0.01;
        scenario.Vx0 = 28;

        % Feedforward steering that roughly follows the slalom shape.
        scenario.t_delta = [0 0.9 1.8 2.7 3.6 4.6 5.6 6.8 13.0];
        scenario.delta_deg = [0 1.96 -3.36 3.78 -3.57 2.80 -1.82 0 0];

        % Low-mu region during the demanding slalom interval.
        scenario.t_mu = [0 1.8 2.0 10.5 13.0];
        scenario.mu = [0.9 0.9 0.50 0.50 0.8];

        [scenario.t_y_ref, scenario.y_ref] = build_slalom_reference( ...
            scenario.Tend, scenario.Ts, 2.1, 1.0, 2.0, 2.3, 3.3, 3.7, 4.7, 5.1, 6.2);

        scenario.T_driver_total = 2400;

        scenario.x_ref = scenario.Vx0 * scenario.t_y_ref;
        scenario.y_ref_path = scenario.y_ref;
        scenario.road_x = linspace(0, scenario.Vx0 * scenario.Tend + 40, 900);
        scenario.road_y = zeros(size(scenario.road_x));
        scenario.road_type = "straight";
        scenario.low_mu_zone_x = [scenario.Vx0 * 2.0, scenario.Vx0 * 10.5];
        scenario.low_mu_zone_value = 0.50;

    otherwise
        error("Unknown scenario name: %s", scenario_name);
end

end


function [t_ref_row, y_ref_row] = build_lane_change_reference(Tend, Ts, lane_shift, t_up0, t_up1, t_down0, t_down1)
t_ref = (0:Ts:Tend)';
s_up = smoothstep(t_ref, t_up0, t_up1);
s_down = smoothstep(t_ref, t_down0, t_down1);
y_ref = lane_shift * (s_up - s_down);
t_ref_row = t_ref';
y_ref_row = y_ref';
end

function [t_ref_row, y_ref_row] = build_double_lane_change_between_lanes_reference( ...
    Tend, Ts, lane_offset, t_right0, t_right1, t_left0, t_left1)
t_ref = (0:Ts:Tend)';
s_to_right = smoothstep(t_ref, t_right0, t_right1);
s_back_left = smoothstep(t_ref, t_left0, t_left1);
y_ref = lane_offset - 2*lane_offset*s_to_right + 2*lane_offset*s_back_left;
t_ref_row = t_ref';
y_ref_row = y_ref';
end

function [t_ref_row, y_ref_row] = build_single_lane_change_between_lanes_reference( ...
    Tend, Ts, lane_offset, t_right0, t_right1)
t_ref = (0:Ts:Tend)';
s_to_right = smoothstep(t_ref, t_right0, t_right1);
y_ref = lane_offset - 2*lane_offset*s_to_right;
t_ref_row = t_ref';
y_ref_row = y_ref';
end


function [t_ref_row, y_ref_row] = build_slalom_reference( ...
    Tend, Ts, amp, t1_on, t1_off, t2_on, t2_off, t3_on, t3_off, t4_on, t4_off)
t_ref = (0:Ts:Tend)';

s1 = smoothstep(t_ref, t1_on, t1_off);
s2 = smoothstep(t_ref, t2_on, t2_off);
s3 = smoothstep(t_ref, t3_on, t3_off);
s4 = smoothstep(t_ref, t4_on, t4_off);

% 0 -> +amp -> -amp -> +amp -> 0
y_ref = amp * (s1 - 2*s2 + 2*s3 - s4);

t_ref_row = t_ref';
y_ref_row = y_ref';
end


function [t_ref_row, y_ref_row, x_ref_row] = build_aggressive_corner_reference(Tend, Ts, Vx0)
t_ref = (0:Ts:Tend)';
r_ss = 0.045;  % [rad/s] nominal steady yaw rate for visual reference
r_profile = r_ss * smoothstep(t_ref, 2.0, 4.5);
psi_ref = cumtrapz(t_ref, r_profile);
x_ref = cumtrapz(t_ref, Vx0 * cos(psi_ref));
y_ref = cumtrapz(t_ref, Vx0 * sin(psi_ref));

t_ref_row = t_ref';
y_ref_row = y_ref';
x_ref_row = x_ref';
end


function s = smoothstep(t, t0, t1)
if t1 <= t0
    error("smoothstep requires t1 > t0.");
end
tau = (t - t0) / (t1 - t0);
tau = min(max(tau, 0), 1);
s = tau.^2 .* (3 - 2 * tau);
end
