library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity E_M_Register is
    Port (
        CLK           : in  STD_LOGIC;
        RST           : in  STD_LOGIC;
        EN            : in  STD_LOGIC;

        MemRead       : in STD_LOGIC;
        MEM_OP        : in STD_LOGIC;
        MEM_SEL       : in STD_LOGIC_VECTOR(1 downto 0);
        MEM_R         : in STD_LOGIC;
        ALURes        : in STD_LOGIC_VECTOR(31 downto 0);
        Raddr1        : in STD_LOGIC_VECTOR(2 downto 0);
        Raddr2        : in STD_LOGIC_VECTOR(2 downto 0);
        Rdst          : in STD_LOGIC_VECTOR(2 downto 0);
        Rdata1        : in STD_LOGIC_VECTOR(31 downto 0);
        Rdata2        : in STD_LOGIC_VECTOR(31 downto 0);
        Mem_Wdata_Sel     : in STD_LOGIC_VECTOR(1 downto 0);
        WE1           : in STD_LOGIC;
        WE2           : in STD_LOGIC;
        IN_Port       : in STD_LOGIC;
        PCSRC         : in STD_LOGIC;
        Stack_en      : in  STD_LOGIC;
        Stack_inc     : in  STD_LOGIC;
        Stack_dec     : in  STD_LOGIC; 
        BR_ADDR       : in STD_LOGIC_VECTOR(31 downto 0);
        MEM_W         : in STD_LOGIC;
        Imm           : in STD_LOGIC_VECTOR(31 downto 0);
        OUT_EN        : in STD_LOGIC;
        CLR           : in STD_LOGIC; 
        PCPlus4       : in STD_LOGIC_VECTOR(31 downto 0);
        WB_Wdata_Sel  : in STD_LOGIC_VECTOR(2 downto 0);
        WB_Waddr_Sel  : in STD_LOGIC_VECTOR(1 downto 0);
        
        -- Outputs
        MemRead_Out   : out STD_LOGIC;
        MEM_OP_Out    : out STD_LOGIC;
        MEM_SEL_Out   : out STD_LOGIC_VECTOR(1 downto 0);
        MEM_R_Out     : out STD_LOGIC;
        ALURes_Out    : out STD_LOGIC_VECTOR(31 downto 0);
        Raddr1_Out    : out STD_LOGIC_VECTOR(2 downto 0);
        Raddr2_Out    : out STD_LOGIC_VECTOR(2 downto 0);
        Rdst_Out      : out STD_LOGIC_VECTOR(2 downto 0);
        PCPlus4_Out   : out STD_LOGIC_VECTOR(31 downto 0);
        PCSRC_Out     : out STD_LOGIC;
        Stack_en_Out  : out STD_LOGIC;
        Stack_inc_Out : out STD_LOGIC;
        Stack_dec_Out     : out  STD_LOGIC; 
        BR_ADDR_Out   : out STD_LOGIC_VECTOR(31 downto 0);
        Rdata1_Out    : out STD_LOGIC_VECTOR(31 downto 0);
        Rdata2_Out    : out STD_LOGIC_VECTOR(31 downto 0);
        Mem_Wdata_Sel_Out : out STD_LOGIC_VECTOR(1 downto 0);
        WE1_Out       : out STD_LOGIC;
        WE2_Out       : out STD_LOGIC;
        MEM_W_Out     : out STD_LOGIC;
        IN_Port_Out   : out STD_LOGIC;
        Imm_Out       : out STD_LOGIC_VECTOR(31 downto 0);
        OUT_EN_Out    : out STD_LOGIC;
        WB_Wdata_Sel_Out  : out STD_LOGIC_VECTOR(2 downto 0);
        WB_Waddr_Sel_Out  : out STD_LOGIC_VECTOR(1 downto 0)
    );
end E_M_Register;

architecture Behavioral of E_M_Register is
    -- Internal registers to store input values
        signal MemRead_Reg   : STD_LOGIC := '0';
        signal MEM_OP_Reg    : STD_LOGIC := '0';
        signal MEM_SEL_Reg   : STD_LOGIC_VECTOR(1 downto 0) := "00";
        signal MEM_R_Reg     : STD_LOGIC := '0';
        signal ALURes_Reg    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
        signal Raddr1_Reg    : STD_LOGIC_VECTOR(2 downto 0)  := (others => '0');
        signal Raddr2_Reg    : STD_LOGIC_VECTOR(2 downto 0)  := (others => '0');
        signal Rdst_Reg      : STD_LOGIC_VECTOR(2 downto 0)  := (others => '0');
        signal PCPlus4_Reg   : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
        signal PCSRC_Reg     : STD_LOGIC := '0';
        signal Stack_en_Reg  : STD_LOGIC := '0';
        signal Stack_inc_Reg : STD_LOGIC := '0';
        signal Stack_dec_Reg : STD_LOGIC := '0';
        signal BR_ADDR_Reg   : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
        signal Rdata1_Reg    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
        signal Rdata2_Reg    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
        signal Mem_Wdata_Sel_Reg : STD_LOGIC_VECTOR(1 downto 0):= "00";
        signal WE1_Reg       : STD_LOGIC := '0';
        signal WE2_Reg       : STD_LOGIC := '0';
        signal MEM_W_Reg     : STD_LOGIC := '0';
        signal IN_Port_Reg   : STD_LOGIC := '0';
        signal Imm_Reg       : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
        signal OUT_EN_Reg    : STD_LOGIC := '0';
        signal WB_Wdata_Sel_Reg: STD_LOGIC_VECTOR(2 downto 0);
        signal WB_Waddr_Sel_Reg: STD_LOGIC_VECTOR(1 downto 0);

begin
    -- Register inputs on rising edge
    process (CLK, RST)
    begin
        if RST = '1' or (rising_edge(CLK) and CLR = '1')then
            MemRead_Reg   <= '0';
            MEM_OP_Reg    <= '0';
            MEM_SEL_Reg   <= "00";
            MEM_R_Reg     <= '0';
            ALURes_Reg    <= (others => '0');
            Raddr1_Reg    <= (others => '0');
            Raddr2_Reg    <= (others => '0');
            Rdst_Reg      <= (others => '0');
            PCPlus4_Reg   <= (others => '0');
            PCSRC_Reg     <= '0';
            Stack_en_Reg  <= '0';
            Stack_inc_Reg <= '0';
            Stack_dec_Reg <= '0';
            BR_ADDR_Reg   <= (others => '0');
            Rdata1_Reg    <= (others => '0');
            Rdata2_Reg    <= (others => '0');
            Mem_Wdata_Sel_Reg <= "00";
            WE1_Reg       <= '0';
            WE2_Reg       <= '0';
            MEM_W_Reg     <= '0';
            IN_Port_Reg   <= '0';
            Imm_Reg       <= (others => '0');
            OUT_EN_Reg    <= '0';
            WB_Wdata_Sel_Reg <= "000";
            WB_Waddr_Sel_Reg <= "00";
        elsif rising_edge(CLK) then
            if EN = '1' then
                MemRead_Reg   <= MemRead;
                MEM_OP_Reg    <= MEM_OP;
                MEM_SEL_Reg   <= MEM_SEL;
                MEM_R_Reg     <= MEM_R;
                ALURes_Reg    <= ALURes;
                Raddr1_Reg    <= Raddr1;
                Raddr2_Reg    <= Raddr2;
                Rdst_Reg      <= Rdst;
                PCPlus4_Reg   <= PCPlus4;
                PCSRC_Reg     <= PCSRC;
                Stack_en_Reg  <= Stack_en;
                Stack_inc_Reg <= Stack_inc;
                Stack_dec_Reg <= Stack_dec;
                BR_ADDR_Reg   <= BR_ADDR;
                Rdata1_Reg    <= Rdata1;
                Rdata2_Reg    <= Rdata2;
                Mem_Wdata_Sel_Reg <= Mem_Wdata_Sel;
                WE1_Reg       <= WE1;
                WE2_Reg       <= WE2;
                MEM_W_Reg     <= MEM_W;
                IN_Port_Reg   <= IN_Port;
                Imm_Reg       <= Imm;
                OUT_EN_Reg    <= OUT_EN;
                WB_Wdata_Sel_Reg <= WB_Wdata_Sel;
                WB_Waddr_Sel_Reg <= WB_Waddr_Sel;
            end if;
        end if;
    end process;

    -- Combinational outputs (continuous assignments)
    MemRead_Out   <=  MemRead_Reg;
    MEM_OP_Out    <=  MEM_OP_Reg;
    MEM_SEL_Out   <=  MEM_SEL_Reg;
    MEM_R_Out     <=  MEM_R_Reg;
    ALURes_Out    <=  ALURes_Reg;
    Raddr1_Out    <=  Raddr1_Reg;
    Raddr2_Out    <=  Raddr2_Reg;
    Rdst_Out      <=  Rdst_Reg;
    PCPlus4_Out   <=  PCPlus4_Reg;
    PCSRC_Out     <=  PCSRC_Reg;
    Stack_en_Out  <=  Stack_en_Reg;
    Stack_inc_Out  <=  Stack_inc_Reg;
    Stack_dec_Out  <=  Stack_dec_Reg;
    BR_ADDR_Out   <=  BR_ADDR_Reg;
    Rdata1_Out    <=  Rdata1_Reg;
    Rdata2_Out    <=  Rdata2_Reg;
    Mem_Wdata_Sel_Out <=  Mem_Wdata_Sel_Reg;
    WE1_Out       <=  WE1_Reg;
    WE2_Out       <=  WE2_Reg;
    MEM_W_Out     <=  MEM_W_Reg;
    IN_Port_Out   <=  IN_Port_Reg;
    Imm_Out       <=  Imm_Reg;
    OUT_EN_Out    <=  OUT_EN_Reg;
    WB_Wdata_Sel_Out <=  WB_Wdata_Sel_Reg;
    WB_Waddr_Sel_Out <=  WB_Waddr_Sel_Reg;

end Behavioral;