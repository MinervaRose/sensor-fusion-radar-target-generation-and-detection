<div align="center">

# 📡 Sensor Fusion — Radar Target Generation & Detection

### FMCW Radar Simulation, Range-Doppler Mapping, and CFAR Target Detection

![MATLAB](https://img.shields.io/badge/MATLAB-Signal_Processing-orange?style=for-the-badge)
![Radar](https://img.shields.io/badge/Radar-FMCW-blue?style=for-the-badge)
![Sensor Fusion](https://img.shields.io/badge/Sensor_Fusion-Perception-green?style=for-the-badge)
![FFT](https://img.shields.io/badge/FFT-Frequency_Analysis-purple?style=for-the-badge)
![Autonomous Driving](https://img.shields.io/badge/Autonomous_Driving-Radar_Perception-red?style=for-the-badge)

Udacity Sensor Fusion Nanodegree Project

</div>

---

# Overview

This project implements a complete FMCW radar simulation pipeline in MATLAB.

The system:

- Generates FMCW radar chirps
- Simulates a moving target
- Produces beat signals
- Performs Range FFT
- Generates a Range-Doppler Map (RDM)
- Applies 2D CFAR detection
- Isolates targets while suppressing noise

The objective is to estimate target position and velocity from simulated radar returns using techniques commonly employed in autonomous vehicles and advanced driver assistance systems (ADAS).

---

# Project Objectives

The project addresses four major radar perception tasks:

1. FMCW waveform design
2. Radar signal simulation
3. Range estimation using FFT
4. Target detection using 2D CFAR

---

# Radar Scenario

The simulated radar operates with the following specifications:

| Parameter | Value |
|------------|---------|
| Operating Frequency | 77 GHz |
| Maximum Range | 200 m |
| Range Resolution | 1 m |
| Maximum Velocity | 100 m/s |

Target parameters:

| Parameter | Value |
|------------|---------|
| Initial Range | 110 m |
| Velocity | -20 m/s |

Negative velocity indicates an approaching target. :contentReference[oaicite:1]{index=1}

---

# FMCW Waveform Design

The radar uses a Frequency-Modulated Continuous Wave (FMCW) waveform.

The waveform was designed using:

- Range Resolution
- Maximum Range
- Operating Frequency

The implementation computes:

- Sweep Bandwidth
- Chirp Duration
- Chirp Slope

The resulting chirp slope satisfies the project requirements and produces accurate range estimation. :contentReference[oaicite:2]{index=2}

---

# Signal Generation

The simulation models:

- Transmitted radar signal
- Reflected signal
- Target motion
- Time delay
- Beat signal generation

For every timestamp:

```text
Target Position
        ↓
Time Delay
        ↓
Received Signal
        ↓
Signal Mixing
        ↓
Beat Signal
```

The beat signal contains the information required for range and velocity estimation. :contentReference[oaicite:3]{index=3}

---

# Range Estimation

The first FFT stage performs range estimation.

## Process

1. Reshape beat signal
2. Perform FFT
3. Normalize output
4. Keep positive frequencies
5. Locate peak response

The resulting peak correctly identifies the target range near its simulated position. :contentReference[oaicite:4]{index=4}

---

# Range-Doppler Map

A two-dimensional FFT is applied to estimate:

- Range
- Relative velocity

This produces a Range-Doppler Map (RDM).

The RDM allows visualization of:

- Target distance
- Target speed
- Background noise

---

# 2D CFAR Detection

One of the most important stages of radar perception is target extraction.

The project implements a full 2D CFAR (Constant False Alarm Rate) detector.

---

## CFAR Workflow

For each Cell Under Test (CUT):

1. Define training cells
2. Define guard cells
3. Estimate local noise
4. Compute adaptive threshold
5. Compare CUT against threshold
6. Classify detection

Only targets exceeding the adaptive threshold are retained. :contentReference[oaicite:5]{index=5}

---

# CFAR Configuration

| Parameter | Value |
|------------|---------|
| Training Cells (Range) | 10 |
| Training Cells (Doppler) | 8 |
| Guard Cells (Range) | 4 |
| Guard Cells (Doppler) | 4 |
| Threshold Offset | 6 dB |

These parameters were empirically selected to achieve effective noise suppression while preserving target detections. :contentReference[oaicite:6]{index=6}

---

# Edge Handling

CFAR cannot be applied near the edges of the Range-Doppler Map because insufficient neighboring cells are available.

To handle this:

- Edge regions are excluded from threshold computation
- Non-processed cells are set to zero
- Matrix dimensions remain unchanged

This preserves visualization consistency while avoiding invalid detections. :contentReference[oaicite:7]{index=7}

---

# Results

The final detector successfully:

✅ Suppresses background noise

✅ Detects the target

✅ Preserves target localization

✅ Produces a clean detection map

The detected target appears near:

```text
Range    ≈ 110 m
Velocity ≈ -20 m/s
```

which matches the simulated scenario. 

---

# Technical Skills Demonstrated

## Radar Engineering

- FMCW Waveforms
- Beat Signal Analysis
- Radar Signal Processing

## Signal Processing

- FFT
- 2D FFT
- Spectral Analysis
- Range-Doppler Mapping

## Detection Theory

- CFAR
- Noise Estimation
- Adaptive Thresholding

## Autonomous Systems

- Radar Perception
- Target Tracking Foundations
- Collision Detection Foundations

---

# Repository Structure

```text
radar_target_generation_and_detection.m

README.md
```

---

# Key Concepts Explored

- FMCW Radar
- Range Estimation
- Doppler Estimation
- FFT
- Range-Doppler Maps
- CFAR
- Signal Processing
- Sensor Fusion
- Autonomous Driving

---

# Why This Project Matters

Radar remains one of the most important sensors in autonomous systems.

Unlike cameras, radar performs well in:

- Darkness
- Fog
- Rain
- Snow

Understanding FMCW radar processing is fundamental for building perception systems capable of operating in real-world conditions.

This project demonstrates the complete radar processing chain from waveform generation through target detection.

---

# Learning Outcomes

This project provided practical experience with:

- Radar signal simulation
- FMCW waveform design
- FFT-based range estimation
- Doppler estimation
- Range-Doppler Maps
- CFAR detection
- MATLAB-based signal processing

---

# References

- Udacity Sensor Fusion Nanodegree
- FMCW Radar Fundamentals
- CFAR Detection Theory
- Automotive Radar Systems

---

# Disclaimer

This repository is provided for educational and portfolio purposes.

Students may study the implementation for learning purposes, but submitting this work as coursework would constitute plagiarism and may violate academic integrity policies.

Copyright © Sabrina Palis
