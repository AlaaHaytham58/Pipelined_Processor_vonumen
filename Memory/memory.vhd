library ieee;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_1164.all;
use STD.TEXTIO.all;
use ieee.numeric_std.all;

entity Memory is
    port (
        clk        : in std_logic;
        reset    : in std_logic;
        -- Data memory
        Mem_write  : in std_logic;
        Mem_Read   : in std_logic;
        RST_Addr   : out std_logic_vector(31 downto 0);
        Mem_Addr   : in std_logic_vector(31 downto 0);
        Write_data : in std_logic_vector(31 downto 0);
        Read_data  : out std_logic_vector(31 downto 0)
    );
end entity;

architecture ARCH_Memory of Memory is
    constant MEM_SIZE : integer := 2**10;
    type memory_array is array (0 to MEM_SIZE - 1) of std_logic_vector(31 downto 0);

    IMPURE FUNCTION GET_START_ADDR RETURN std_logic_vector IS
		VARIABLE TEXT_LINE : LINE;
        VARIABLE STARTING_ADDRESS: std_logic_vector(31 downto 0);
        VARIABLE BINARY_TEXT_LINE : BIT_VECTOR(31 DOWNTO 0);
		FILE MEMORY_FILE: TEXT;
    BEGIN
        -- OPEN FILE
        FILE_OPEN(MEMORY_FILE, "ASSEMBLER/two_opreand.mem",  READ_MODE);

        -- READ FIRST 32 BITS OF STARTING ADDRESS
        READLINE(MEMORY_FILE, TEXT_LINE);
        READ(TEXT_LINE, BINARY_TEXT_LINE);

	    -- REPORT "TEXT_LINE: "& INTEGER'IMAGE(TO_INTEGER(UNSIGNED(TO_STDLOGICVECTOR(BINARY_TEXT_LINE))));
        STARTING_ADDRESS := TO_STDLOGICVECTOR(BINARY_TEXT_LINE);
        FILE_CLOSE(MEMORY_FILE);
        RETURN STARTING_ADDRESS;
    END FUNCTION GET_START_ADDR;

    IMPURE FUNCTION FILL_MEMORY RETURN memory_array IS
		VARIABLE MEMORY_CONTENT : memory_array;
		VARIABLE TEXT_LINE : LINE;
		VARIABLE COUNT: INTEGER;
		VARIABLE I: INTEGER;
        VARIABLE STARTING_ADDRESS: STD_LOGIC_VECTOR(31 DOWNTO 0);
        VARIABLE BINARY_TEXT_LINE : BIT_VECTOR(31 DOWNTO 0);
		FILE MEMORY_FILE: TEXT;
    BEGIN
       -- OPEN FILE
        FILE_OPEN(MEMORY_FILE, "ASSEMBLER/two_opreand.mem",  READ_MODE);

        -- READ FIRST 32 BITS OF STARTING ADDRESS
        READLINE(MEMORY_FILE, TEXT_LINE);
        READ(TEXT_LINE, BINARY_TEXT_LINE);
	    -- REPORT "TEXT_LINE: "& INTEGER'IMAGE(TO_INTEGER(UNSIGNED(TO_STDLOGICVECTOR(BINARY_TEXT_LINE))));
        --STARTING_ADDRESS(31 DOWNTO 0) := TO_STDLOGICVECTOR(BINARY_TEXT_LINE);

        COUNT := 0;

        WHILE NOT ENDFILE(MEMORY_FILE) LOOP
            READLINE(MEMORY_FILE, TEXT_LINE);
            READ(TEXT_LINE, BINARY_TEXT_LINE);
            -- REPORT "TEXT_LINE INSIDE MEMORY LOOP: "& INTEGER'IMAGE(TO_INTEGER(UNSIGNED(TO_STDLOGICVECTOR(BINARY_TEXT_LINE))));
            MEMORY_CONTENT(COUNT) := TO_STDLOGICVECTOR(BINARY_TEXT_LINE);
            COUNT := COUNT + 1;
        END lOOP;

        FILE_CLOSE(MEMORY_FILE);
        RETURN MEMORY_CONTENT;

    END FUNCTION FILL_MEMORY;
    signal start_addr : std_logic_vector(31 downto 0) := GET_START_ADDR;
    signal mem : memory_array := FILL_MEMORY;
begin
    -- read for data memory
    Read_data <= mem(to_integer(unsigned(Mem_Addr)));

    RST_Addr <= start_addr;

    --mem(0) when reset = '1' else
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