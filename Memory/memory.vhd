library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Memory is
    port (
        clk        : in std_logic;
        reset    : in std_logic;

        -- Data memory 
        Mem_write  : in std_logic;
        Mem_Read   : in std_logic; 
        Mem_Addr   : in std_logic_vector(31 downto 0);   
        Write_data : in std_logic_vector(31 downto 0);
        Read_data  : out std_logic_vector(31 downto 0);
       
    );
end entity;

architecture ARCH_Memory of Memory is
    constant MEM_SIZE : integer := 2**20;  
    type memory_array is array (0 to MEM_SIZE - 1) of std_logic_vector(31 downto 0);
    signal mem : memory_array := (
        others => (others => '0')
    );
    
begin
    -- read for data memory 
    Read_data <= mem(0) when reset = '1' else mem(to_integer(unsigned(Mem_Addr)));
    
    -- write
    process(clk, reset)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                -- leave it in case we use  it later
            elsif Mem_write = '1' then
                mem(to_integer(unsigned(Mem_Addr))) <= Write_data;
            end if;
        end if;
    end process;
end architecture;