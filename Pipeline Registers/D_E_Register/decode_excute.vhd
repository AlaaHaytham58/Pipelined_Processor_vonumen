library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity D_E_Register is
    Port (
        CLK        : in  STD_LOGIC;
        RST        : in  STD_LOGIC;
        EN         : in  STD_LOGIC;
        CLR        : in  STD_LOGIC;

        -- Control inputs
        CCR_EN     : in  STD_LOGIC; 
        RTI        : in  STD_LOGIC; 
        INT_Jump   : in  STD_LOGIC;
        INT_IDX    : in  STD_LOGIC_VECTOR(1 downto 0);
        MEM_W      : in  STD_LOGIC;
        Branch     : in  STD_LOGIC;
        Mem_Wdata_Sel  : in  STD_LOGIC_VECTOR(1 downto 0);
        MemRead    : in  STD_LOGIC;
        J_Type     : in  STD_LOGIC_VECTOR(1 downto 0);
        Stack_en   : in  STD_LOGIC;
        Stack_inc  : in  STD_LOGIC; 
        MEM_OP     : in  STD_LOGIC;
        MEM_SEL    : in  STD_LOGIC_VECTOR(1 downto 0);
        OUT_EN     : in  STD_LOGIC;
        ALU_A      : in  STD_LOGIC;
        ALUOp      : in  STD_LOGIC_VECTOR(2 downto 0);
        WE1        : in  STD_LOGIC;
        WE2        : in  STD_LOGIC;
        MEM_R      : in  STD_LOGIC;
        PCSRC      : in  STD_LOGIC;
        WB_Wdata_Sel  : in STD_LOGIC_VECTOR(2 downto 0);
        WB_Waddr_Sel  : in STD_LOGIC_VECTOR(1 downto 0);
        
        -- Data inputs
        PCPlus4    : in  STD_LOGIC_VECTOR(31 downto 0);
        Rdata1     : in  STD_LOGIC_VECTOR(31 downto 0);
        Rdata2     : in  STD_LOGIC_VECTOR(31 downto 0);
        Raddr1     : in  STD_LOGIC_VECTOR(2 downto 0);
        Raddr2     : in  STD_LOGIC_VECTOR(2 downto 0);
        Rdst       : in  STD_LOGIC_VECTOR(2 downto 0);
        Imm        : in  STD_LOGIC_VECTOR(31 downto 0);
        IN_Port    : in  STD_LOGIC_VECTOR(31 downto 0);
        ALU_B      : in  STD_LOGIC;

        -- Outputs
        CCR_EN_Out    : out STD_LOGIC;
        RTI_Out       : out STD_LOGIC;
        INT_Jump_Out  : out STD_LOGIC;
        INT_IDX_Out   : out STD_LOGIC_VECTOR(1 downto 0);
        MEM_W_Out     : out STD_LOGIC;
        Branch_Out    : out STD_LOGIC;
        Mem_Wdata_Sel_Out : out STD_LOGIC_VECTOR(1 downto 0);
        MemRead_Out   : out STD_LOGIC;
        J_Type_Out    : out STD_LOGIC_VECTOR(1 downto 0);
        Stack_en_Out  : out STD_LOGIC;
        Stack_inc_Out : out STD_LOGIC;
        MEM_OP_Out    : out STD_LOGIC;
        MEM_SEL_Out   : out STD_LOGIC_VECTOR(1 downto 0);
        OUT_EN_Out    : out STD_LOGIC;
        ALU_A_Out     : out STD_LOGIC;
        ALUOp_Out     : out STD_LOGIC_VECTOR(2 downto 0);
        WE1_Out       : out STD_LOGIC;
        WE2_Out       : out STD_LOGIC;
        MEM_R_Out     : out STD_LOGIC;
        PCSRC_Out     : out STD_LOGIC;

        PCPlus4_Out   : out STD_LOGIC_VECTOR(31 downto 0);
        Rdata1_Out    : out STD_LOGIC_VECTOR(31 downto 0);
        Rdata2_Out    : out STD_LOGIC_VECTOR(31 downto 0);
        Raddr1_Out    : out STD_LOGIC_VECTOR(2 downto 0);
        Raddr2_Out    : out STD_LOGIC_VECTOR(2 downto 0);
        Rdst_Out      : out STD_LOGIC_VECTOR(2 downto 0);
        Imm_Out       : out STD_LOGIC_VECTOR(31 downto 0);
        IN_Out        : out STD_LOGIC_VECTOR(31 downto 0);
        ALU_B_Out     : out STD_LOGIC;
        WB_Wdata_Sel_Out  : out STD_LOGIC_VECTOR(2 downto 0);
        WB_Waddr_Sel_Out  : out STD_LOGIC_VECTOR(1 downto 0)
    );
end D_E_Register;
architecture D_E_ARCH of D_E_Register is

    signal CCR_EN_Reg     : STD_LOGIC := '0';
    signal RTI_Reg        : STD_LOGIC := '0';
    signal INT_Jump_Reg   : STD_LOGIC := '0';
    signal INT_IDX_Reg    : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
    signal MEM_W_Reg      : STD_LOGIC := '0';
    signal Branch_Reg     : STD_LOGIC := '0';
    signal Mem_Wdata_Sel_Reg  : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal MemRead_Reg    : STD_LOGIC := '0';
    signal J_Type_Reg     : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
    signal Stack_en_Reg   : STD_LOGIC := '0';
    signal Stack_inc_Reg  : STD_LOGIC := '0';
    signal MEM_OP_Reg     : STD_LOGIC := '0';
    signal MEM_SEL_Reg    : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
    signal OUT_EN_Reg     : STD_LOGIC := '0';
    signal ALU_A_Reg      : STD_LOGIC := '0';
    signal ALUOp_Reg      : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal WE1_Reg        : STD_LOGIC := '0';
    signal WE2_Reg        : STD_LOGIC := '0';
    signal MEM_R_Reg      : STD_LOGIC := '0';
    signal PCSRC_Reg      : STD_LOGIC := '0';


    signal PCPlus4_Reg    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal Rdata1_Reg     : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal Rdata2_Reg     : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal Raddr1_Reg     : STD_LOGIC_VECTOR(2 downto 0)  := (others => '0');
    signal Raddr2_Reg     : STD_LOGIC_VECTOR(2 downto 0)  := (others => '0');
    signal Rdst_Reg       : STD_LOGIC_VECTOR(2 downto 0)  := (others => '0');
    signal Imm_Reg        : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal IN_Reg         : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal ALU_B_Reg      : STD_LOGIC := '0';
    signal WB_Wdata_Sel_Reg: STD_LOGIC_VECTOR(2 downto 0);
    signal WB_Waddr_Sel_Reg: STD_LOGIC_VECTOR(1 downto 0);
begin

 
    process (CLK, RST)
    begin
        if RST = '1' then
            CCR_EN_Reg    <= '0';
            RTI_Reg       <= '0';
            INT_Jump_Reg  <= '0';
            INT_IDX_Reg   <= (others => '0');
            MEM_W_Reg     <= '0';
            Branch_Reg    <= '0';
            Mem_Wdata_Sel_Reg <= "00";
            MemRead_Reg   <= '0';
            J_Type_Reg    <= (others => '0');
            Stack_en_Reg  <= '0';
            Stack_inc_Reg <= '0';
            MEM_OP_Reg    <= '0';
            MEM_SEL_Reg   <= (others => '0');
            OUT_EN_Reg    <= '0';
            ALU_A_Reg     <= '0';
            ALUOp_Reg     <= (others => '0');
            WE1_Reg       <= '0';
            WE2_Reg       <= '0';
            MEM_R_Reg     <= '0';
            PCSRC_Reg     <= '0';

            PCPlus4_Reg <= (others => '0');
            Rdata1_Reg  <= (others => '0');
            Rdata2_Reg  <= (others => '0');
            Raddr1_Reg  <= (others => '0');
            Raddr2_Reg  <= (others => '0');
            Rdst_Reg    <= (others => '0');
            Imm_Reg     <= (others => '0');
            IN_Reg      <= (others => '0');
            ALU_B_Reg   <= '0';
            WB_Wdata_Sel_Reg <= "000";
            WB_Waddr_Sel_Reg <= "00";
        elsif rising_edge(CLK) then
            if EN = '1' then
                CCR_EN_Reg    <= CCR_EN;
                RTI_Reg       <= RTI;
                INT_Jump_Reg  <= INT_Jump;
                INT_IDX_Reg   <= INT_IDX;
                MEM_W_Reg     <= MEM_W;
                Branch_Reg    <= Branch;
                Mem_Wdata_Sel_Reg <= Mem_Wdata_Sel;
                MemRead_Reg   <= MemRead;
                J_Type_Reg    <= J_Type;
                Stack_en_Reg  <= Stack_en;
                Stack_inc_Reg <= Stack_inc;
                MEM_OP_Reg    <= MEM_OP;
                MEM_SEL_Reg   <= MEM_SEL;
                OUT_EN_Reg    <= OUT_EN;
                ALU_A_Reg     <= ALU_A;
                ALUOp_Reg     <= ALUOp;
                WE1_Reg       <= WE1;
                WE2_Reg       <= WE2;
                MEM_R_Reg     <= MEM_R;
                PCSRC_Reg     <= PCSRC;

                -- Data latch
                PCPlus4_Reg <= PCPlus4;
                Rdata1_Reg  <= Rdata1;
                Rdata2_Reg  <= Rdata2;
                Raddr1_Reg  <= Raddr1;
                Raddr2_Reg  <= Raddr2;
                Rdst_Reg    <= Rdst;
                Imm_Reg     <= Imm;
                IN_Reg      <= IN_Port;
                ALU_B_Reg   <= ALU_B;
                WB_Wdata_Sel_Reg <= WB_Wdata_Sel;
                WB_Waddr_Sel_Reg <= WB_Waddr_Sel;
            end if;
        end if;
    end process;

    -- 
    -- flush
    
    CCR_EN_Out    <= '0' when CLR='1' else CCR_EN_Reg;
    RTI_Out       <= '0' when CLR='1' else RTI_Reg;
    INT_Jump_Out  <= '0' when CLR='1' else INT_Jump_Reg;
    INT_IDX_Out   <= (others=>'0') when CLR='1' else INT_IDX_Reg;
    MEM_W_Out     <= '0' when CLR='1' else MEM_W_Reg;
    Branch_Out    <= '0' when CLR='1' else Branch_Reg;
    Mem_Wdata_Sel_Out <= "00" when CLR='1' else Mem_Wdata_Sel_Reg;
    MemRead_Out   <= '0' when CLR='1' else MemRead_Reg;
    J_Type_Out    <= (others=>'0') when CLR='1' else J_Type_Reg;
    Stack_en_Out  <= '0' when CLR='1' else Stack_en_Reg;
    Stack_inc_Out  <= '0' when CLR='1' else Stack_inc_Reg;
    MEM_OP_Out    <= '0' when CLR='1' else MEM_OP_Reg;
    MEM_SEL_Out   <= (others=>'0') when CLR='1' else MEM_SEL_Reg;
    OUT_EN_Out    <= '0' when CLR='1' else OUT_EN_Reg;
    ALU_A_Out     <= '0' when CLR='1' else ALU_A_Reg;
    ALUOp_Out     <= (others=>'0') when CLR='1' else ALUOp_Reg;
    WE1_Out       <= '0' when CLR='1' else WE1_Reg;
    WE2_Out       <= '0' when CLR='1' else WE2_Reg;
    MEM_R_Out     <= '0' when CLR='1' else MEM_R_Reg;
    PCSRC_Out     <= '0' when CLR='1' else PCSRC_Reg;

    PCPlus4_Out <= (others=>'0') when CLR='1' else PCPlus4_Reg;
    Rdata1_Out  <= (others=>'0') when CLR='1' else Rdata1_Reg;
    Rdata2_Out  <= (others=>'0') when CLR='1' else Rdata2_Reg;
    Raddr1_Out  <= (others=>'0') when CLR='1' else Raddr1_Reg;
    Raddr2_Out  <= (others=>'0') when CLR='1' else Raddr2_Reg;
    Rdst_Out    <= (others=>'0') when CLR='1' else Rdst_Reg;
    Imm_Out     <= (others=>'0') when CLR='1' else Imm_Reg;
    IN_Out      <= (others=>'0') when CLR='1' else IN_Reg;
    ALU_B_Out   <= '0' when CLR='1' else ALU_B_Reg;
    WB_Wdata_Sel_Out <= "000" when CLR = '1' else WB_Wdata_Sel_Reg;
    WB_Waddr_Sel_Out <= "00" when CLR = '1' else WB_Waddr_Sel_Reg;
    
end D_E_ARCH;
