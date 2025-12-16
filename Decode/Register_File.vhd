LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY Register_file IS
	PORT(	
            clk,rst,WE1,WE2 : IN std_logic;
            Raddr1,Raddr2: IN std_logic_vector(2 downto 0);
            Waddr1, Waddr2: IN std_logic_vector(2 downto 0);
            Wdata1, Wdata2: IN std_logic_vector (15 downto 0);
            Rdata1,Rdata2: OUT std_logic_vector (15 downto 0)
        );
END Register_file;

ARCHITECTURE Register_file_arch OF Register_file IS
    type registerFile is array(0 to 7) of std_logic_vector(31 downto 0);
    signal registers : registerFile := (7 downto 0 => ( x"00000000"));
BEGIN

    Rdata1 <= registers(to_integer(unsigned((Raddr1))));
    Rdata2 <= registers(to_integer(unsigned((Raddr2))));

    process (clk, rst)
    begin
        if (rst = '1') then
            registers <= (7 downto 0 => ( x"00000000"));
        elsif (CLK'event and CLK = '1') then
            if (WE1 = '1') then 
                registers(to_integer(unsigned((Waddr1)))) <= Wdata1;
            end if;
            
            if (WE2 = '1') then 
                registers(to_integer(unsigned((Waddr2)))) <= Wdata2;
            end if;
        end if;
    end process;

END Register_file_arch;