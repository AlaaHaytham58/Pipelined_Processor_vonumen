library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CCR_Top is
    port (
        clk          : in  std_logic;
        reset        : in  std_logic;
        ccr_en       : in  std_logic;
        int_j        : in  std_logic;
        RTI          : in  std_logic;
        alu_ccr      : in  std_logic_vector(2 downto 0);
        ccr_update   : in  std_logic_vector(2 downto 0);  -- Flags of z,c,n to
        ccr_out      : out std_logic_vector(2 downto 0)
    );
end entity;


architecture Structural of CCR_Top is

    signal ccr_next      : std_logic_vector(2 downto 0);
    signal ccr_current   : std_logic_vector(2 downto 0);
    signal ccr_saved     : std_logic_vector(2 downto 0);

begin

    ------------------------------------------------------------------
    -- CCR input MUX
    -- RTI restores saved CCR, otherwise ALU writes
    ------------------------------------------------------------------
    ccr_next <= ccr_saved when RTI = '1'
                else alu_ccr;

    ------------------------------------------------------------------
    -- Main CCR Register
    ------------------------------------------------------------------
    CCR_MAIN : entity work.CCR_Reg
        port map (
            clk      => clk,
            reset    => reset,
            write_en => ccr_en,
            ccr_update => ccr_update,
            ccr_next => ccr_next,
            ccr_out  => ccr_current
        );

    ------------------------------------------------------------------
    -- Reserved CCR Register
    ------------------------------------------------------------------
    CCR_SAVE : entity work.CCR_Reserved
        port map (
            clk          => clk,
            reset        => reset,
            save_ccr     => int_j,
            ccr_in       => ccr_current,
            ccr_reserved => ccr_saved
        );
    
    ccr_out <= ccr_current;

end architecture;
