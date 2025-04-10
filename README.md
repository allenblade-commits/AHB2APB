# 🧩 AMBA AHB to APB Bridge – Verilog Implementation

This project implements an **AMBA AHB (Advanced High-performance Bus)** to **APB (Advanced Peripheral Bus)** bridge in Verilog. The design facilitates communication between high-speed components on the AHB and low-speed peripherals on the APB.

---

## 📌 Table of Contents

- [Overview](#overview)
- [File Descriptions](#file-descriptions)
- [Design Features](#design-features)
- [Simulation Instructions](#simulation-instructions)
- [Waveform Viewing](#waveform-viewing)
- [Directory Structure](#directory-structure)
- [Requirements](#requirements)
- [References](#references)
- [Author](#author)

---

## 🧠 Overview

This AMBA bridge design enables high-speed AHB masters to communicate with low-speed APB peripherals by converting AHB protocol signals to APB format. It's ideal for SoC designs where performance and power efficiency are balanced through protocol segmentation.

---

## 📂 File Descriptions

| File Name               | Description |
|-------------------------|-------------|
| `ahb_master.v`          | AHB master module that initiates read/write transactions. |
| `ahb_slave_interface.v` | Receives transactions from the AHB master and converts them for bridge use. |
| `apb_controller.v`      | Core APB controller handling signal transitions and control logic. |
| `apb_interface.v`       | Generates APB protocol signals and drives data to APB peripherals. |
| `bridge_top.v`          | Top-level integration module connecting AHB and APB logic. |
| `top_tb.v`              | Testbench simulating full end-to-end operation of the bridge. |

---

## ✨ Design Features

- ✅ Fully supports AMBA AHB and APB protocols.
- ✅ Modular structure for clarity and reusability.
- ✅ Handles single-cycle read/write transactions.
- ✅ Easy to extend for burst or multi-cycle transfers.
- ✅ Includes simulation testbench with waveform support.

---

## 🧪 Simulation Instructions

### Using Icarus Verilog (Open Source)

1. **Compile the design and testbench:**

```bash
iverilog -o bridge_sim top_tb.v bridge_top.v apb_interface.v apb_controller.v ahb_slave_interface.v ahb_master.v
