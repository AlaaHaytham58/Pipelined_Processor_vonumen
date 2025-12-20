library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity CCR_Reserved is
    port (
        clk           : in  std_logic;
        reset         : in  std_logic;

        -- Control signals
        save_ccr      : in  std_logic;  -- Save CCR on interrupt
        Int_Jump_Sel           : in  std_logic;  -- ENABLE signal for interrupt jump

        -- Data signals
        ccr_in        : in  std_logic_vector(2 downto 0);  -- Current CCR flags
        ccr_reserved  : out std_logic_vector(2 downto 0) ; -- Saved CCR flags

        -- Status
        flags_saved   : out std_logic   -- Indicates if flags are currently saved
    );
end entity;

architecture RTL of CCR_Reserved is
    signal reserved_reg : std_logic_vector(2 downto 0);
begin

    process(clk, reset)
    begin
        if reset = '1' then
            reserved_reg <= (others => '0');
            saved_flag <= '0';

        elsif rising_edge(clk) then
            -- Save CCR on interrupt
            if Int_Jump_Sel = '1' then
                reserved_reg <= ccr_in;
                saved_flag <= '1';
            
            -- Clear saved flag on restore (RTI)
            elsif RTI = '1' then
                saved_flag <= '0';
                -- Keep reserved_reg value until next save
            end if;
        end if;
    end process;

    ccr_reserved <= reserved_reg;

end architecture;