library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_F_D_Register is
end tb_F_D_Register;

architecture TB of tb_F_D_Register is

    -- DUT signals
    signal CLK         : STD_LOGIC := '0';
    signal RST         : STD_LOGIC := '0';
    signal EN          : STD_LOGIC := '0';
    signal CLR         : STD_LOGIC := '0';

    signal Inst        : STD_LOGIC_VECTOR(31 downto 0);
    signal PCPlus4     : STD_LOGIC_VECTOR(31 downto 0);
    signal IN_Port     : STD_LOGIC_VECTOR(31 downto 0);

    signal Inst_Out    : STD_LOGIC_VECTOR(31 downto 0);
    signal PCPlus4_Out : STD_LOGIC_VECTOR(31 downto 0);
    signal IN_Out      : STD_LOGIC_VECTOR(31 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    -- Clock generation
    CLK <= not CLK after CLK_PERIOD / 2;

    -- DUT instantiation
    DUT: entity work.F_D_Register
        port map (
            CLK         => CLK,
            RST         => RST,
            EN          => EN,
            CLR         => CLR,
            Inst        => Inst,
            PCPlus4     => PCPlus4,
            IN_Port     => IN_Port,
            Inst_Out    => Inst_Out,
            PCPlus4_Out => PCPlus4_Out,
            IN_Out      => IN_Out
        );

    -- Stimulus process
    process
    begin
        -- Reset
        RST <= '1';
        EN  <= '0';
        CLR <= '0';
        Inst    <= x"00000000";
        PCPlus4 <= x"00000000";
        IN_Port <= x"00000000";
        wait for 20 ns;

        RST <= '0';
        EN  <= '1';

        -- First instruction
        Inst    <= x"12345678";
        PCPlus4 <= x"00000004";
        IN_Port <= x"AAAAAAAA";
        wait for 10 ns;

        -- Second instruction
        Inst    <= x"87654321";
        PCPlus4 <= x"00000008";
        IN_Port <= x"BBBBBBBB";
        wait for 10 ns;

        -- Stall (EN = 0)
        EN <= '0';
        Inst    <= x"FFFFFFFF";
        PCPlus4 <= x"FFFFFFFF";
        IN_Port <= x"FFFFFFFF";
        wait for 10 ns;

        -- Resume
        EN <= '1';
        wait for 10 ns;

        -- Flush (branch taken)
        CLR <= '1';
        wait for 10 ns;
        CLR <= '0';

        -- New instruction after flush
        Inst    <= x"DEADBEEF";
        PCPlus4 <= x"0000000C";
        IN_Port <= x"CCCCCCCC";
        wait for 10 ns;

        wait;
    end process;

end TB ;
