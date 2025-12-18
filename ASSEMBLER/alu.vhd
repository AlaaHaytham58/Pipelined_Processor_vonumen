library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    Port (
        -- Inputs
        op1 : in  STD_LOGIC_VECTOR(31 downto 0);  -- First operand
        op2 : in  STD_LOGIC_VECTOR(31 downto 0);  -- Second operand
        alu_op   : in  STD_LOGIC_VECTOR(2 downto 0);   -- Operation select
        ccr_in   : in  STD_LOGIC_VECTOR(2 downto 0);   -- (C, N, Z)

        -- Outputs
        alu_out  : out STD_LOGIC_VECTOR(31 downto 0);  -- ALU result
        ccr_out  : out STD_LOGIC_VECTOR(2 downto 0)    -- (C, N, Z)

    );
end ALU;

architecture Behavioral of ALU is

    signal signed_result       : STD_LOGIC_VECTOR(32 downto 0);
    signal unsigned_result     : STD_LOGIC_VECTOR(31 downto 0);
    signal A            : unsigned(32 downto 0); --33 bits for case of carry
    signal B            : unsigned(32 downto 0);


    signal zf           : STD_LOGIC;
    signal nf           : STD_LOGIC;
    signal cf           : STD_LOGIC;


    signal update_flags     : STD_LOGIC_VECTOR(2 downto 0);  -- C, N, Z;

    begin

        A <= unsigned('0' & op1);
        B <= unsigned('0' & op2);

        process(op1, op2, alu_op, A, B, unsigned_result)
            variable tmp : unsigned(32 downto 0);
        begin
            signed_result   <= (others => '0');
            unsigned_result <= (others => '0');
            cf <= '0';
            zf <= '0';
            nf <= '0';
            update_flags <= "000";  -- Don't update by default

            case alu_op is
                when "000" => --NOP
                    unsigned_result <= (others =>'0');
                    update_flags <= "000";

                when "111" => --SETC
                    unsigned_result <= (others => '0');
                    cf       <= '1';
                    update_flags <= "100";

                when "100" => --Not
                    unsigned_result <= not op1;
                    if unsigned_result = x"00000000" then
                        zf <= '1';
                    else
                        zf <= '0';
                    end if;
                    nf <= unsigned_result(31);
                    update_flags <= "011";

                when "110" => --INC
                    signed_result <= std_logic_vector(A + 1);     --32-bits
                    unsigned_result <= signed_result(31 downto 0);
                    cf <= signed_result(32);
                    if signed_result(31 downto 0) = x"00000000" then
                        zf <= '1';
                    else
                        zf <= '0';
                    end if;
                    nf <= signed_result(31);
                    update_flags <= "111";

                when "001" => --Add
                    tmp := A + B;
                    unsigned_result <= std_logic_vector(tmp(31 downto 0));
                    cf <= tmp(32);
                    if  tmp(31 downto 0) = x"00000000" then
                        zf <= '1';
                    else
                        zf <= '0';
                    end if;
                    nf <= signed_result(31);
                    update_flags <= "111";

                when "010" => --Sub
                    unsigned_result <= std_logic_vector(A(31 downto 0) - B(31 downto 0));
                    if A(31 downto 0) >= B(31 downto 0) then
                        cf <= '0';
                    else
                        cf <= '1';
                    end if;
                    if unsigned_result = x"00000000" then
                        zf <= '1';
                    else
                        zf <= '0';
                    end if;
                    nf <= unsigned_result(31);
                    update_flags <= "111";

                when "011" => --And
                    unsigned_result <= op1 and op2;
                    if unsigned_result = x"00000000" then
                        zf <= '1';
                    else
                        zf <= '0';
                    end if;
                    nf <= unsigned_result(31);
                    update_flags <= "011";

                when "101" => --IAdd
                    tmp := A + B;
                    unsigned_result <= std_logic_vector(tmp(31 downto 0));
                    cf <= tmp(32);
                    if signed_result(31 downto 0) = x"00000000" then
                        zf <= '1';
                    else
                        zf <= '0';
                    end if;
                    nf <= signed_result(31);
                    update_flags <= "111";

                when others =>
                    unsigned_result <= (others => 'X');
                    update_flags <= "000";
            end case;
        end process;

        alu_out <= unsigned_result;

        process(ccr_in, cf, nf, zf, update_flags)
        variable new_ccr : STD_LOGIC_VECTOR(2 downto 0);
        begin
            new_ccr := ccr_in; -- Default: Hold the current value

            if update_flags(2) = '1' then new_ccr(2) := cf; end if; -- C
            if update_flags(1) = '1' then new_ccr(1) := nf; end if; -- N
            if update_flags(0) = '1' then new_ccr(0) := zf; end if; -- Z

            ccr_out <= new_ccr;
        end process;


end architecture;