# ROIC Digital Block - Verilog HDL

## 📌 Overview
This repository contains the Verilog HDL implementation of the digital block of a Read-Out Integrated Circuit (ROIC).
The design features an FSM-based pixel scanner that sequentially reads pixel data from the sensor array for further processing.

## 🛠 Features
- FSM-based pixel scanning logic
- Parameterized design for flexibility
- Testbench for functional verification
- Compatible with ModelSim, Vivado, and other Verilog simulators

## 📂 Project Structure
- `src/` → Verilog source files
- `testbench/` → Testbench files
- `docs/` → Documentation, simulation screenshots, diagrams

## 🖼 Block Diagram
![Block Diagram](docs/block_diagram.png)

## 🚀 Simulation Results
![Simulation Screenshot](docs/simulation_results.png)

## ⚙️ Tools Used
- ModelSim for simulation
- Vivado for synthesis
- GTKWave for waveform analysis

## ▶️ How to Run
1. Open ModelSim or Vivado simulator.
2. Compile the files in `src/` and `testbench/`.
3. Run the testbench and view the waveform output.
4. Use GTKWave or built-in tools to analyze the signals.

## 👨‍💻 Author
Shivam Mandal

## 📜 License
This project is licensed under the MIT License.
