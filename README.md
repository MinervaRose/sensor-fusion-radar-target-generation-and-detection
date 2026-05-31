# Radar Target Generation and Detection: Final Project

## Overview

This project implements an **FMCW radar simulation** and **2D CFAR detection** in MATLAB.  
It models the radar signal generation, propagation, target motion, FFT-based range and Doppler estimation, and dynamic noise thresholding through CFAR.  
The goal is to detect a moving target accurately while suppressing background noise.

---

## 1. Implementation steps for the 2D CFAR process

The **2D CFAR (Constant False Alarm Rate)** algorithm was applied on the **Range Doppler Map (RDM)** to dynamically estimate a noise threshold for each Cell Under Test (CUT).

### Process summary

1. **Define** the number of training and guard cells in both dimensions:
   - Training cells - estimate background noise  
   - Guard cells - prevent target signal leakage  

2. **Slide** the CUT across the entire RDM (skipping the edges).

3. **For each CUT:**
   - Extract the surrounding grid of training and guard cells  
   - Exclude guard cells and the CUT itself  
   - Convert from dB to linear scale using `db2pow()`  
   - Compute the average noise level  
   - Convert back to dB with `pow2db()`  
   - Add the **offset (in dB)** to form the detection threshold  

4. **Compare** the CUT signal to the threshold:  
   - If `CUT > threshold → 1` (target detected)  
   - Else `0` (no target)

5. **Repeat** for all possible CUTs.

6. The final output is a **binary detection map** where only true targets are retained.

---

## 2. Selection of training cells, guard cells, and offset

| Parameter | Symbol | Value | Rationale |
|------------|---------|--------|------------|
| Training Cells (Range) | `Tr` | 10 | Sufficient neighborhood for noise estimation |
| Training Cells (Doppler) | `Td` | 8 | Keeps processing time manageable |
| Guard Cells (Range) | `Gr` | 4 | Prevents target leakage into training region |
| Guard Cells (Doppler) | `Gd` | 4 | Ensures stable detection boundary |
| Offset | — | 6 dB | Provides appropriate SNR margin to reduce false alarms |

These values were fine-tuned empirically to give a **clean detection peak** and effective **noise suppression**.

---

## 3. Edge handling: suppressing non-thresholded cells

Because training and guard cells extend around the CUT, edge cells cannot be processed.  
To handle this, the algorithm:

- Restricts the CFAR sliding window to:
* Range: (Tr+Gr+1) → (Nr/2 - (Gr+Tr))
* Doppler: (Td+Gd+1) → (Nd - (Gd+Td))

- Sets **all non-processed edge values to zero** in the final detection map.
- Maintains **the same matrix size** as the RDM for consistent visualization.

---

## 4. Outcome

- The 2D CFAR output successfully suppresses noise and highlights the target.  
- A clear detection appears at approximately **110 m range** and **−20 m/s velocity**.  
- The final plot matches the expected output from the walkthrough example.

---

## References

- Udacity Sensor Fusion Nanodegree: *Radar Target Generation and Detection Project*  
- [Analog Devices  Beam Steering Design](https://www.analog.com)  
- [Electronic Products 2D CFAR Visualization](https://www.electronicproducts.com)

---

**Author:** Sabrina Palis  
