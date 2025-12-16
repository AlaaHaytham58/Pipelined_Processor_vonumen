
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Memory is
    generic (
        Address_bits : integer := 12;  
        Data_width   : integer := 32   
    );
    port (
        clk        : in std_logic;
        reset_n    : in std_logic;
        Mem_write  : in std_logic;
        Mem_Read   : in std_logic; 
        Mem_Addr   : in std_logic_vector(Address_bits - 1 downto 0);
        Write_data : in std_logic_vector(Data_width - 1 downto 0);
        Rdata      : out std_logic_vector(Data_width - 1 downto 0)
    );
end entity;

architecture ARCH_Memory of Memory is
    type memory_array is array (0 to 2**Address_bits - 1) of std_logic_vector(Data_width - 1 downto 0);
    signal mem : memory_array := (others => (others => '0'));

begin
    -- read
    process(Mem_Addr)
    begin
        Rdata <= mem(to_integer(unsigned(Mem_Addr)));
    end process;

    --  write
    process(clk)
    begin
        if rising_edge(clk) then
            if Mem_write = '1' then
                mem(to_integer(unsigned(Mem_Addr))) <= Write_data;
            end if;
        end if;
    end process;
end architecture;
