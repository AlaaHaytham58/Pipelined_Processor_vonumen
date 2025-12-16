library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    Port (
        -- Inputs
        op1 : in  STD_LOGIC_VECTOR(31 downto 0);  -- First operand
        op2 : in  STD_LOGIC_VECTOR(31 downto 0);  -- Second operand
        alu_op   : in  STD_LOGIC_VECTOR(6 downto 0);   -- Operation select
        offset   : in  STD_LOGIC_VECTOR(15 downto 0);  -- Offset for address calculation
        imm      : in  STD_LOGIC_VECTOR(15 downto 0);  -- Immediate value

        -- Outputs
        alu_out  : out STD_LOGIC_VECTOR(31 downto 0);  -- ALU result
        ccr      : out STD_LOGIC_VECTOR(3 downto 0)    -- Condition Code Register (Z, N, C, O flags)
        -- N is for signed negative, C is for unsigned overflow, O is for signed overflow
    );
end ALU;

architecture Behavioral of ALU is

    signal signed_result       : STD_LOGIC_VECTOR(32 downto 0);
    signal unsigned_result     : STD_LOGIC_VECTOR(31 downto 0);
    signal A            : unsigned(32 downto 0); --33 bits for case of carry
    signal B            : unsigned(32 downto 0);

    signal imm_33_bit : unsigned(32 downto 0);

    signal zf           : STD_LOGIC;
    signal nf           : STD_LOGIC;
    signal cf           : STD_LOGIC;

    signal flags        : STD_LOGIC_VECTOR(3 downto 0);

    signal update_flags     : STD_LOGIC_VECTOR(3 downto 0);  -- Z, N, C;

    -- Sign-extended immediate value signals
    signal imm_extended    : STD_LOGIC_VECTOR(31 downto 0);
    signal offset_extended : STD_LOGIC_VECTOR(31 downto 0);

    signal CCR_IN : STD_LOGIC_VECTOR(3 downto 0) := "0000"; -- Assumed input from Register File

    begin

        A <= unsigned('0' & op1);
        B <= unsigned('0' & op2);

        imm_extended <= (31 downto 16 => Imm(15)) & Imm;
        imm_33_bit <= unsigned('0' & imm_extended);
        offset_extended <= (31 downto 16 => offset(15)) & offset;

        zf <= '1' when unsigned_result = x"00000000" else '0';  -- Zero flag
        nf <= unsigned_result(31);                              -- Negative flag (MSB)

        -- The VHDL signal 'flags' prepares the final output vector (V N C Z)
        flags(0) <= zf;
        flags(1) <= nf;
        flags(2) <= cf;
        flags(3) <= '0'; -- V flag (Reserved/Unused)

        process(op1, op2, alu_op, A, B, offset, imm, imm_extended, offset_extended, unsigned_result)
        begin
            signed_result   <= (others => '0');
            unsigned_result <= (others => '0');
            cf <= '0';
            update_flags <= (others => '0');  -- Don't update by default

            case alu_op is
                when "0000000" => --NOP
                    unsigned_result <= (others =>'0');

                when "0010111" => --SETC
                    unsigned_result <= (others => '0');
                    cf       <= '1';
                    update_flags <= "0010";

                when "0011100" => --Not
                    unsigned_result <= not op1;
                    update_flags <= "1100";

                when "0011110" => --INC
                    signed_result <= std_logic_vector(A + 1);     --33-bits
                    unsigned_result <= signed_result(31 downto 0);
                    cf <= signed_result(32);
                    update_flags <= "1110";

                when "0001011" => --Mov
                    unsigned_result <= op1;
                    update_flags <= "0000";

                when "0011001" => --Add
                    signed_result <= std_logic_vector(A + B);
                    unsigned_result <= signed_result(31 downto 0);
                    cf <= signed_result(32);
                    update_flags <= "1110";

                when "0011010" => --Sub
                    unsigned_result <= std_logic_vector(A(31 downto 0) - B(31 downto 0));
                    if A(31 downto 0) >= B(31 downto 0) then
                        cf <= '0';
                    else
                        cf <= '1';
                    end if;
                    update_flags <= "1110";

                when "0011011" => --And
                    unsigned_result <= op1 and op2;
                    update_flags <= "1100";

                when "0011101" => --IAdd
                    signed_result <= std_logic_vector(A + imm_33_bit);
                    unsigned_result <= signed_result(31 downto 0);
                    cf <= signed_result(32);
                    update_flags <= "1110";

                when "0001110" => --LDM
                    unsigned_result <= imm_extended;
                    update_flags <= "0000";

                when others =>
                    unsigned_result <= (others => 'X');
            end case;
        end process;

        alu_out <= unsigned_result;

        process(flags, update_flags, CCR_IN)
        variable new_ccr : STD_LOGIC_VECTOR(3 downto 0);
    begin
        new_ccr := CCR_IN; -- Default: Hold the current value

        -- Apply new calculated flags only if the corresponding update bit is '1'
        if update_flags(0) = '1' then new_ccr(0) := flags(0); end if; -- C
        if update_flags(1) = '1' then new_ccr(1) := flags(1); end if; -- N
        if update_flags(2) = '1' then new_ccr(2) := flags(2); end if; -- Z
        -- CCR(0) (V flag) is unused and remains '0' unless specified by update_flags(0)

        ccr <= new_ccr;
    end process;


end architecture;