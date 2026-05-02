# Persona 2 - Maniobras, referencias y métricas

## Objetivo

Esta parte del proyecto define el banco de pruebas del vehículo. Su función es generar las maniobras, referencias y condiciones de simulación, ejecutar los casos de prueba y calcular métricas objetivas para comparar el comportamiento del vehículo.

La estructura está preparada para comparar tres casos:

- `without_control`: vehículo sin control.
- `stability_control`: vehículo con control de estabilidad.
- `torque_vectoring`: vehículo con control de estabilidad y reparto de par.

## Estructura general

```text
Scenario Inputs  ->  Vehicle Interface  ->  Output Logging