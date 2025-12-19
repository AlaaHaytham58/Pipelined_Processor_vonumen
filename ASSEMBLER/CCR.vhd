library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CCR_Reg is
    port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        CCR_En  : in  std_logic;
        CCR_IN  : in  std_logic_vector(2 downto 0);
        CCR_OUT   : out std_logic_vector(2 downto 0)
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
            if CCR_En = '1' then
                ccr_reg <= CCR_IN;     -- from ALU or RTI mux
            end if;
        end if;
    end process;

    CCR_OUT <= ccr_reg;
end architecture;
