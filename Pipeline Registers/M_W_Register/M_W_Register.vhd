library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity M_W_Register is
    Port (
        CLK           : in  STD_LOGIC;
        RST           : in  STD_LOGIC;
        EN            : in  STD_LOGIC;
        -- Inputs
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
        STACK         : in STD_LOGIC;
        BR_ADDR       : in STD_LOGIC_VECTOR(31 downto 0);
        MEM_W         : in STD_LOGIC;
        Imm           : in STD_LOGIC_VECTOR(15 downto 0);
        OUT_EN        : in STD_LOGIC;
        CLR           : in STD_LOGIC; 

        -- Outputs;
        MEM_OP_Out    : out STD_LOGIC;
        MEM_SEL_Out   : out STD_LOGIC;
        MEM_R_Out     : out STD_LOGIC;
        ALURes_Out    : out STD_LOGIC_VECTOR(31 downto 0);
        Raddr1_Out    : out STD_LOGIC_VECTOR(2 downto 0);
        Raddr2_Out    : out STD_LOGIC_VECTOR(2 downto 0);
        Rdst_Out      : out STD_LOGIC_VECTOR(2 downto 0);
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
end M_W_Register;

architecture Behavioral of M_W_Register is
    -- Internal registers to store input values
        signal MEM_OP_Reg    : STD_LOGIC := '0';
        signal MEM_SEL_Reg   : STD_LOGIC := '0';
        signal MEM_R_Reg     : STD_LOGIC := '0';
        signal ALURes_Reg    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
        signal Raddr1_Reg    : STD_LOGIC_VECTOR(2 downto 0)  := (others => '0');
        signal Raddr2_Reg    : STD_LOGIC_VECTOR(2 downto 0)  := (others => '0');
        signal Rdst_Reg      : STD_LOGIC_VECTOR(2 downto 0)  := (others => '0');
        signal STACK_Reg     : STD_LOGIC := '0';
        signal BR_ADDR_Reg   : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
        signal Rdata1_Reg    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
        signal Rdata2_Reg    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
        signal WriteData_Reg : STD_LOGIC := '0';
        signal WE1_Reg       : STD_LOGIC := '0';
        signal WE2_Reg       : STD_LOGIC := '0';
        signal MEM_W_Reg     : STD_LOGIC := '0';
        signal IN_Port_Reg   : STD_LOGIC := '0';
        signal Imm_Reg       : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
        signal OUT_EN_Reg    : STD_LOGIC := '0';

begin
    -- Register inputs on rising edge
    process (CLK, RST)
    begin
        if RST = '1' then
            MEM_OP_Reg    <= '0';
            MEM_SEL_Reg   <= '0';
            MEM_R_Reg     <= '0';
            ALURes_Reg    <= (others => '0');
            Raddr1_Reg    <= (others => '0');
            Raddr2_Reg    <= (others => '0');
            Rdst_Reg      <= (others => '0');
            STACK_Reg     <= '0';
            BR_ADDR_Reg   <= (others => '0');
            Rdata1_Reg    <= (others => '0');
            Rdata2_Reg    <= (others => '0');
            WriteData_Reg <= '0';
            WE1_Reg       <= '0';
            WE2_Reg       <= '0';
            MEM_W_Reg     <= '0';
            IN_Port_Reg   <= '0';
            Imm_Reg       <= (others => '0');
            OUT_EN_Reg    <= '0';
        elsif rising_edge(CLK) then
            if EN = '1' then
                MEM_OP_Reg    <= MEM_OP;
                MEM_SEL_Reg   <= MEM_SEL;
                MEM_R_Reg     <= MEM_R;
                ALURes_Reg    <= ALURes;
                Raddr1_Reg    <= Raddr1;
                Raddr2_Reg    <= Raddr2;
                Rdst_Reg      <= Rdst;
                STACK_Reg     <= STACK;
                BR_ADDR_Reg   <= BR_ADDR;
                Rdata1_Reg    <= Rdata1;
                Rdata2_Reg    <= Rdata2;
                WriteData_Reg <= WriteData;
                WE1_Reg       <= WE1;
                WE2_Reg       <= WE2;
                MEM_W_Reg     <= MEM_W;
                IN_Port_Reg   <= IN_Port;
                Imm_Reg       <= Imm;
                OUT_EN_Reg    <= OUT_EN;
            end if;
        end if;
    end process;

    -- Combinational outputs (continuous assignments)
    MEM_OP_Out    <= '0' when CLR = '1' else MEM_OP_Reg;
    MEM_SEL_Out   <= '0' when CLR = '1' else MEM_SEL_Reg;
    MEM_R_Out     <= '0' when CLR = '1' else MEM_R_Reg;
    ALURes_Out    <= (others => '0') when CLR = '1' else ALURes_Reg;
    Raddr1_Out    <= (others => '0') when CLR = '1' else Raddr1_Reg;
    Raddr2_Out    <= (others => '0') when CLR = '1' else Raddr2_Reg;
    Rdst_Out      <= (others => '0') when CLR = '1' else Rdst_Reg;
    STACK_Out     <= '0' when CLR = '1' else STACK_Reg;
    BR_ADDR_Out   <= (others => '0') when CLR = '1' else BR_ADDR_Reg;
    Rdata1_Out    <= (others => '0') when CLR = '1' else Rdata1_Reg;
    Rdata2_Out    <= (others => '0') when CLR = '1' else Rdata2_Reg;
    WriteData_Out <= '0' when CLR = '1' else WriteData_Reg;
    WE1_Out       <= '0' when CLR = '1' else WE1_Reg;
    WE2_Out       <= '0' when CLR = '1' else WE2_Reg;
    MEM_W_Out     <= '0' when CLR = '1' else MEM_W_Reg;
    IN_Port_Out   <= '0' when CLR = '1' else IN_Port_Reg;
    Imm_Out       <= (others => '0') when CLR = '1' else Imm_Reg;
    OUT_EN_Out    <= '0' when CLR = '1' else OUT_EN_Reg;

end Behavioral;