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
        --SP_DEC      : in  std_logic;  only sp_inc needed
        SP_mem      : in  std_logic_vector(31 downto 0); --direct load
        SP_out      : out std_logic_vector(31 downto 0)  
    );
end STACK;

architecture ARCH_SP of STACK is
    constant SP_INITIAL : std_logic_vector(31 downto 0) := x"000FFFFC";  
    signal SP_reg  : std_logic_vector(31 downto 0) := SP_INITIAL;
    signal SP_next : std_logic_vector(31 downto 0);
    
begin
    process(SP_reg, SP_enable, SP_INC, SP_mem)
    begin
        if SP_enable = '1' then
            if SP_INC = '1' then
                -- Increment by 4 (word addressing)
                SP_next <= std_logic_vector(unsigned(SP_reg) + 4);
            elsif SP_INC = '0' then
                -- Decrement by 4 (word addressing)
                SP_next <= std_logic_vector(unsigned(SP_reg) - 4);
            else
                -- Direct load or hold
                SP_next <= SP_mem;
            end if;
        else
            SP_next <= SP_reg;
        end if;
    end process;

    process(clk, reset)
    begin
        if reset = '1' then
            SP_reg <= SP_INITIAL;
        elsif rising_edge(clk) then
            SP_reg <= SP_next;
        end if;
    end process;

    SP_out <= SP_reg;

end ARCH_SP;