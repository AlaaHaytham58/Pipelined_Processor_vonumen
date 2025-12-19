-- STACK.vhd (32-bit version)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity STACK is
    Port ( 
        clk         : in  std_logic;
        reset       : in  std_logic;
        SP_enable   : in  std_logic;
        SP_INC      : in  std_logic;  
        SP_out      : out std_logic_vector(31 downto 0)  
    );
end STACK;

architecture ARCH_SP of STACK is
    constant SP_INITIAL : std_logic_vector(31 downto 0) := x"000003FF";  
    signal SP_reg  : std_logic_vector(31 downto 0) := SP_INITIAL;
    signal SP_next : std_logic_vector(31 downto 0);
    
begin
    process(SP_reg, SP_enable, SP_INC)
    begin
            if SP_INC = '1' then
                -- Increment by 4 (word addressing)
                SP_next <= std_logic_vector(unsigned(SP_reg) + 1);
            elsif SP_INC = '0' then
                -- Decrement by 4 (word addressing)
                SP_next <= std_logic_vector(unsigned(SP_reg) - 1);
            end if;
    end process;

    process(clk, reset)
    begin
        if reset = '1' then
            SP_reg <= SP_INITIAL;
        elsif rising_edge(clk) then
            if SP_enable = '1' then
                SP_reg <= SP_next;
            end if;
        end if;
    end process;

    SP_out <= SP_reg;

end ARCH_SP;