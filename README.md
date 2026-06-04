# 20-Channel High-Throughput Parallel SPI System

A resource-optimized, fully parallel multi-channel SPI controller core designed in VHDL and targeted for the **Intel/Altera DE0-Nano (Cyclone IV FPGA)**. This architecture is engineered to interface with up to 20 independent peripheral interfaces simultaneously, completely eliminating the sequential polling latency and timing overhead inherent in traditional microcontroller architectures.


## 🛠️ System Architecture & Engineering Principles

The entire system is designed around a unified master clock domain to ensure strict deterministic timing and zero clock-skew across channels. The hierarchy is scaled dynamically utilizing VHDL `generate` blocks.

               +-------------------------------------------------+
               |             SPI20_channel_system                |
               +-------------------------------------------------+
                                       |
                   +-------------------+-------------------+
                   | (VHDL Generate Statement x20)         |
                   v                                       v
        +-----------------------+               +-----------------------+
        |   spi_master_core (0) |               |  spi_master_core (19) |
        +-----------------------+               +-----------------------+
          |    |    |    |                        |    |    |    |
          |    |    |    +--> FSM_SPI             |    |    |    +--> FSM_SPI
          |    |    +-------> clk_generation      |    |    +-------> clk_generation
          |    +------------> SPI_ShiftRegister   |    +------------> SPI_ShiftRegister
          +-----------------> SPI_BitCounter      +-----------------> SPI_BitCounter

📦 Core Submodule Breakdown

    FSM_SPI
        ●   A glitch-free, 4-state Mealy/Moore hybrid Finite State Machine implementing rigorous state transition rules to safely assert control flags (CS_n, shift_enable, count_enable). Contains explicit fallback states to handle physical single-event upsets (SEU).

    clk_generation
        ●   A multi-channel clock prescaler that outputs a gated SCLK line (configured for SPI Mode 0, CPOL=0/CPHA=0). Critically, it distributes a single-cycle system clock synchronous pulse (SCLK_strobe) downstream instead of using divided clocks directly as toggled routing clocks, preserving global low-skew routing resources.

    SPI_ShiftRegister
        ●    An 8-bit bidirectional shift register running left-to-right (MSB first). Captures incoming slave data (MISO) synchronously at the system clock boundary using custom pipeline-delay edge trackers.

    SPI_BitCounter
        ●    A robust frame-boundary supervisor that tracks bit transitions to enforce accurate 8-bit packaging limits, asserting frame completion flags directly to the controller FSM.


🔍 RTL Synthesis & Hardware Mapping

    The system design was synthesized and mapped using the Altera Cyclone IV E technology library inside Quartus Prime. The following schematics illustrate how VHDL code translates to silicon-level routing structures.

    1. Fully Parallel Top-Level Bus Architecture
        Below is the synthesized RTL representation of the 20 distinct SPI master instances scaling concurrently. Notice how every master block works in parallel under a single shared clock domain to prevent timing conflicts.

    2. Inner-Core Modular Layout
        Each master channel is isolated structurally to preserve signal integrity and modularity. This structural representation highlights the individual master block instantiation:   

images/rtl_master_core_detail.png

    3. Submodule Interconnect Topology
        This view shows the physical hardware connections between the FSM, Bit Counter, Shift Register, and Clock Prescaler within each channel. This interconnect network guarantees zero-latency internal communication:

images/modelsim_simulation.png

    -----
c:\Users\Haidar\Documents\SPI-Implementation\images\rtl_master_connections.png
images/rtl_parallel_system.png


📊 Behavioral Simulation & Verification

    To validate multi-channel synchronization, loopback stability, and phase-lock accuracy, a structural testbench was executed in ModelSim.

images/modelsim_waveform.png


    Waveform Analysis & Timing Milestones:
    1. Synchronous Initialization & Reset:
        On the assertion of reset, all FSM states drop to IDLE within a single system clock cycle. SPI line output levels are cleanly initialized (CS_n = '1', SCLK = '0', MOSI = '0'), matching SPI Mode 0 ($CPOL=0$).
    2. Single-Cycle Parallel Launch:
        As start_tx transitions active-low, all 20 SPI master channels trigger in perfect lockstep on the exact same rising edge of the high-speed system clock. CS_n transitions to active-low ('0') synchronously, securing bus dominance for the transmission frame.
    3. Gated Clock Sync & Strobe Propagation:
        Instead of passing a divided clock over global signal lines, the prescaler asserts SCLK_strobe as a single system-clock-width pulse synchronized exactly to the rising edge of SCLK. This technique ensures clean, glitch-free synchronous shifts and bit-counting without propagation delays or metastability.
    4. Bidirectional Serialization & Read Validation:
        The ShiftRegister shifts bits out sequentially via MOSI (MSB-first) on the falling edge of SCLK, while sampling incoming MISO data on the rising edge of SCLK. Upon shifting the 8th bit, the BitCounter flags the transaction complete, transitioning the FSM to DONE and asserting data_ready to indicate parallel data is stable and valid for the FPGA fabric.

⚡ Specifications & Real-Time Performance
        ●   Target Board: Intel/Altera DE0-Nano (EP4CE22F17C6N Cyclone IV E)
        ●   System Input Clock: 50 MHz onboard crystal oscillator fsys
        ●   SPI Protocol Config: Mode 0 (CPOL = 0, CPHA = 0)
        ●   Throughput Metric: Generates a 160-bit parallel datapath instantly accessible within a single system execution period.

Configurable Clock Divider Rule:

                                             f_SCLK = fsys / (2 * divide_value) 

                                            | Parameter            | Value         |
                                            | -------------------- | ------------- |
                                            | FPGA Board           | DE0-Nano      |
                                            | FPGA Device          | EP4CE22F17C6N |
                                            | System Clock         | 50 MHz        |
                                            | SPI Mode             | Mode 0        |
                                            | Channels             | 20            |
                                            | Data Width           | 8-bit         |
                                            | Total Parallel Width | 160-bit       |



🚀 Repository Roadmap

        ●   Phase 1: Modular RTL Architecture
               Complete full sub-block descriptions in standard VHDL, maintaining strict synthesis boundaries and synchronous design boundaries.
        ●   Phase 2: Simulation & Waveform Verification
               Validated overall continuous loopback functionality using structural testbenches in ModelSim. Verified timing closure and strobe alignment across parallel blocks.
        ●   Phase 3: RTL Synthesis & Hierarchy Mapping
                Compiled design hierarchy seamlessly using Quartus Prime targeting Cyclone IV hardware nodes.
        ●   Phase 4: Physical Hardware Validation
                Next step involves physical board placement, I/O pin mapping to GPIO expansion headers, and hardware-in-the-loop (HIL) testing.

💻 Toolchain & Engineering Suite

    ●   Synthesis Engine: Quartus Prime (Lite Edition)
    ●   Simulation Environment: ModelSim - Intel FPGA Edition
    ●   Language Standard: VHDL-93 / VHDL-2008