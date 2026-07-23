APB Master design using Verilog

This project implements an **AMBA Advanced Peripheral Bus (APB) Master** in Verilog. The APB Master initiates read and write transactions to APB slave peripherals by following the APB protocol timing defined by ARM. 
The design includes a finite state machine (FSM) that controls the bus signals during setup and access phases, ensuring reliable communication with APB-compliant peripherals.

 Features

1. APB read and write transaction support
2. Finite State Machine (FSM) based controller
3. APB protocol compliant signal sequencing
4. Supports wait-state handling using the `PREADY` signal
5. Active-low reset (`PRESETn`)
