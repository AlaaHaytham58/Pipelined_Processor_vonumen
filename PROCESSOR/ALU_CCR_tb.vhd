LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY alu_ccr_tb IS
END alu_ccr_tb;

ARCHITECTURE tb OF alu_ccr_tb IS

    -- Clock
    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';

    -- ALU signals
    signal op1, op2   : std_logic_vector(31 downto 0);
    signal alu_op     : std_logic_vector(2 downto 0);
    signal alu_out    : std_logic_vector(31 downto 0);

    -- CCR signals
    signal ccr_in, ccr_out : std_logic_vector(2 downto 0);
    signal ccr_en          : std_logic;

    -- CCR Reserved signals
    signal ccr_reserved    : std_logic_vector(2 downto 0);
    signal int_jump_sel    : std_logic;
    signal flags_saved     : std_logic;

    constant CLK_PERIOD : time := 10 ns;

BEGIN

    ------------------------------------------------------------------
    -- CLOCK
    ------------------------------------------------------------------
    clk <= not clk after CLK_PERIOD/2;

    ------------------------------------------------------------------
    -- ALU
    ------------------------------------------------------------------
    ALU_UUT : entity work.ALU
        port map (
            op1     => op1,
            op2     => op2,
            alu_op  => alu_op,
            ccr_in  => ccr_out,
            alu_out => alu_out,
            ccr_out => ccr_in
        );

    ------------------------------------------------------------------
    -- CCR REGISTER
    ------------------------------------------------------------------
    CCR_REG_UUT : entity work.CCR_Reg
        port map (
            clk     => clk,
            reset   => reset,
            CCR_En  => ccr_en,
            CCR_IN  => ccr_in,
            CCR_OUT => ccr_out
        );

    ------------------------------------------------------------------
    -- CCR RESERVED
    ------------------------------------------------------------------
    CCR_RESERVED_UUT : entity work.CCR_Reserved
        port map (
            clk           => clk,
            reset         => reset,
            Int_Jump_Sel  => int_jump_sel,
            ccr_in        => ccr_out,
            ccr_reserved  => ccr_reserved,
            flags_saved   => flags_saved
        );

    ------------------------------------------------------------------
    -- TEST SEQUENCE
    ------------------------------------------------------------------
   stimulus : process
begin
    ------------------------------------------------------------------
    -- RESET
    ------------------------------------------------------------------
    reset <= '1';
    ccr_en <= '0';
    int_jump_sel <= '0';
    wait for CLK_PERIOD * 2;
    reset <= '0';

    ------------------------------------------------------------------
    -- TEST 1: ZERO FLAG (ADD 0 + 0)
    ------------------------------------------------------------------
    op1 <= x"00000000";
    op2 <= x"00000000";
    alu_op <= "001"; -- ADD
    ccr_en <= '1';

    wait for CLK_PERIOD;

    assert alu_out = x"00000000"
        report "ADD 0+0 failed" severity error;

    assert ccr_out = "001"
        report "ZERO flag test failed (expected Z=1)" severity error;

    ------------------------------------------------------------------
    -- TEST 2: NEGATIVE FLAG (NOT 0x7FFFFFFF)
    ------------------------------------------------------------------
    op1 <= x"7FFFFFFF";
    op2 <= x"00000000";
    alu_op <= "100"; -- NOT

    wait for CLK_PERIOD;

    assert alu_out = x"80000000"
        report "NOT operation failed" severity error;

    assert ccr_out = "010"
        report "NEGATIVE flag test failed (expected N=1)" severity error;

    ------------------------------------------------------------------
    -- TEST 3: CARRY FLAG (INC 0xFFFFFFFF)
    ------------------------------------------------------------------
    op1 <= x"FFFFFFFF";
    op2 <= x"00000000";
    alu_op <= "110"; -- INC

    wait for CLK_PERIOD;

    assert alu_out = x"00000000"
        report "INC overflow failed" severity error;

    assert ccr_out = "101"
        report "CARRY flag test failed (expected C=1, Z=1)" severity error;

    ------------------------------------------------------------------
    -- TEST 4: CCR HOLD (NOP)
    ------------------------------------------------------------------
    alu_op <= "000"; -- NOP
    op1 <= x"12345678";
    ccr_en <= '0';   -- Disable CCR update

    wait for CLK_PERIOD;

    assert ccr_out = "101"
        report "CCR changed during NOP (should hold)" severity error;

    ------------------------------------------------------------------
    -- TEST 5: SETC (force Carry = 1)
    ------------------------------------------------------------------
    ccr_en <= '1';
    alu_op <= "111"; -- SETC

    wait for CLK_PERIOD;

    assert ccr_out(2) = '1'
        report "SETC failed (Carry not set)" severity error;

    ------------------------------------------------------------------
    -- TEST 6: SAVE CCR INTO CCR_RESERVED
    ------------------------------------------------------------------
    int_jump_sel <= '1';
    wait for CLK_PERIOD;

    assert flags_saved = '1'
        report "CCR_Reserved did not save flags" severity error;

    assert ccr_reserved = ccr_out
        report "CCR_Reserved value incorrect" severity error;

    ------------------------------------------------------------------
    -- TEST 7: CLEAR SAVED FLAG
    ------------------------------------------------------------------
    int_jump_sel <= '0';
    wait for CLK_PERIOD;

    assert flags_saved = '0'
        report "flags_saved not cleared after interrupt" severity error;

    ------------------------------------------------------------------
    -- DONE
    ------------------------------------------------------------------
    report "ALL ALU / CCR / CCR_RESERVED FLAG TESTS PASSED";
    wait;
end process;


END tb;
