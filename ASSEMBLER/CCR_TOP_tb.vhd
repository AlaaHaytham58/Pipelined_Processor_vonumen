library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CCR_Top_tb is
end entity;

architecture TB of CCR_Top_tb is

    signal clk         : std_logic := '0';
    signal reset       : std_logic := '0';
    signal write_en    : std_logic := '0';
    signal save_ccr    : std_logic := '0';
    signal RTI         : std_logic := '0';
    signal alu_ccr     : std_logic_vector(2 downto 0) := (others => '0');
    signal ccr_out     : std_logic_vector(2 downto 0);
    signal ccr_reserved : std_logic_vector(2 downto 0);
    signal flags_saved : std_logic;

    constant CLK_PERIOD : time := 10 ns;

begin

    ------------------------------------------------------------------
    -- DUT
    ------------------------------------------------------------------
    DUT : entity work.CCR_Top
    port map (
        clk          => clk,
        reset        => reset,
        write_en     => write_en,
        save_ccr     => save_ccr,
        RTI          => RTI,
        alu_ccr      => alu_ccr,
        ccr_out      => ccr_out,
        ccr_reserved => ccr_reserved,
        flags_saved  => flags_saved
    );


    ------------------------------------------------------------------
    -- Clock Generator
    ------------------------------------------------------------------
    clk <= not clk after CLK_PERIOD / 2;

    ------------------------------------------------------------------
    -- Stimulus + Assertions
    ------------------------------------------------------------------
    stim_proc : process
    begin

        ------------------------------------------------------------------
        -- TEST 1: Reset behavior
        ------------------------------------------------------------------
        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';
        wait for CLK_PERIOD;

        assert ccr_out = "000"
            report "TEST 1 FAILED: CCR not cleared on reset"
            severity error;

        assert flags_saved = '0'
            report "TEST 1 FAILED: flags_saved not cleared on reset"
            severity error;

        ------------------------------------------------------------------
        -- TEST 2: Normal ALU write
        ------------------------------------------------------------------
        alu_ccr  <= "101";
        write_en <= '1';
        wait for CLK_PERIOD;
        write_en <= '0';
        wait for CLK_PERIOD;

        assert ccr_out = "101"
            report "TEST 2 FAILED: CCR not updated from ALU"
            severity error;

        ------------------------------------------------------------------
        -- TEST 3: Save CCR on interrupt
        ------------------------------------------------------------------
        save_ccr <= '1';
        wait for CLK_PERIOD;
        save_ccr <= '0';
        wait for CLK_PERIOD;

        assert flags_saved = '1'
            report "TEST 3 FAILED: flags_saved not asserted after save"
            severity error;

        assert ccr_reserved = "101"
            report "TEST 3 FAILED: CCR not saved correctly"
            severity error;


        ------------------------------------------------------------------
        -- TEST 4: Modify CCR during ISR
        ------------------------------------------------------------------
        alu_ccr  <= "010";
        write_en <= '1';
        wait for CLK_PERIOD;
        write_en <= '0';
        wait for CLK_PERIOD;

        assert ccr_out = "010"
            report "TEST 4 FAILED: CCR not updated during ISR"
            severity error;

        ------------------------------------------------------------------
        -- TEST 5: RTI restores saved CCR
        ------------------------------------------------------------------
        RTI      <= '1';
        write_en <= '1';
        wait for CLK_PERIOD;
        RTI      <= '0';
        write_en <= '0';
        wait for CLK_PERIOD;

        assert ccr_out = "101"
            report "TEST 5 FAILED: CCR not restored on RTI"
            severity error;

        assert ccr_reserved = "101"
            report "TEST 5 FAILED: Reserved CCR corrupted after RTI"
            severity error;


        ------------------------------------------------------------------
        -- TEST 6: flags_saved cleared after RTI
        ------------------------------------------------------------------
        assert flags_saved = '0'
            report "TEST 6 FAILED: flags_saved not cleared after RTI"
            severity error;

        ------------------------------------------------------------------
        -- END OF TEST
        ------------------------------------------------------------------
        assert false
            report "ALL CCR TESTS PASSED SUCCESSFULLY"
            severity failure;

    end process;

end architecture;
