library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity STACK is
    Port ( 
        clk         : in  std_logic;
        reset_n         : in  std_logic;
        SP_enable   : in  std_logic;
        SP_INC      : in  std_logic;  
        SP_DEC      : in  std_logic;  
        SP_mem      : in  std_logic_vector(11 downto 0);  
        SP_out      : out std_logic_vector(11 downto 0)  
    );
end STACK;

architecture ARCH_SP of STACK is
    signal SP_reg  : std_logic_vector(11 downto 0) := (others => '1'); 
    signal SP_next : std_logic_vector(11 downto 0);
begin

    process(SP_reg, SP_enable, SP_INC, SP_DEC, SP_mem)
    begin
        if SP_enable = '1' then
            if SP_INC = '1' and SP_reg /= "111111111111" then
                SP_next <= std_logic_vector(unsigned(SP_reg) + 1);
            elsif SP_DEC = '1' and SP_reg /= "000000000000" then
                SP_next <= std_logic_vector(unsigned(SP_reg) - 1); 
            else
                SP_next <= SP_reg; 
            end if;
        else
            SP_next <= SP_reg; --hold stack
        end if;
    end process;

    process(clk, reset_n)
    begin
        if reset_n = '1' then
            SP_reg <= (others => '1');
        elsif rising_edge(clk) then
            SP_reg <= SP_next;
        end if;
    end process;

    SP_out <= SP_reg;

end ARCH_SP;
