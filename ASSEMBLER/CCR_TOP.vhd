library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CCR_Top is
    port (
        clk          : in  std_logic;
        reset        : in  std_logic;
        write_en     : in  std_logic;
        save_ccr     : in  std_logic;
        RTI          : in  std_logic;
        alu_ccr      : in  std_logic_vector(2 downto 0);

        ccr_out      : out std_logic_vector(2 downto 0);
        ccr_reserved : out std_logic_vector(2 downto 0); -- 👈 expose
        flags_saved  : out std_logic
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
            write_en => write_en,
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
            save_ccr     => save_ccr,
            RTI          => RTI,
            ccr_in       => ccr_current,
            ccr_reserved => ccr_saved,
            flags_saved  => flags_saved
        );
    
    ccr_reserved <= ccr_saved;
    ccr_out <= ccr_current;

end architecture;
