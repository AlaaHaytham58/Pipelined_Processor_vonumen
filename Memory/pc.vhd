library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC_Unit is
    port (
        clk         : in  std_logic;
        reset_n     : in  std_logic;
        stall       : in  std_logic;   
        int         : in  std_logic;
        PCSrc       : in  std_logic; -- iassume  pcsrc equal 1 yb2a branch mesh motakda a7san a3mlha keda wala fakes we handle in mux?
        ImmExt      : in  std_logic_vector(31 downto 0);
        M0          : in  std_logic_vector(31 downto 0);
        M1          : in  std_logic_vector(31 downto 0);
        PC_out      : out std_logic_vector(31 downto 0)
    );
end entity;

architecture Behavioral of PC_Unit is
    signal PC         : std_logic_vector(31 downto 0) := (others => '0');
    signal PC_plus4   : std_logic_vector(31 downto 0);
    signal PC_branch  : std_logic_vector(31 downto 0);
    signal NextPC     : std_logic_vector(31 downto 0);

begin
    PC_plus4  <= std_logic_vector(unsigned(PC) + 4);
    PC_branch <= std_logic_vector(unsigned(PC) + unsigned(ImmExt));
    NextPC    <= PC_branch when PCSrc = '1' else PC_plus4;
    process(clk, reset_n)
    begin
        if reset_n = '0'  then
            PC <= M0;                           
        elsif rising_edge(clk) then
            if int = '1' then
                PC <= M1;   
            elsif stall = '0' then
                PC <= NextPC;                   
            else
                PC <= PC;               
            end if;
        end if;
    end process;

    PC_out <= PC;

end architecture;
