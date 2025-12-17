library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Memory is
    port (
        clk        : in std_logic;
        reset    : in std_logic;
        
        -- Instruction  
        PC_addr    : in std_logic_vector(31 downto 0);  
        instruction: out std_logic_vector(31 downto 0);  
        
        -- Data memory 
        Mem_write  : in std_logic;
        Mem_Read   : in std_logic; 
        Mem_Addr   : in std_logic_vector(31 downto 0);   
        Write_data : in std_logic_vector(31 downto 0);
        Read_data  : out std_logic_vector(31 downto 0);
        
        -- Interrupt  
        intr_vector0 : in std_logic_vector(31 downto 0);  -- Address 0x0 (Reset)
        intr_vector1 : in std_logic_vector(31 downto 0)   -- Address 0x4 (Interrupt)
    );
end entity;

architecture ARCH_Memory of Memory is
    constant MEM_SIZE : integer := 2**20;  
    type memory_array is array (0 to MEM_SIZE - 1) of std_logic_vector(31 downto 0);
    signal mem : memory_array := (
        0 => x"00000000",  -- Reset
        1 => x"00000004",  -- Interrupt 
        others => (others => '0')
    );
    
begin
    --  read for instruction fetch 
    instruction <= mem(to_integer(unsigned(PC_addr)));
    
    -- read for data memory 
    Read_data <= mem(to_integer(unsigned(Mem_Addr)));
    
    -- write
    process(clk)
    begin
        if rising_edge(clk) then
            if reset= '0' then
                -- Reset interrup?
                mem(0) <= intr_vector0;
                mem(1) <= intr_vector1;
            elsif Mem_write = '1' then
                mem(to_integer(unsigned(Mem_Addr))) <= Write_data;
            end if;
        end if;
    end process;
end architecture;