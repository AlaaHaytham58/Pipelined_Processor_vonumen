library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CCR_Reg is
    port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        write_en  : in  std_logic;
        ccr_next  : in  std_logic_vector(2 downto 0);
        ccr_update: in  std_logic_vector(2 downto 0);
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
                if (ccr_update(0) = '1') then 
                    ccr_reg(0) <= ccr_next(0);
                end if;

                if (ccr_update(1) = '1') then 
                    ccr_reg(1) <= ccr_next(1);
                end if;

                if (ccr_update(2) = '1') then 
                    ccr_reg(2) <= ccr_next(2);
                end if;
            end if;
        end if;
    end process;

    CCR_OUT <= ccr_reg;
end architecture;
