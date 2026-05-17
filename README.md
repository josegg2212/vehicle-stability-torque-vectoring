# vehicle-stability-torque-vectoring

## 1) Objetivo

Este proyecto implementa y compara control de estabilidad y torque vectoring en un vehiculo electrico con traccion en las cuatro ruedas, usando MATLAB/Simulink.

El objetivo de la entrega final es doble:
1. Que la simulacion sea tecnicamente coherente (modelo, control y metricas).
2. Que la presentacion sea interpretable (demo 2D con carretera fija, referencia fija y trayectoria real).

## 2) Arquitectura final

Modelo principal:
- `full_system.slx`

Flujo funcional:
1. `Scenario Inputs` genera:
   - `delta_ff` (direccion base del escenario)
   - `mu` (adherencia)
   - `T_driver_total`
   - `y_ref` (referencia lateral)
2. `Path Tracking Controller` calcula direccion aplicada:
   - `delta_cmd = sat(rate(delta_ff + delta_fb))`
   - `delta_fb = K_y * (y_ref - y) - K_psi * psi`
3. `Vehicle Interface` ejecuta:
   - modo `without_control` (sin momento de estabilidad)
   - modo `stability_control` (aplica `Mz_cmd`)
   - modo `torque_vectoring` (convierte momento a reparto de par por rueda)
4. `Output Logging` guarda todas las senales necesarias para metricas y visualizacion.

Separacion clave de senales:
- `delta_ff`: entrada base del escenario.
- `delta_cmd`: direccion final realmente aplicada al vehiculo.

## 3) Evolucion del trabajo

### Fase A: seguimiento lateral basico
- Se anadio control de seguimiento de `y_ref`.
- Se incorporo saturacion fisica de direccion y limite de rapidez de giro.
- Todas las ganancias quedaron en `init/` (sin hardcode en bloques).

### Fase B: coherencia de la demo 2D
- La carretera se define por escenario y no a partir de la trayectoria real.
- Se separaron claramente:
  - geometria de carretera,
  - referencia lateral,
  - trayectoria real del vehiculo.
- El panel de reparto de par se calcula solo desde `T_FL`, `T_FR`, `T_RL`, `T_RR`.

### Fase C: escenarios y comparacion robusta
- Se mantuvieron los tres escenarios originales.
- Se anadio `high_speed_low_mu_slalom` para mostrar un caso donde:
  - `stability_control` no es suficiente,
  - `torque_vectoring` aporta mejora clara.

### Fase D: limpieza para entrega
- Se eliminaron modelos y scripts legacy no usados.
- Se reviso calidad de codigo (`checkcode`) en scripts activos.
- Se regeneraron resultados y figuras de comparacion.

## 4) Escenarios y modos

Escenarios:
- `double_lane_change`
- `aggressive_corner`
- `low_mu_lane_change`
- `high_speed_low_mu_slalom`

Modos de control:
- `0 = without_control`
- `1 = stability_control`
- `2 = torque_vectoring`

Interpretacion correcta:
- `without_control` no significa "sin seguir referencia"; el path tracking sigue activo. Significa "sin estabilidad adicional ni torque vectoring".
- `stability_control` agrega control de yaw (`Mz_cmd`).
- `torque_vectoring` agrega reparto asimetrico de par para generar yaw adicional (`Mz_applied`).

## 5) Resultados globales (12 casos)

Archivo fuente:
- `results/full_system/metrics/all_full_system_metrics.csv`

Metricas clave:
- `rms_y_error_m`
- `max_abs_y_error_m`
- `max_abs_beta_deg`
- `max_abs_r_rad_s`
- `max_abs_Mz_applied_Nm`
- `max_abs_torque_difference_RL_Nm`

| Scenario | Mode | RMS e_y [m] | Max abs e_y [m] | Max abs beta [deg] | Max abs r [rad/s] | Max abs Mz_applied [Nm] | Max abs DeltaT_lr [Nm] |
|---|---|---:|---:|---:|---:|---:|---:|
| double_lane_change | without_control | 2.017 | 4.556 | 2.484 | 0.521 | 0 | 0 |
| double_lane_change | stability_control | 1.161 | 2.938 | 1.387 | 0.511 | 9101 | 0 |
| double_lane_change | torque_vectoring | 1.092 | 2.881 | 3.283 | 0.499 | 11644 | 5123 |
| aggressive_corner | without_control | 5.655 | 12.400 | 1.681 | 0.278 | 0 | 0 |
| aggressive_corner | stability_control | 0.910 | 1.342 | 1.024 | 0.207 | 10282 | 0 |
| aggressive_corner | torque_vectoring | 0.966 | 1.423 | 1.651 | 0.237 | 9162 | 4031 |
| low_mu_lane_change | without_control | 26.544 | 111.442 | 29.275 | 0.448 | 0 | 0 |
| low_mu_lane_change | stability_control | 1.398 | 3.113 | 3.408 | 0.517 | 7742 | 0 |
| low_mu_lane_change | torque_vectoring | 1.335 | 3.064 | 5.195 | 0.494 | 7742 | 3406 |
| high_speed_low_mu_slalom | without_control | 105.816 | 325.567 | 268.013 | 0.630 | 0 | 0 |
| high_speed_low_mu_slalom | stability_control | 60.577 | 450.482 | 352.590 | 4.792 | 10492 | 0 |
| high_speed_low_mu_slalom | torque_vectoring | 1.677 | 5.395 | 5.297 | 0.539 | 10492 | 4616 |

## 6) Interpretacion tecnica por escenario

### double_lane_change
- `without_control`: mas oscilacion lateral y mas error.
- `stability_control`: reduce claramente deriva y oscilacion.
- `torque_vectoring`: mejora adicional ligera y muestra reparto de par.

### aggressive_corner
- Escenario centrado en giro sostenido, no en cambio de carril puro.
- `stability_control` controla bien `r` y `beta`.
- `torque_vectoring` mantiene comportamiento comparable y con accion de reparto.

### low_mu_lane_change
- La baja adherencia penaliza fuerte el caso `without_control`.
- `stability_control` recupera gran parte de estabilidad.
- `torque_vectoring` aporta mejor seguimiento lateral y momento de guiada efectivo.

### high_speed_low_mu_slalom
- Escenario de validacion exigente.
- `stability_control` solo no mantiene trayectoria con calidad suficiente.
- `torque_vectoring` marca la diferencia: reduce mucho el error lateral y estabiliza.

## 7) Demo 2D

Las figuras 2D se guardan en:
- `results/figures/demos_2D/<scenario>/<scenario>_<mode>_trajectory.png`

Las comparativas por escenario se guardan en:
- `results/full_system/comparisons/<scenario>_vehicle_comparison.png`

Principios visuales usados:
- carretera fija por escenario,
- referencia fija del escenario,
- trayectoria real de simulacion,
- panel de par coherente con los torques de rueda.

## 8) Ejecucion

Secuencia recomendada para entrega (2D + metricas):
1. `run('init/init_project_final.m')`
2. `run('run_all_full_system_scenarios.m')`
3. `run('scripts/run_all_input_scenarios.m')`
4. `run('scripts/prepare_all_demos_2D_3D.m')`
5. `run('scripts/run_all_demos_visualization.m')`
6. `run('scripts/run_all_vehicle_comparisons.m')`

Nota:
- La parte 3D queda opcional para esta entrega. El flujo principal evaluado es el de metricas y demo 2D.

## 9) Estructura limpia del repositorio

- `full_system.slx`: modelo principal de simulacion.
- `init/`: parametros del vehiculo, controladores y configuracion.
- `scripts/`: ejecucion batch, escenarios, metricas, exportes y visualizacion.
- `models/`: modelo auxiliar opcional para 3D (`demo_3D_unreal.slx`).
- `results/`: resultados de simulacion, metricas y figuras.

Nomenclatura de scripts:
- Los nombres siguen formato funcional directo: `run_*`, `prepare_*`, `plot_*`, `compute_*`, `init_*`.
- Se han retirado aliases y scripts de pruebas antiguas para evitar ambiguedad.
- Los unicos nombres historicos mantenidos son `P1_parametros_IONIQ5N.m` y `P2_parametros_IONIQ5N.m` porque representan bloques de parametros originales del vehiculo.

Elementos legacy eliminados (no funcionales):
- modelos legacy de controlador/planta separados,
- scripts de desarrollo obsoletos,
- caches de compilacion y ficheros temporales.

## 10) Estado final de entrega

- Funcionalidad validada sin cambiar el comportamiento deseado.
- Escenarios y modos listos para presentacion y memoria.
- Codigo y estructura depurados para evitar contenido legacy.
- Documentacion unificada y coherente con resultados.
