# vehicle-stability-torque-vectoring

Proyecto final de control integrado de estabilidad y reparto de par para un vehiculo electrico de cuatro motores sobre el modelo `full_system.slx`.

## Resumen

El proyecto integra:
- Control de estabilidad en guinada y sideslip.
- Reparto de par izquierda-derecha para generar momento de guinada.
- Simulacion de tres escenarios de maniobra con tres modos de control.
- Modelo principal unico: `full_system.slx` en la raiz del repositorio.

## Estructura de carpetas

- `init/`: inicializacion central y parametros del vehiculo/controlador/allocator/demo.
- `scripts/`: ejecucion de escenarios, metricas, plots, comparativas y demo 2D.
- `models/`: recursos de modelos auxiliares.
- `results/runs/`: salidas `.mat` de simulaciones y `demo_2D_input_data.mat`.
- `results/full_system/metrics/`: metricas CSV por caso y globales.
- `results/full_system/plots/`: plots de respuesta por escenario/caso.
- `results/full_system/comparisons/`: comparativas por escenario.
- `results/figures/`: figuras de la demo 2D desde datos.

## Orden de ejecucion desde cero

1. Abrir MATLAB en la raiz del repositorio.
2. `run('init/init_project_final.m')`
3. `run('run_all_full_system_scenarios.m')`
4. `run('scripts/run_all_vehicle_comparisons.m')`
5. `run('scripts/export_demo_2D_input_data_from_full_system.m')`
6. `run('scripts/demo_2D_from_data.m')`

## Preparar las 9 demos (2D + 3D) de una vez

Para generar automaticamente los 9 casos oficiales (`3 escenarios x 3 modos`) y dejar listos los datos para visualizacion 2D y 3D:

1. Abrir MATLAB en la raiz del repositorio.
2. `run('scripts/prepare_all_demos_2D_3D.m')`

Salida generada:

- `results/runs/demos_2D/<scenario>/<scenario>_<case>_demo_2D_input_data.mat`
- `results/runs/demos_3D/<scenario>/<scenario>_<case>_demo_3D_unreal_input_data.mat`
- `results/runs/demo_cases_manifest.csv`

## Visualizar las 9 demos en lote

Para recorrer los 9 casos y generar visualizacion 2D por caso (mas launchers 3D por caso):

1. `run('scripts/run_all_demos_visualization.m')`

Salida generada:

- Figuras 2D por caso en:
  `results/figures/demos_2D/<scenario>/<scenario>_<case>_trajectory.png`
- Launchers 3D por caso en:
  `results/runs/demos_3D/launchers/`

## Escenarios oficiales

- `double_lane_change`: doble cambio de carril.
- `aggressive_corner`: curva sostenida agresiva.
- `low_mu_lane_change`: cambio de carril con reduccion de `mu`.

## Modos de control

- `0 = without_control`
- `1 = stability_control`
- `2 = torque_vectoring`

## Donde se guarda cada salida

- Simulaciones `.mat`: `results/runs/`
- Metricas: `results/full_system/metrics/`
- Plots individuales: `results/full_system/plots/`
- Comparativas por escenario: `results/full_system/comparisons/`
- Figuras demo 2D: `results/figures/`

## Nota sobre low_mu_lane_change

`low_mu_lane_change` uses a time-varying road friction coefficient. In the current model, `mu` limits the lateral tire forces in the bicycle model through a simple `mu*Fz` saturation and also limits the maximum transmissible torque per wheel through `mu*Fz*rw`. This is a simple friction-limited approximation, not a full Pacejka tire model.

## Nota sobre resultados incluidos

Los resultados finales se conservan en el repositorio para facilitar la revision, pero pueden regenerarse completamente ejecutando la secuencia de scripts indicada arriba.


