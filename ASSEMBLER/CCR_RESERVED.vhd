library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CCR_Reserved is
    port (
        clk           : in  std_logic;
        reset         : in  std_logic;
        
        -- Control signals
        save_ccr      : in  std_logic;  -- Save CCR on interrupt
        
        -- Data signals
        ccr_in        : in  std_logic_vector(2 downto 0);  -- Current CCR flags
        ccr_reserved  : out std_logic_vector(2 downto 0)  -- Saved CCR flags
    );
end entity;

architecture RTL of CCR_Reserved is
    signal reserved_reg : std_logic_vector(2 downto 0);
begin

    process(clk, reset)
    begin
        if reset = '1' then
            reserved_reg <= (others => '0');
        elsif rising_edge(clk) then
            -- Save CCR on interrupt
            if save_ccr = '1' then
                reserved_reg <= ccr_in;
            end if;
        end if;
    end process;

    ccr_reserved <= reserved_reg;

end architecture;