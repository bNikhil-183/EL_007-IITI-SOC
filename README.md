# EL_007: Hardware Accelerator for Quaternion Multiplication

## Overview

This repository contains the complete Verilog HDL implementation and system integration of a **hardware accelerator for quaternion multiplication**, developed as part of the IITI Summer of Code (SoC) program by Team EL_007.
## Team Members

**Team Name:** EL\_007  
- Bhasuru Nikhil  
- Nainsi Kushwaha  
- Shakkar Ridhi  

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




## Tools Used

- Xilinx Vivado (Simulation & Synthesis)
- Modelsim and Quartus (for testing)
- Arduino IDE (IMU Communication)
- Overleaf (Report Documentation)
- Git & GitHub (Version Control)


