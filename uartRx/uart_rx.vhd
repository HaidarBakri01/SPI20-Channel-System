library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx is
    port (
        clk        : in  std_logic; -- 50 MHz
        rx_serial  : in  std_logic;
        rx_byte    : out std_logic_vector(7 downto 0);
        rx_done    : out std_logic
    );
end uart_rx;

architecture rtl of uart_rx is
    -- 50MHz / 115200 baud = 434 clock cycles per bit
    constant BIT_PERIOD : integer := 434;
    type state_type is (IDLE, START_BIT, DATA_BITS, STOP_BIT, DONE);
    signal state : state_type := IDLE;
    signal timer : integer range 0 to BIT_PERIOD := 0;
    signal bit_idx : integer range 0 to 7 := 0;
    signal shift_reg : std_logic_vector(7 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            case state is
                when IDLE =>
                    rx_done <= '0';
                    if rx_serial = '0' then -- Start bit detected
                        timer <= 0;
                        state <= START_BIT;
                    end if;

                when START_BIT =>
                    if timer = BIT_PERIOD / 2 then -- Sample in middle
                        state <= DATA_BITS;
                        timer <= 0;
                        bit_idx <= 0;
                    else
                        timer <= timer + 1;
                    end if;

                when DATA_BITS =>
                    if timer = BIT_PERIOD then
                        shift_reg(bit_idx) <= rx_serial;
                        timer <= 0;
                        if bit_idx = 7 then
                            state <= STOP_BIT;
                        else
                            bit_idx <= bit_idx + 1;
                        end if;
                    else
                        timer <= timer + 1;
                    end if;

                when STOP_BIT =>
                    if timer = BIT_PERIOD then
                        rx_byte <= shift_reg;
                        rx_done <= '1';
                        state <= DONE;
                    else
                        timer <= timer + 1;
                    end if;

                when DONE =>
                    state <= IDLE;
                    rx_done <= '0';
            end case;
        end if;
    end process;
end rtl;