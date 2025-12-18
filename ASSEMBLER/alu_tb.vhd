library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU_TB is
end ALU_TB;

architecture TB of ALU_TB is

    -- DUT signals
    signal op1     : STD_LOGIC_VECTOR(31 downto 0);
    signal op2     : STD_LOGIC_VECTOR(31 downto 0);
    signal alu_op  : STD_LOGIC_VECTOR(2 downto 0);
    signal ccr_in  : STD_LOGIC_VECTOR(2 downto 0);

    signal alu_out : STD_LOGIC_VECTOR(31 downto 0);
    signal ccr_out : STD_LOGIC_VECTOR(2 downto 0);

begin

    -- Instantiate ALU
    DUT : entity work.ALU
        port map (
            op1     => op1,
            op2     => op2,
            alu_op  => alu_op,
            ccr_in  => ccr_in,
            alu_out => alu_out,
            ccr_out => ccr_out
        );

    -- Test process
    process
    begin
        -----------------------------------------
        -- INIT
        -----------------------------------------
        ccr_in <= "000";
        op1 <= (others => '0');
        op2 <= (others => '0');
        alu_op <= "000";
        wait for 10 ns;

        -----------------------------------------
        -- ADD
        -----------------------------------------
        op1 <= x"00000005";
        op2 <= x"00000003";
        alu_op <= "001"; -- ADD
        wait for 10 ns;

        assert alu_out = x"00000008"
            report "ADD failed" severity error;
        assert ccr_out = "000"
            report "ADD CCR wrong" severity error;

        -----------------------------------------
        -- ADD with carry
        -----------------------------------------
        op1 <= x"FFFFFFFF";
        op2 <= x"00000001";
        alu_op <= "001";
        wait for 10 ns;

        assert alu_out = x"00000000"
            report "ADD carry failed" severity error;
        assert ccr_out(2) = '1' and ccr_out(0) = '1'
            report "ADD carry flags wrong" severity error;

        -----------------------------------------
        -- SUB
        -----------------------------------------
        op1 <= x"00000005";
        op2 <= x"00000003";
        alu_op <= "010"; -- SUB
        wait for 10 ns;

        assert alu_out = x"00000002"
            report "SUB failed" severity error;

        -----------------------------------------
        -- AND
        -----------------------------------------
        op1 <= x"F0F0F0F0";
        op2 <= x"0F0F0F0F";
        alu_op <= "011"; -- AND
        wait for 10 ns;

        assert alu_out = x"00000000"
            report "AND failed" severity error;
        assert ccr_out(0) = '1'
            report "AND zero flag wrong" severity error;

        -----------------------------------------
        -- NOT
        -----------------------------------------
        op1 <= x"00000000";
        alu_op <= "100"; -- NOT
        wait for 10 ns;

        assert alu_out = x"FFFFFFFF"
            report "NOT failed" severity error;
        assert ccr_out(1) = '1'
            report "NOT negative flag wrong" severity error;

        -----------------------------------------
        -- INC
        -----------------------------------------
        op1 <= x"0000000F";
        alu_op <= "110"; -- INC
        wait for 10 ns;

        assert alu_out = x"00000010"
            report "INC failed" severity error;

        -----------------------------------------
        -- SETC
        -----------------------------------------
        alu_op <= "111"; -- SETC
        wait for 10 ns;

        assert ccr_out(2) = '1'
            report "SETC failed" severity error;

        -----------------------------------------
        -- DONE
        -----------------------------------------
        report "ALU TESTS PASSED SUCCESSFULLY" severity note;
        wait;

    end process;

end architecture;
