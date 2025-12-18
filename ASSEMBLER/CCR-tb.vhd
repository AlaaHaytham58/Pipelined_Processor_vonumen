library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CCR_Reg_TB is
end;

architecture TB of CCR_Reg_TB is
    signal clk      : std_logic := '0';
    signal reset    : std_logic := '0';
    signal write_en : std_logic;
    signal ccr_next : std_logic_vector(2 downto 0);
    signal ccr_out  : std_logic_vector(2 downto 0);
begin

    clk <= not clk after 5 ns;

    DUT: entity work.CCR_Reg
        port map (
            clk      => clk,
            reset    => reset,
            write_en => write_en,
            ccr_next => ccr_next,
            ccr_out  => ccr_out
        );

    process
    begin
        -- Reset
        reset <= '1';
        wait for 10 ns;
        reset <= '0';

        -- Write flags
        write_en <= '1';
        ccr_next <= "101";
        wait for 10 ns;

        assert ccr_out = "101"
            report "CCR write failed" severity error;

        -- Hold
        write_en <= '0';
        ccr_next <= "010";
        wait for 10 ns;

        assert ccr_out = "101"
            report "CCR hold failed" severity error;

        report "CCR REGISTER TEST PASSED" severity note;
        wait;
    end process;
end architecture;
