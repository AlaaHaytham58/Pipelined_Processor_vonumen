library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CCR_Reg is
    port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        write_en  : in  std_logic;
        ccr_next  : in  std_logic_vector(2 downto 0);
        ccr_out   : out std_logic_vector(2 downto 0)
    );
end entity;

architecture RTL of CCR_Reg is
    signal ccr_reg : std_logic_vector(2 downto 0);
begin
    process(clk, reset)
    begin
        if reset = '1' then
            ccr_reg <= (others => '0');
        elsif rising_edge(clk) then
            if write_en = '1' then
                ccr_reg <= ccr_next;     -- from ALU or RTI mux
            end if;
        end if;
    end process;

    ccr_out <= ccr_reg;
end architecture;
