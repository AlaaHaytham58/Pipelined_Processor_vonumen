library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity F_D_Register is
    Port (
        CLK         : in  STD_LOGIC;
        RST         : in  STD_LOGIC;
        EN          : in  STD_LOGIC;
        CLR         : in  STD_LOGIC;
        -- Inputs
        Inst        : in  STD_LOGIC_VECTOR(31 downto 0);
        PCPlus4     : in  STD_LOGIC_VECTOR(31 downto 0);
        IN_Port     : in  STD_LOGIC_VECTOR(31 downto 0);
        -- Outputs
        Inst_Out    : out STD_LOGIC_VECTOR(31 downto 0);
        PCPlus4_Out : out STD_LOGIC_VECTOR(31 downto 0);
        IN_Out      : out STD_LOGIC_VECTOR(31 downto 0)
    );
end F_D_Register;

architecture FETCH_DECODE_ARCH of F_D_Register is

    -- Internal registers
    signal Inst_Reg    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal PCPlus4_Reg : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal IN_Reg      : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

begin

    -- Sequential logic
    process (CLK, RST)
    begin
        if RST = '1' then
            Inst_Reg    <= (others => '0');
            PCPlus4_Reg <= (others => '0');
            IN_Reg      <= (others => '0');
        elsif rising_edge(CLK) then
            if (CLR = '1')then
                Inst_Reg    <= (others => '0');
                PCPlus4_Reg <= (others => '0');
                IN_Reg      <= (others => '0');
            elsif EN = '1' then
                Inst_Reg    <= Inst;
                PCPlus4_Reg <= PCPlus4;
                IN_Reg      <= IN_Port;
            end if;
        end if;
    end process;

    -- Output logic with flush
    Inst_Out    <= Inst_Reg;
    PCPlus4_Out <= PCPlus4_Reg;
    IN_Out      <=  IN_Reg;

end FETCH_DECODE_ARCH;
