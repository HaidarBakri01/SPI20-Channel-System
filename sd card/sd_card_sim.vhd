library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sd_card_sim is
    port (
        sclk : in  std_logic;
        mosi : in  std_logic;
        miso : out std_logic := '0'
    );
end entity;

architecture behavior of sd_card_sim is
    -- The SD card will send this back to the FPGA
    signal fake_storage : std_logic_vector(15 downto 0) := x"A5A5"; 
    signal bit_index    : integer range 0 to 15 := 0;
begin
    -- Important: sclk must be in the sensitivity list
    process(sclk)
    begin
        if falling_edge(sclk) then
            -- Drive the MISO line with the current bit
            miso <= fake_storage(15 - bit_index);
            
            -- Increment index
            if bit_index = 15 then
                bit_index <= 0;
            else
                bit_index <= bit_index + 1;
            end if;
        end if;
    end process;
end architecture;