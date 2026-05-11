# vehicle-stability-torque-vectoring

Proyecto final de control integrado de estabilidad y reparto de par para un vehiculo electrico de cuatro motores sobre el modelo `full_system.slx`.

## Resumen

El proyecto integra:
- Control de estabilidad en guinada y sideslip.
- Reparto de par izquierda-derecha para generar momento de guinada.
- Simulacion de tres escenarios de maniobra con tres modos de control.

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

`low_mu_lane_change` genera la senal `mu`, pero en la version actual del modelo lineal `mu` todavia no modifica la dinamica ni limita los pares, por lo que sus resultados pueden coincidir con `double_lane_change`.


