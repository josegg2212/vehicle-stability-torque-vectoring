% =========================================================================
% plot_persona3_run.m
% Visualización provisional de una simulación de Persona 3
% =========================================================================

clc;

% -------------------------------------------------------------------------
% Lectura de señales obligatorias
% -------------------------------------------------------------------------
delta_sig  = read_logged_signal(out.delta_ws);
Mz_cmd_sig = read_logged_signal(out.Mz_cmd_ws);
Vy_sig     = read_logged_signal(out.Vy_ws);
r_sig      = read_logged_signal(out.r_ws);
ay_sig     = read_logged_signal(out.ay_ws);
beta_sig   = read_logged_signal(out.beta_ws);
psi_sig    = read_logged_signal(out.psi_ws);
X_sig      = read_logged_signal(out.X_ws);
Y_sig      = read_logged_signal(out.Y_ws);

% -------------------------------------------------------------------------
% Señales opcionales
% -------------------------------------------------------------------------
has_rref    = has_signal(out, 'r_ref_ws');
has_mode    = has_signal(out, 'mode_beta_ws');
has_Mzap    = has_signal(out, 'Mz_applied_ws');
has_Mz_yaw  = has_signal(out, 'Mz_yaw_ws');
has_Mz_beta = has_signal(out, 'Mz_beta_ws');

if has_rref
    rref_sig = read_logged_signal(out.r_ref_ws);
end

if has_mode
    mode_sig = read_logged_signal(out.mode_beta_ws);
end

if has_Mzap
    Mz_applied_sig = read_logged_signal(out.Mz_applied_ws);
end

if has_Mz_yaw
    Mz_yaw_sig = read_logged_signal(out.Mz_yaw_ws);
end

if has_Mz_beta
    Mz_beta_sig = read_logged_signal(out.Mz_beta_ws);
end

% -------------------------------------------------------------------------
% Conversión de unidades útiles
% -------------------------------------------------------------------------
beta_deg  = rad2deg(beta_sig.values);
delta_deg = rad2deg(delta_sig.values);

% -------------------------------------------------------------------------
% Figura 1: entrada de dirección y momento corrector final
% -------------------------------------------------------------------------
figure('Name','Entrada y momento corrector final','Color','w');

subplot(2,1,1);
plot(delta_sig.time, delta_deg, 'LineWidth', 1.5);
grid on;
xlabel('Tiempo [s]');
ylabel('\delta [deg]');
title('Ángulo de dirección');

subplot(2,1,2);
plot(Mz_cmd_sig.time, Mz_cmd_sig.values, 'LineWidth', 1.5);
hold on;
if has_Mzap
    plot(Mz_applied_sig.time, Mz_applied_sig.values, '--', 'LineWidth', 1.2);
    legend('Mz\_cmd','Mz\_applied','Location','best');
else
    legend('Mz\_cmd','Location','best');
end
grid on;
xlabel('Tiempo [s]');
ylabel('Mz [N·m]');
title('Momento corrector final');

% -------------------------------------------------------------------------
% Figura 2: contribuciones internas del controlador
% -------------------------------------------------------------------------
if has_Mz_yaw || has_Mz_beta || has_mode
    figure('Name','Diagnóstico del controlador','Color','w');

    subplot(2,1,1);
    hold on;
    if has_Mz_yaw
        plot(Mz_yaw_sig.time, Mz_yaw_sig.values, 'LineWidth', 1.5);
    end
    if has_Mz_beta
        plot(Mz_beta_sig.time, Mz_beta_sig.values, 'LineWidth', 1.5);
    end
    if has_Mz_yaw && has_Mz_beta
        legend('Mz\_yaw','Mz\_beta','Location','best');
    elseif has_Mz_yaw
        legend('Mz\_yaw','Location','best');
    elseif has_Mz_beta
        legend('Mz\_beta','Location','best');
    end
    grid on;
    xlabel('Tiempo [s]');
    ylabel('Mz [N·m]');
    title('Contribuciones de las ramas yaw y beta');

    subplot(2,1,2);
    if has_mode
        plot(mode_sig.time, mode_sig.values, 'LineWidth', 1.5);
        ylim([-0.1 1.1]);
        grid on;
        xlabel('Tiempo [s]');
        ylabel('mode\_beta');
        title('Activación del modo beta');
    else
        text(0.1,0.5,'No se ha registrado mode\_beta\_ws','FontSize',12);
        axis off;
    end
end

% -------------------------------------------------------------------------
% Figura 3: estados laterales principales
% -------------------------------------------------------------------------
figure('Name','Estados laterales','Color','w');

subplot(3,1,1);
plot(r_sig.time, r_sig.values, 'LineWidth', 1.5);
hold on;
if has_rref
    plot(rref_sig.time, rref_sig.values, '--', 'LineWidth', 1.2);
    legend('r','r_{ref}','Location','best');
end
grid on;
xlabel('Tiempo [s]');
ylabel('r [rad/s]');
title('Yaw rate');

subplot(3,1,2);
plot(beta_sig.time, beta_deg, 'LineWidth', 1.5);
hold on;
if exist('beta_on_deg','var') == 1
    yline(beta_on_deg, '--');
    yline(-beta_on_deg, '--');
end
if exist('beta_off_deg','var') == 1
    yline(beta_off_deg, ':');
    yline(-beta_off_deg, ':');
end
grid on;
xlabel('Tiempo [s]');
ylabel('\beta [deg]');
title('Sideslip angle');

subplot(3,1,3);
plot(Vy_sig.time, Vy_sig.values, 'LineWidth', 1.5);
grid on;
xlabel('Tiempo [s]');
ylabel('Vy [m/s]');
title('Velocidad lateral');

% -------------------------------------------------------------------------
% Figura 4: aceleración lateral
% -------------------------------------------------------------------------
figure('Name','Aceleración lateral','Color','w');
plot(ay_sig.time, ay_sig.values, 'LineWidth', 1.5);
grid on;
xlabel('Tiempo [s]');
ylabel('a_y [m/s^2]');
title('Aceleración lateral');

% -------------------------------------------------------------------------
% Figura 5: trayectoria
% -------------------------------------------------------------------------
figure('Name','Trayectoria XY','Color','w');
plot(X_sig.values, Y_sig.values, 'LineWidth', 1.8);
grid on;
axis equal;
xlabel('X [m]');
ylabel('Y [m]');
title('Trayectoria del vehículo');

% -------------------------------------------------------------------------
% Figura 6: orientación
% -------------------------------------------------------------------------
figure('Name','Orientación','Color','w');
plot(psi_sig.time, rad2deg(psi_sig.values), 'LineWidth', 1.5);
grid on;
xlabel('Tiempo [s]');
ylabel('\psi [deg]');
title('Orientación global');

% -------------------------------------------------------------------------
% Resumen rápido por consola
% -------------------------------------------------------------------------
fprintf('\n================ RESUMEN RÁPIDO ================\n');
fprintf('Max |beta|   = %.3f deg\n', max(abs(beta_deg)));
fprintf('Max |r|      = %.3f rad/s\n', max(abs(r_sig.values)));
fprintf('Max |Vy|     = %.3f m/s\n', max(abs(Vy_sig.values)));
fprintf('Max |ay|     = %.3f m/s^2\n', max(abs(ay_sig.values)));
fprintf('Max |Mz_cmd| = %.3f N·m\n', max(abs(Mz_cmd_sig.values)));

if has_Mzap
    fprintf('Max |Mz_applied| = %.3f N·m\n', max(abs(Mz_applied_sig.values)));
else
    fprintf('Mz_applied_ws no está disponible en out.\n');
end

if has_Mz_yaw
    fprintf('Max |Mz_yaw|   = %.3f N·m\n', max(abs(Mz_yaw_sig.values)));
else
    fprintf('Mz_yaw_ws no está disponible en out.\n');
end

if has_Mz_beta
    fprintf('Max |Mz_beta|  = %.3f N·m\n', max(abs(Mz_beta_sig.values)));
else
    fprintf('Mz_beta_ws no está disponible en out.\n');
end

if has_mode
    mode_vals = mode_sig.values;
    mode_time = mode_sig.time;

    if numel(mode_time) > 1
        dt_mode = mean(diff(mode_time));
        beta_active_time = sum(mode_vals > 0.5) * dt_mode;
        beta_active_pct  = 100 * beta_active_time / (mode_time(end) - mode_time(1));
    else
        beta_active_time = 0;
        beta_active_pct  = 0;
    end

    fprintf('Tiempo activo modo beta = %.4f s\n', beta_active_time);
    fprintf('Porcentaje activo beta  = %.2f %%\n', beta_active_pct);
else
    fprintf('mode_beta_ws no está disponible en out.\n');
end

fprintf('================================================\n');

% =========================================================================
% Función auxiliar: lectura de señal
% =========================================================================
function sig = read_logged_signal(var_in)
    if isstruct(var_in)
        sig.time = var_in.time;
        sig.values = squeeze(var_in.signals.values);
    elseif isa(var_in, 'timeseries')
        sig.time = var_in.Time;
        sig.values = squeeze(var_in.Data);
    else
        error('Formato de señal no soportado.');
    end
end

% =========================================================================
% Función auxiliar: comprobar si una señal existe dentro de out
% =========================================================================
function tf = has_signal(out_obj, signal_name)
    tf = false;
    try
        tmp = out_obj.(signal_name); %#ok<NASGU>
        tf = true;
    catch
        tf = false;
    end
end