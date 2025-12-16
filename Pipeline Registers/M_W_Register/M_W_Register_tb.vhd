library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity M_W_Register_tb is
end M_W_Register_tb;

architecture Behavioral of M_W_Register_tb is
    -- Component declaration
    component M_W_Register is
        Port (
            CLK           : in  STD_LOGIC;
            RST           : in  STD_LOGIC;
            EN            : in  STD_LOGIC;
            ALURes        : in STD_LOGIC_VECTOR(31 downto 0);
            Raddr1        : in STD_LOGIC_VECTOR(2 downto 0);
            Raddr2        : in STD_LOGIC_VECTOR(2 downto 0);
            Rdst          : in STD_LOGIC_VECTOR(2 downto 0);
            Rdata1        : in STD_LOGIC_VECTOR(31 downto 0);
            Rdata2        : in STD_LOGIC_VECTOR(31 downto 0);
            WE1           : in STD_LOGIC;
            WE2           : in STD_LOGIC;
            IN_Port       : in STD_LOGIC;
            RT_ADDR       : in STD_LOGIC_VECTOR(31 downto 0);
            LD_DATA       : in STD_LOGIC_VECTOR(31 downto 0);
            Imm           : in STD_LOGIC_VECTOR(15 downto 0);
            OUT_EN        : in STD_LOGIC;
            CLR           : in STD_LOGIC; 
            ALURes_Out    : out STD_LOGIC_VECTOR(31 downto 0);
            Raddr1_Out    : out STD_LOGIC_VECTOR(2 downto 0);
            Raddr2_Out    : out STD_LOGIC_VECTOR(2 downto 0);
            Rdst_Out      : out STD_LOGIC_VECTOR(2 downto 0);
            RT_ADDR_Out   : out STD_LOGIC_VECTOR(31 downto 0);
            Rdata1_Out    : out STD_LOGIC_VECTOR(31 downto 0);
            Rdata2_Out    : out STD_LOGIC_VECTOR(31 downto 0);
            WE1_Out       : out STD_LOGIC;
            WE2_Out       : out STD_LOGIC;
            IN_Port_Out   : out STD_LOGIC;
            LD_DATA_Out   : out STD_LOGIC_VECTOR(31 downto 0);
            Imm_Out       : out STD_LOGIC_VECTOR(15 downto 0);
            OUT_EN_Out    : out STD_LOGIC
        );
    end component;

    -- Test signals
    signal CLK           : STD_LOGIC := '0';
    signal RST           : STD_LOGIC := '0';
    signal EN            : STD_LOGIC := '0';
    signal ALURes        : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal Raddr1        : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal Raddr2        : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal Rdst          : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal Rdata1        : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal Rdata2        : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal WE1           : STD_LOGIC := '0';
    signal WE2           : STD_LOGIC := '0';
    signal IN_Port       : STD_LOGIC := '0';
    signal RT_ADDR       : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal LD_DATA       : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal Imm           : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal OUT_EN        : STD_LOGIC := '0';
    signal CLR           : STD_LOGIC := '0';
    
    signal ALURes_Out    : STD_LOGIC_VECTOR(31 downto 0);
    signal Raddr1_Out    : STD_LOGIC_VECTOR(2 downto 0);
    signal Raddr2_Out    : STD_LOGIC_VECTOR(2 downto 0);
    signal Rdst_Out      : STD_LOGIC_VECTOR(2 downto 0);
    signal RT_ADDR_Out   : STD_LOGIC_VECTOR(31 downto 0);
    signal Rdata1_Out    : STD_LOGIC_VECTOR(31 downto 0);
    signal Rdata2_Out    : STD_LOGIC_VECTOR(31 downto 0);
    signal WE1_Out       : STD_LOGIC;
    signal WE2_Out       : STD_LOGIC;
    signal IN_Port_Out   : STD_LOGIC;
    signal LD_DATA_Out   : STD_LOGIC_VECTOR(31 downto 0);
    signal Imm_Out       : STD_LOGIC_VECTOR(15 downto 0);
    signal OUT_EN_Out    : STD_LOGIC;

    constant CLK_PERIOD : time := 10 ns;
    signal test_complete : boolean := false;

begin
    -- Instantiate UUT
    UUT: M_W_Register
        port map (
            CLK         => CLK,
            RST         => RST,
            EN          => EN,
            ALURes      => ALURes,
            Raddr1      => Raddr1,
            Raddr2      => Raddr2,
            Rdst        => Rdst,
            Rdata1      => Rdata1,
            Rdata2      => Rdata2,
            WE1         => WE1,
            WE2         => WE2,
            IN_Port     => IN_Port,
            RT_ADDR     => RT_ADDR,
            LD_DATA     => LD_DATA,
            Imm         => Imm,
            OUT_EN      => OUT_EN,
            CLR         => CLR,
            ALURes_Out  => ALURes_Out,
            Raddr1_Out  => Raddr1_Out,
            Raddr2_Out  => Raddr2_Out,
            Rdst_Out    => Rdst_Out,
            RT_ADDR_Out => RT_ADDR_Out,
            Rdata1_Out  => Rdata1_Out,
            Rdata2_Out  => Rdata2_Out,
            WE1_Out     => WE1_Out,
            WE2_Out     => WE2_Out,
            IN_Port_Out => IN_Port_Out,
            LD_DATA_Out => LD_DATA_Out,
            Imm_Out     => Imm_Out,
            OUT_EN_Out  => OUT_EN_Out
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
        -- Test 1: Reset functionality
        report "TEST 1: Reset functionality";
        RST <= '1';
        EN <= '1';
        ALURes <= X"DEADBEEF";
        Raddr1 <= "101";
        LD_DATA <= X"CAFEBABE";
        wait for CLK_PERIOD;
        
        assert ALURes_Out = X"00000000" report "Reset failed for ALURes_Out" severity error;
        assert Raddr1_Out = "000" report "Reset failed for Raddr1_Out" severity error;
        assert LD_DATA_Out = X"00000000" report "Reset failed for LD_DATA_Out" severity error;
        report "TEST 1: PASSED";
        
        RST <= '0';
        wait for CLK_PERIOD;

        -- Test 2: Normal operation with EN=1
        report "TEST 2: Normal operation with EN=1";
        EN <= '1';
        ALURes <= X"12345678";
        Raddr1 <= "011";
        Raddr2 <= "101";
        Rdst <= "111";
        RT_ADDR <= X"00000100";
        Rdata1 <= X"11111111";
        Rdata2 <= X"22222222";
        WE1 <= '1';
        WE2 <= '0';
        IN_Port <= '1';
        LD_DATA <= X"AABBCCDD";
        Imm <= X"ABCD";
        OUT_EN <= '1';
        
        wait for CLK_PERIOD;
        
        assert ALURes_Out = X"12345678" report "Failed to register ALURes" severity error;
        assert Raddr1_Out = "011" report "Failed to register Raddr1" severity error;
        assert Raddr2_Out = "101" report "Failed to register Raddr2" severity error;
        assert Rdst_Out = "111" report "Failed to register Rdst" severity error;
        assert RT_ADDR_Out = X"00000100" report "Failed to register RT_ADDR" severity error;
        assert LD_DATA_Out = X"AABBCCDD" report "Failed to register LD_DATA" severity error;
        assert WE1_Out = '1' report "Failed to register WE1" severity error;
        assert Imm_Out = X"ABCD" report "Failed to register Imm" severity error;
        report "TEST 2: PASSED";

        -- Test 3: Enable disabled (EN=0)
        report "TEST 3: Testing EN=0 (register hold)";
        EN <= '0';
        ALURes <= X"FFFFFFFF";
        Raddr1 <= "000";
        LD_DATA <= X"99999999";
        
        wait for CLK_PERIOD;
        
        assert ALURes_Out = X"12345678" report "EN=0 failed: ALURes changed" severity error;
        assert Raddr1_Out = "011" report "EN=0 failed: Raddr1 changed" severity error;
        assert LD_DATA_Out = X"AABBCCDD" report "EN=0 failed: LD_DATA changed" severity error;
        report "TEST 3: PASSED";

        -- Test 4: Multiple consecutive writes
        report "TEST 4: Multiple consecutive writes";
        EN <= '1';
        
        ALURes <= X"AAAA1111";
        Rdst <= "001";
        wait for CLK_PERIOD;
        assert ALURes_Out = X"AAAA1111" report "Write 1 failed" severity error;
        assert Rdst_Out = "001" report "Write 1 Rdst failed" severity error;
        
        ALURes <= X"BBBB2222";
        Rdst <= "010";
        wait for CLK_PERIOD;
        assert ALURes_Out = X"BBBB2222" report "Write 2 failed" severity error;
        assert Rdst_Out = "010" report "Write 2 Rdst failed" severity error;
        
        report "TEST 4: PASSED";

        -- Test 5: All control signals
        report "TEST 5: Testing all control signals";
        WE1 <= '0';
        WE2 <= '1';
        IN_Port <= '1';
        OUT_EN <= '0';
        
        wait for CLK_PERIOD;
        
        assert WE1_Out = '0' report "Control signal WE1 failed" severity error;
        assert WE2_Out = '1' report "Control signal WE2 failed" severity error;
        assert IN_Port_Out = '1' report "Control signal IN_Port failed" severity error;
        assert OUT_EN_Out = '0' report "Control signal OUT_EN failed" severity error;
        report "TEST 5: PASSED";

        -- Test 6: Edge values
        report "TEST 6: Testing edge values";
        ALURes <= X"00000000";
        Rdata1 <= X"00000000";
        Rdata2 <= X"FFFFFFFF";
        RT_ADDR <= X"FFFFFFFF";
        LD_DATA <= X"00000000";
        Imm <= X"0000";
        
        wait for CLK_PERIOD;
        
        assert ALURes_Out = X"00000000" report "Min value test failed" severity error;
        assert Rdata2_Out = X"FFFFFFFF" report "Max value test failed" severity error;
        assert RT_ADDR_Out = X"FFFFFFFF" report "RT_ADDR max value failed" severity error;
        report "TEST 6: PASSED";

        report "======================================";
        report "ALL TESTS COMPLETED SUCCESSFULLY!";
        report "======================================";
        
        test_complete <= true;
        wait;
    end process;

end Behavioral;