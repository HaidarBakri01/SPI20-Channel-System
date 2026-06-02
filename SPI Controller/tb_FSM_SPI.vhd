library ieee;
use ieee.std_logic_1164.all;

entity tb_FSM_SPI is
end tb_FSM_SPI;

architecture tb of tb_FSM_SPI is

    component FSM_SPI
        port (clk            : in std_logic;
              reset          : in std_logic;
              start_tx       : in std_logic;
              bit_count_done : in std_logic;
              CS_n           : out std_logic;
              shift_enable   : out std_logic;
              count_enable   : out std_logic;
              SCLK_enable    : out std_logic;
              data_ready     : out std_logic);
    end component;

    signal clk            : std_logic;
    signal reset          : std_logic;
    signal start_tx       : std_logic;
    signal bit_count_done : std_logic;
    signal CS_n           : std_logic;
    signal shift_enable   : std_logic;
    signal count_enable   : std_logic;
    signal SCLK_enable    : std_logic;
    signal data_ready     : std_logic;

    constant TbPeriod : time := 20 ns; -- T = 1/f ==> 1/50MHz ~= 20ns 
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : FSM_SPI
    port map (clk            => clk,
              reset          => reset,
              start_tx       => start_tx,
              bit_count_done => bit_count_done,
              CS_n           => CS_n,
              shift_enable   => shift_enable,
              count_enable   => count_enable,
              SCLK_enable    => SCLK_enable,
              data_ready     => data_ready);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- ***EDIT*** Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- ***EDIT*** Adapt initialization as needed
        start_tx <= '0';
        bit_count_done <= '0';

        -- Reset generation
        -- ***EDIT*** Check that reset is really your reset signal
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 100 ns;

        -- ***EDIT*** Add stimuli here
        wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_FSM_SPI of tb_FSM_SPI is
    for tb
    end for;
end cfg_tb_FSM_SPI;