# vehicle-stability-torque-vectoring

Proyecto final de control integrado de estabilidad y reparto de par para un vehiculo electrico de cuatro motores sobre el modelo `full_system.slx`.

## Resumen

El proyecto integra:
- Control de estabilidad en guinada y sideslip.
- Reparto de par izquierda-derecha para generar momento de guinada.
- Control lateral simple de seguimiento de referencia `y_ref` mediante `delta_cmd`.
- Tres escenarios x tres modos de control (9 casos oficiales).

La demo 3D queda aplazada en esta entrega. El foco de validacion y presentacion es 2D + metricas.

## Estructura de carpetas

- `init/`: inicializacion y parametros.
- `scripts/`: ejecucion de escenarios, metricas, plots y demo 2D.
- `models/`: modelos auxiliares.
- `results/full_system/metrics/`: metricas CSV por caso y globales.
- `results/full_system/plots/`: plots de respuesta por escenario/caso.
- `results/figures/demos_2D/`: figuras 2D por caso.

## Escenarios y modos

Escenarios:
- `double_lane_change`
- `aggressive_corner`
- `low_mu_lane_change`

Modos:
- `0 = without_control`
- `1 = stability_control`
- `2 = torque_vectoring`

Interpretacion de modos:
- `without_control`: sin momento corrector (`Mz_cmd_to_use=0`) y reparto simetrico base.
- `stability_control`: control de estabilidad activo (momento corrector).
- `torque_vectoring`: control de estabilidad + allocator de par izquierda/derecha.

## Path Tracking Controller

Bloque nuevo en `full_system.slx`: `Path Tracking Controller`.

Ley usada:
- `delta_cmd = sat(rate(delta_ff + K_y*(y_ref-y) - K_psi*psi))`

Parametros:
- `init/init_path_tracking_controller.m`

Logging separado:
- `logs_delta_ff` (direccion feedforward de escenario)
- `logs_delta_cmd` (direccion final aplicada)

## Flujo de ejecucion (presentacion, sin 3D)

1. `run('init/init_project_final.m')`
2. `run('run_all_full_system_scenarios.m')`
3. `run('scripts/prepare_all_demos_2D_3D.m')`
4. `run('scripts/run_all_demos_visualization.m')`

Notas:
- Aunque el script de preparacion tambien genera datos 3D, la evaluacion de esta entrega se hace solo con 2D.
- Las metricas consolidadas quedan en:
  - `results/full_system/metrics/all_full_system_metrics.csv`

## Resultados finales (9 casos)

Fuente de la tabla: ultima corrida de validacion (16-May-2026) con `run_all_full_system_scenarios.m`.
Si necesitas regenerar exactamente estos datos, ejecuta de nuevo:
- `run('init/init_project_final.m')`
- `run('run_all_full_system_scenarios.m')`

Metricas clave:
- `rms_y_error_m`: error lateral RMS.
- `max_abs_y_error_m`: error lateral maximo absoluto.
- `max_abs_beta_deg`: sideslip maximo absoluto.
- `max_abs_r_rad_s`: yaw-rate maximo absoluto.
- `max_abs_ay_m_s2`: aceleracion lateral maxima absoluta.
- `max_abs_Mz_applied_Nm`: momento aplicado maximo.
- `max_abs_torque_difference_RL_Nm`: diferencia de par lateral maxima (indicador de torque vectoring).

### Tabla comparativa completa (9 casos)

| Scenario | Mode | RMS e_y [m] | Max abs e_y [m] | Max abs beta [deg] | Max abs r [rad/s] | Max abs a_y [m/s^2] | Max abs Mz_applied [Nm] | Max abs DeltaT_lr [Nm] |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| double_lane_change | without_control | 2.017 | 4.556 | 2.484 | 0.521 | 8.829 | 0 | 0 |
| double_lane_change | stability_control | 1.161 | 2.938 | 1.387 | 0.511 | 8.829 | 9101 | 0 |
| double_lane_change | torque_vectoring | 1.092 | 2.881 | 3.283 | 0.499 | 8.829 | 11644 | 5123 |
| aggressive_corner | without_control | 5.655 | 12.400 | 1.681 | 0.278 | 7.023 | 0 | 0 |
| aggressive_corner | stability_control | 0.910 | 1.342 | 1.024 | 0.207 | 3.633 | 10282 | 0 |
| aggressive_corner | torque_vectoring | 0.966 | 1.423 | 1.651 | 0.237 | 6.101 | 9162 | 4031 |
| low_mu_lane_change | without_control | 26.544 | 111.442 | 29.275 | 0.448 | 8.829 | 0 | 0 |
| low_mu_lane_change | stability_control | 1.398 | 3.113 | 3.408 | 0.517 | 8.829 | 7742 | 0 |
| low_mu_lane_change | torque_vectoring | 1.335 | 3.064 | 5.195 | 0.494 | 8.829 | 7742 | 3406 |

### Comparacion por escenario (respecto a without_control)

#### double_lane_change
- `stability_control`:
  - RMS e_y: `-42.4%`
  - Max |beta|: `-44.2%`
  - Max |r|: `-1.9%`
- `torque_vectoring`:
  - RMS e_y: `-45.9%` (mejor tracking lateral)
  - Max |r|: `-4.2%`
  - Max |beta| sube frente a without (`+32.2%`), por mayor agresividad del control lateral + reparto.

#### aggressive_corner
- `stability_control`:
  - RMS e_y: `-83.9%`
  - Max |beta|: `-39.1%`
  - Max |r|: `-25.7%`
- `torque_vectoring`:
  - RMS e_y: `-82.9%`
  - Max |beta|: `-1.8%`
  - Max |r|: `-14.9%`
- En este escenario, el caso mas robusto es `stability_control`.

#### low_mu_lane_change
- `stability_control`:
  - RMS e_y: `-94.7%`
  - Max |beta|: `-88.4%`
  - Max |r|: `+15.3%` (respuesta de guinada mas activa en baja adherencia).
- `torque_vectoring`:
  - RMS e_y: `-95.0%` (mejor tracking lateral)
  - Max |beta|: `-82.3%`
  - Max |r|: `+10.3%`
- Con baja adherencia, ambos controladores son muy superiores a without; `torque_vectoring` mejora ligeramente el tracking lateral y muestra reparto de par, `stability_control` mantiene menor pico de beta.

## Lectura corta para presentacion/memoria

- `without_control`: peor caso en los 3 escenarios; en `low_mu` se degrada claramente.
- `stability_control`: caso mas solido para estabilidad pura (beta/r), especialmente en `aggressive_corner`.
- `torque_vectoring`: aporta reparto lateral de par visible y mejora tracking lateral en lane-change, con compromiso de picos de beta en algunos casos.

## Demo 2D lista para defensa

Las figuras finales por caso se guardan en:
- `results/figures/demos_2D/<scenario>/<scenario>_<case>_trajectory.png`

La demo 2D:
- usa carretera fija por escenario,
- dibuja referencia fija (`y_ref`) y trayectoria real del vehiculo,
- muestra panel de reparto de par consistente con `T_FL/T_FR/T_RL/T_RR`,
- incluye resumen de metricas clave para interpretacion rapida.
