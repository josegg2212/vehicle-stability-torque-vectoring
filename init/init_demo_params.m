% init_demo_params.m
% Visual parameters for 2D demo

car_length = 4.7;       % Vehicle drawing length [m]
car_width  = 1.9;       % Vehicle drawing width [m]

road_width = 12.0;      % Road width [m]
lane_width = 3.5;       % Lane width [m]

demo_dt = 0.02;         % Animation time step [s]
export_video = false;   % Save animation using VideoWriter when true
video_fps = 30;

% Presentation axis mode: fixed limits per scenario (no automatic zoom)
use_presentation_axes = true;

% Straight-road scenarios
presentation_xlim_straight = [-10, 350];
presentation_ylim_straight = [-15, 80];

% Curved-road scenarios
presentation_xlim_corner = [-10, 350];
presentation_ylim_corner = [-15, 80];
