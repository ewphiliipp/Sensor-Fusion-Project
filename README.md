# Smartphone Sensor Fusion for Running Analysis

A multi-sensor fusion pipeline that estimates **distance and elevation** during running using smartphone sensors.

## How it works

Combines data from 5 sensors:
- **GNSS** – absolute position
- **IMU / Accelerometer** – velocity estimation (100 Hz)
- **Gyroscope** – 3D orientation (100 Hz)
- **Magnetometer** – heading correction (100 Hz)
- **Barometer** – elevation estimation (1 Hz)

Processing steps: Bias elimination → Madgwick AHRS → ZUPT → Extended Kalman Filter → Barometric elevation → Hybrid distance calculation

## Results

| Metric | Accuracy |
|---|---|
| Horizontal Distance | 97.80% (RMSE: 26.57 m) |
| Elevation Gain | 89.93% |
| Elevation Loss | 91.94% |

## Requirements

- MATLAB
- Phyphox app (raw sensor data export)
- DGM1 terrain data (optional, for elevation ground truth)

## Data Collection

1. Strap phone tightly around waist
2. Stand still 10 seconds before and after run
3. Export CSV from Phyphox
4. Run pipeline

## References

Groves, P.D. (2013). *Principles of GNSS, Inertial, and Multisensor Integrated Navigation Systems*

Madgwick, S. (2010). *An efficient orientation filter for inertial and inertial/magnetic sensor arrays*
