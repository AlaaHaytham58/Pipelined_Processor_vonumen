library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity M_W_Register is
    Port (
        CLK           : in  STD_LOGIC;
        RST           : in  STD_LOGIC;
        EN            : in  STD_LOGIC;
        -- Inputs
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
        Imm           : in STD_LOGIC_VECTOR(31 downto 0);
        OUT_EN        : in STD_LOGIC;
        CLR           : in STD_LOGIC; 

        -- Outputs;
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
        Imm_Out       : out STD_LOGIC_VECTOR(31 downto 0);
        OUT_EN_Out    : out STD_LOGIC
    );
end M_W_Register;

architecture Behavioral of M_W_Register is
    -- Internal registers to store input values
        signal ALURes_Reg    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
        signal Raddr1_Reg    : STD_LOGIC_VECTOR(2 downto 0)  := (others => '0');
        signal Raddr2_Reg    : STD_LOGIC_VECTOR(2 downto 0)  := (others => '0');
        signal Rdst_Reg      : STD_LOGIC_VECTOR(2 downto 0)  := (others => '0');
        signal RT_ADDR_Reg   : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
        signal Rdata1_Reg    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
        signal Rdata2_Reg    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
        signal WE1_Reg       : STD_LOGIC := '0';
        signal WE2_Reg       : STD_LOGIC := '0';
        signal IN_Port_Reg   : STD_LOGIC := '0';
        signal LD_DATA_Reg   : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
        signal Imm_Reg       : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
        signal OUT_EN_Reg    : STD_LOGIC := '0';

begin
    -- Register inputs on rising edge
    process (CLK, RST)
    begin
        if RST = '1' then
            ALURes_Reg    <= (others => '0');
            Raddr1_Reg    <= (others => '0');
            Raddr2_Reg    <= (others => '0');
            Rdst_Reg      <= (others => '0');
            RT_ADDR_Reg   <= (others => '0');
            Rdata1_Reg    <= (others => '0');
            Rdata2_Reg    <= (others => '0');
            WE1_Reg       <= '0';
            WE2_Reg       <= '0';
            IN_Port_Reg   <= '0';
            LD_DATA_Reg   <= (others => '0');
            Imm_Reg       <= (others => '0');
            OUT_EN_Reg    <= '0';
        elsif rising_edge(CLK) then
            if EN = '1' then
                ALURes_Reg    <= ALURes;
                Raddr1_Reg    <= Raddr1;
                Raddr2_Reg    <= Raddr2;
                Rdst_Reg      <= Rdst;
                RT_ADDR_Reg   <= RT_ADDR;
                Rdata1_Reg    <= Rdata1;
                Rdata2_Reg    <= Rdata2;
                WE1_Reg       <= WE1;
                WE2_Reg       <= WE2;
                IN_Port_Reg   <= IN_Port;
                LD_DATA_Reg   <= LD_DATA;
                Imm_Reg       <= Imm;
                OUT_EN_Reg    <= OUT_EN;
            end if;
        end if;
    end process;

    -- Combinational outputs (continuous assignments)
    ALURes_Out    <= ALURes_Reg;
    Raddr1_Out    <= Raddr1_Reg;
    Raddr2_Out    <= Raddr2_Reg;
    Rdst_Out      <= Rdst_Reg;
    RT_ADDR_Out   <= RT_ADDR_Reg;
    Rdata1_Out    <= Rdata1_Reg;
    Rdata2_Out    <= Rdata2_Reg;
    WE1_Out       <= WE1_Reg;
    WE2_Out       <= WE2_Reg;
    IN_Port_Out   <= IN_Port_Reg;
    LD_DATA_Out   <= LD_DATA_Reg;
    Imm_Out       <= Imm_Reg;
    OUT_EN_Out    <= OUT_EN_Reg;

end Behavioral;