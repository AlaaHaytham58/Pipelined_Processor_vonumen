library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity E_M_Register_tb is
end E_M_Register_tb;

architecture Behavioral of E_M_Register_tb is
    -- Component declaration
    component E_M_Register is
        Port (
            CLK           : in  STD_LOGIC;
            RST           : in  STD_LOGIC;
            EN            : in  STD_LOGIC;
            MemRead       : in STD_LOGIC;
            MEM_OP        : in STD_LOGIC;
            MEM_SEL       : in STD_LOGIC;
            MEM_R         : in STD_LOGIC;
            ALURes        : in STD_LOGIC_VECTOR(31 downto 0);
            Raddr1        : in STD_LOGIC_VECTOR(2 downto 0);
            Raddr2        : in STD_LOGIC_VECTOR(2 downto 0);
            Rdst          : in STD_LOGIC_VECTOR(2 downto 0);
            Rdata1        : in STD_LOGIC_VECTOR(31 downto 0);
            Rdata2        : in STD_LOGIC_VECTOR(31 downto 0);
            WriteData     : in STD_LOGIC;
            WE1           : in STD_LOGIC;
            WE2           : in STD_LOGIC;
            IN_Port       : in STD_LOGIC;
            PCSRC         : in STD_LOGIC;
            STACK         : in STD_LOGIC;
            BR_ADDR       : in STD_LOGIC_VECTOR(31 downto 0);
            MEM_W         : in STD_LOGIC;
            Imm           : in STD_LOGIC_VECTOR(15 downto 0);
            OUT_EN        : in STD_LOGIC;
            CLR           : in STD_LOGIC; 
            PCPlus4       : in STD_LOGIC_VECTOR(31 downto 0);
            MemRead_Out   : out STD_LOGIC;
            MEM_OP_Out    : out STD_LOGIC;
            MEM_SEL_Out   : out STD_LOGIC;
            MEM_R_Out     : out STD_LOGIC;
            ALURes_Out    : out STD_LOGIC_VECTOR(31 downto 0);
            Raddr1_Out    : out STD_LOGIC_VECTOR(2 downto 0);
            Raddr2_Out    : out STD_LOGIC_VECTOR(2 downto 0);
            Rdst_Out      : out STD_LOGIC_VECTOR(2 downto 0);
            PCPlus4_Out   : out STD_LOGIC_VECTOR(31 downto 0);
            PCSRC_Out     : out STD_LOGIC;
            STACK_Out     : out STD_LOGIC;
            BR_ADDR_Out   : out STD_LOGIC_VECTOR(31 downto 0);
            Rdata1_Out    : out STD_LOGIC_VECTOR(31 downto 0);
            Rdata2_Out    : out STD_LOGIC_VECTOR(31 downto 0);
            WriteData_Out : out STD_LOGIC;
            WE1_Out       : out STD_LOGIC;
            WE2_Out       : out STD_LOGIC;
            MEM_W_Out     : out STD_LOGIC;
            IN_Port_Out   : out STD_LOGIC;
            Imm_Out       : out STD_LOGIC_VECTOR(15 downto 0);
            OUT_EN_Out    : out STD_LOGIC
        );
    end component;

    -- Test signals
    signal CLK           : STD_LOGIC := '0';
    signal RST           : STD_LOGIC := '0';
    signal EN            : STD_LOGIC := '0';
    signal MemRead       : STD_LOGIC := '0';
    signal MEM_OP        : STD_LOGIC := '0';
    signal MEM_SEL       : STD_LOGIC := '0';
    signal MEM_R         : STD_LOGIC := '0';
    signal ALURes        : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal Raddr1        : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal Raddr2        : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal Rdst          : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal Rdata1        : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal Rdata2        : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal WriteData     : STD_LOGIC := '0';
    signal WE1           : STD_LOGIC := '0';
    signal WE2           : STD_LOGIC := '0';
    signal IN_Port       : STD_LOGIC := '0';
    signal PCSRC         : STD_LOGIC := '0';
    signal STACK         : STD_LOGIC := '0';
    signal BR_ADDR       : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal MEM_W         : STD_LOGIC := '0';
    signal Imm           : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal OUT_EN        : STD_LOGIC := '0';
    signal CLR           : STD_LOGIC := '0';
    signal PCPlus4       : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    
    signal MemRead_Out   : STD_LOGIC;
    signal MEM_OP_Out    : STD_LOGIC;
    signal MEM_SEL_Out   : STD_LOGIC;
    signal MEM_R_Out     : STD_LOGIC;
    signal ALURes_Out    : STD_LOGIC_VECTOR(31 downto 0);
    signal Raddr1_Out    : STD_LOGIC_VECTOR(2 downto 0);
    signal Raddr2_Out    : STD_LOGIC_VECTOR(2 downto 0);
    signal Rdst_Out      : STD_LOGIC_VECTOR(2 downto 0);
    signal PCPlus4_Out   : STD_LOGIC_VECTOR(31 downto 0);
    signal PCSRC_Out     : STD_LOGIC;
    signal STACK_Out     : STD_LOGIC;
    signal BR_ADDR_Out   : STD_LOGIC_VECTOR(31 downto 0);
    signal Rdata1_Out    : STD_LOGIC_VECTOR(31 downto 0);
    signal Rdata2_Out    : STD_LOGIC_VECTOR(31 downto 0);
    signal WriteData_Out : STD_LOGIC;
    signal WE1_Out       : STD_LOGIC;
    signal WE2_Out       : STD_LOGIC;
    signal MEM_W_Out     : STD_LOGIC;
    signal IN_Port_Out   : STD_LOGIC;
    signal Imm_Out       : STD_LOGIC_VECTOR(15 downto 0);
    signal OUT_EN_Out    : STD_LOGIC;

    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;
    
    -- Test control
    signal test_complete : boolean := false;

begin
    -- Instantiate the Unit Under Test (UUT)
    UUT: E_M_Register
        port map (
            CLK           => CLK,
            RST           => RST,
            EN            => EN,
            MemRead       => MemRead,
            MEM_OP        => MEM_OP,
            MEM_SEL       => MEM_SEL,
            MEM_R         => MEM_R,
            ALURes        => ALURes,
            Raddr1        => Raddr1,
            Raddr2        => Raddr2,
            Rdst          => Rdst,
            Rdata1        => Rdata1,
            Rdata2        => Rdata2,
            WriteData     => WriteData,
            WE1           => WE1,
            WE2           => WE2,
            IN_Port       => IN_Port,
            PCSRC         => PCSRC,
            STACK         => STACK,
            BR_ADDR       => BR_ADDR,
            MEM_W         => MEM_W,
            Imm           => Imm,
            OUT_EN        => OUT_EN,
            CLR           => CLR,
            PCPlus4       => PCPlus4,
            MemRead_Out   => MemRead_Out,
            MEM_OP_Out    => MEM_OP_Out,
            MEM_SEL_Out   => MEM_SEL_Out,
            MEM_R_Out     => MEM_R_Out,
            ALURes_Out    => ALURes_Out,
            Raddr1_Out    => Raddr1_Out,
            Raddr2_Out    => Raddr2_Out,
            Rdst_Out      => Rdst_Out,
            PCPlus4_Out   => PCPlus4_Out,
            PCSRC_Out     => PCSRC_Out,
            STACK_Out     => STACK_Out,
            BR_ADDR_Out   => BR_ADDR_Out,
            Rdata1_Out    => Rdata1_Out,
            Rdata2_Out    => Rdata2_Out,
            WriteData_Out => WriteData_Out,
            WE1_Out       => WE1_Out,
            WE2_Out       => WE2_Out,
            MEM_W_Out     => MEM_W_Out,
            IN_Port_Out   => IN_Port_Out,
            Imm_Out       => Imm_Out,
            OUT_EN_Out    => OUT_EN_Out
        );

    -- Clock process
    clk_process: process
    begin
        while not test_complete loop
            CLK <= '0';
            wait for CLK_PERIOD/2;
            CLK <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Test 1: Reset test
        report "TEST 1: Reset functionality";
        RST <= '1';
        EN <= '1';
        MemRead <= '1';
        MEM_OP <= '1';
        ALURes <= X"DEADBEEF";
        Raddr1 <= "101";
        wait for CLK_PERIOD;
        
        -- Check that outputs are zero after reset
        assert MemRead_Out = '0' report "Reset failed for MemRead_Out" severity error;
        assert ALURes_Out = X"00000000" report "Reset failed for ALURes_Out" severity error;
        assert Raddr1_Out = "000" report "Reset failed for Raddr1_Out" severity error;
        report "TEST 1: PASSED";
        
        RST <= '0';
        wait for CLK_PERIOD;

        -- Test 2: Normal operation with EN=1
        report "TEST 2: Normal operation with EN=1";
        EN <= '1';
        MemRead <= '1';
        MEM_OP <= '1';
        MEM_SEL <= '1';
        MEM_R <= '0';
        ALURes <= X"12345678";
        Raddr1 <= "011";
        Raddr2 <= "101";
        Rdst <= "111";
        PCPlus4 <= X"00000100";
        PCSRC <= '1';
        STACK <= '0';
        BR_ADDR <= X"AABBCCDD";
        Rdata1 <= X"11111111";
        Rdata2 <= X"22222222";
        WriteData <= '1';
        WE1 <= '1';
        WE2 <= '0';
        MEM_W <= '1';
        IN_Port <= '0';
        Imm <= X"ABCD";
        OUT_EN <= '1';
        CLR <= '0';
        
        wait for CLK_PERIOD;
        
        -- Check registered values appear on output
        assert MemRead_Out = '1' report "Failed to register MemRead" severity error;
        assert MEM_OP_Out = '1' report "Failed to register MEM_OP" severity error;
        assert MEM_SEL_Out = '1' report "Failed to register MEM_SEL" severity error;
        assert ALURes_Out = X"12345678" report "Failed to register ALURes" severity error;
        assert Raddr1_Out = "011" report "Failed to register Raddr1" severity error;
        assert Raddr2_Out = "101" report "Failed to register Raddr2" severity error;
        assert Rdst_Out = "111" report "Failed to register Rdst" severity error;
        assert PCPlus4_Out = X"00000100" report "Failed to register PCPlus4" severity error;
        assert PCSRC_Out = '1' report "Failed to register PCSRC" severity error;
        assert BR_ADDR_Out = X"AABBCCDD" report "Failed to register BR_ADDR" severity error;
        assert WE1_Out = '1' report "Failed to register WE1" severity error;
        assert Imm_Out = X"ABCD" report "Failed to register Imm" severity error;
        report "TEST 2: PASSED";

        -- Test 3: Enable disabled (EN=0)
        report "TEST 3: Testing EN=0 (register hold)";
        EN <= '0';
        MemRead <= '0';
        MEM_OP <= '0';
        ALURes <= X"FFFFFFFF";
        Raddr1 <= "000";
        
        wait for CLK_PERIOD;
        
        -- Outputs should hold previous values
        assert MemRead_Out = '1' report "EN=0 failed: output changed" severity error;
        assert ALURes_Out = X"12345678" report "EN=0 failed: ALURes changed" severity error;
        assert Raddr1_Out = "011" report "EN=0 failed: Raddr1 changed" severity error;
        report "TEST 3: PASSED";

        -- Test 4: CLR (Clear) functionality
        report "TEST 4: Testing CLR functionality";
        EN <= '1';
        CLR <= '1';
        
        wait for 1 ns;  -- Combinational delay
        
        -- Outputs should be cleared immediately (combinational)
        assert MemRead_Out = '0' report "CLR failed for MemRead_Out" severity error;
        assert MEM_OP_Out = '0' report "CLR failed for MEM_OP_Out" severity error;
        assert ALURes_Out = X"00000000" report "CLR failed for ALURes_Out" severity error;
        assert Raddr1_Out = "000" report "CLR failed for Raddr1_Out" severity error;
        assert PCSRC_Out = '0' report "CLR failed for PCSRC_Out" severity error;
        report "TEST 4: PASSED";
        
        CLR <= '0';
        wait for CLK_PERIOD;

        -- Test 5: Multiple consecutive writes
        report "TEST 5: Multiple consecutive writes";
        EN <= '1';
        
        -- First write
        ALURes <= X"AAAA1111";
        Rdst <= "001";
        wait for CLK_PERIOD;
        assert ALURes_Out = X"AAAA1111" report "Write 1 failed" severity error;
        assert Rdst_Out = "001" report "Write 1 Rdst failed" severity error;
        
        -- Second write
        ALURes <= X"BBBB2222";
        Rdst <= "010";
        wait for CLK_PERIOD;
        assert ALURes_Out = X"BBBB2222" report "Write 2 failed" severity error;
        assert Rdst_Out = "010" report "Write 2 Rdst failed" severity error;
        
        -- Third write
        ALURes <= X"CCCC3333";
        Rdst <= "011";
        wait for CLK_PERIOD;
        assert ALURes_Out = X"CCCC3333" report "Write 3 failed" severity error;
        assert Rdst_Out = "011" report "Write 3 Rdst failed" severity error;
        report "TEST 5: PASSED";

        -- Test 6: All control signals
        report "TEST 6: Testing all control signals";
        MemRead <= '1';
        MEM_OP <= '0';
        MEM_SEL <= '1';
        MEM_R <= '1';
        PCSRC <= '0';
        STACK <= '1';
        WriteData <= '1';
        WE1 <= '0';
        WE2 <= '1';
        MEM_W <= '1';
        IN_Port <= '1';
        OUT_EN <= '0';
        
        wait for CLK_PERIOD;
        
        assert MemRead_Out = '1' report "Control signal MemRead failed" severity error;
        assert MEM_OP_Out = '0' report "Control signal MEM_OP failed" severity error;
        assert MEM_SEL_Out = '1' report "Control signal MEM_SEL failed" severity error;
        assert MEM_R_Out = '1' report "Control signal MEM_R failed" severity error;
        assert PCSRC_Out = '0' report "Control signal PCSRC failed" severity error;
        assert STACK_Out = '1' report "Control signal STACK failed" severity error;
        assert WriteData_Out = '1' report "Control signal WriteData failed" severity error;
        assert WE1_Out = '0' report "Control signal WE1 failed" severity error;
        assert WE2_Out = '1' report "Control signal WE2 failed" severity error;
        assert MEM_W_Out = '1' report "Control signal MEM_W failed" severity error;
        assert IN_Port_Out = '1' report "Control signal IN_Port failed" severity error;
        assert OUT_EN_Out = '0' report "Control signal OUT_EN failed" severity error;
        report "TEST 6: PASSED";

        -- Test 7: Edge values for data buses
        report "TEST 7: Testing edge values";
        ALURes <= X"00000000";
        Rdata1 <= X"00000000";
        Rdata2 <= X"FFFFFFFF";
        BR_ADDR <= X"FFFFFFFF";
        PCPlus4 <= X"00000000";
        Imm <= X"0000";
        
        wait for CLK_PERIOD;
        
        assert ALURes_Out = X"00000000" report "Min value test failed" severity error;
        assert Rdata2_Out = X"FFFFFFFF" report "Max value test failed" severity error;
        assert BR_ADDR_Out = X"FFFFFFFF" report "BR_ADDR max value failed" severity error;
        report "TEST 7: PASSED";

        -- Final report
        report "======================================";
        report "ALL TESTS COMPLETED SUCCESSFULLY!";
        report "======================================";
        
        test_complete <= true;
        wait;
    end process;

end Behavioral;