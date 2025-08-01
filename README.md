# EL_007: Hardware Accelerator for Quaternion Multiplication

**Team Name:** EL\_007  
- Bhasuru Nikhil  
- Nainsi Kushwaha  
- Shakkar Ridhi  

## Overview

This repository contains the complete Verilog HDL implementation and system integration of a **hardware accelerator for quaternion multiplication**, developed as part of the IITI Summer of Code (SoC) program by Team EL_007.
## Team Members


The project investigates and compares four different architectures for quaternion multiplication on FPGA:
- Direct Multiplier
- Pipelined Direct Multiplier
- Algorithmic Multiplier (hybrid Booth + Baugh-Wooley)
- Fully Pipelined Algorithmic Multiplier (optimized with CLA)

## Problem Statement

**Domain:** Electronics  
**Goal:** To design and optimize a high-speed, resource-efficient hardware accelerator that performs quaternion multiplication for applications like sensor fusion, 3D orientation tracking, and robotics.

## Project Features

- Hybrid multiplier usage: Booth for cross terms, Baugh-Wooley for diagonal terms.
- Includes custom CLA, RCA, and pipelined adder trees.
- Real-time integration with **MPU6050** IMU via Arduino and UART.
- Supports both combinational and pipelined computation paths.

- 
## External Resources

https://share.google/vLRxOtKJnZ5gnRpvB
https://share.google/mTRVE3X9I1PaTySKQ
https://share.google/U68MjuvapWPtFbpu9
https://share.google/SIA1VyrFZaAz3vVPz
https://share.google/DvmhEwlhn4XL35j5F


## Tools Used

- Xilinx Vivado (Simulation & Synthesis)
- Modelsim and Quartus (for testing)
- Arduino IDE (IMU Communication)
- Overleaf (Report Documentation)
- Git & GitHub (Version Control)


