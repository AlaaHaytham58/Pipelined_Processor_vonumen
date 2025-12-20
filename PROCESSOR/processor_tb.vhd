LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_1164.all;
use STD.TEXTIO.all;
use IEEE.NUMERIC_STD_UNSIGNED.all;
library std;


ENTITY processor_tb IS
END processor_tb;

ARCHITECTURE testbench OF processor_tb IS
    
    -- Test signals
    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    signal IN_PORT : std_logic_vector(31 downto 0) := (others => '0');
    signal OUT_PORT : std_logic_vector(31 downto 0);
    signal INTR_IN : std_logic := '0';
    signal PC_debug : std_logic_vector(31 downto 0);
    signal instruction_debug : std_logic_vector(31 downto 0);
    signal ALU_result_debug : std_logic_vector(31 downto 0);
    signal CCR_debug : std_logic_vector(2 downto 0);
    signal endoffile : bit := '0';

    signal  dataread : integer;
    signal linenumber : integer:=1; --line number of the file read or written.
    signal rd_en : std_logic := '0';
    signal wr_en: std_logic := '1';
    -- Clock period
    constant CLK_PERIOD : time := 10 ns;

BEGIN

    -- Instantiate the processor
    UUT: entity work.processor
        PORT MAP(
            clk => clk,
            reset => reset,
            IN_PORT => IN_PORT,
            OUT_PORT => OUT_PORT,
            INTR_IN => INTR_IN,
            PC_debug => PC_debug,
            instruction_debug => instruction_debug,
            ALU_result_debug => ALU_result_debug,
            CCR_debug => CCR_debug
        );

    -- Clock generation
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;


    -- Test stimulus
    stim_process: process
    begin
        -- Initialize
        reset <= '1';
        IN_PORT <= x"00000030";  -- Test input for IN R0
        wait for CLK_PERIOD * 2;

        -- Release reset
        reset <= '0';
        wait for CLK_PERIOD;

        -- Run the program
        for i in 1 to 50 loop  -- Run for 50 clock cycles
            wait for CLK_PERIOD;

            -- Monitor progress
            if PC_debug = x"0000000C" then  -- End of program
                report "Program completed at PC = 0x0C";
                exit;
            end if;
        end loop;

        -- Check final results
        report "Test completed";
        -- report "Final PC: " & to_hstring(PC_debug);
        -- report "Final OUT_PORT: " & to_hstring(OUT_PORT);
        --report "Final CCR: " & to_string(CCR_debug);

        wait;
    end process;

END testbench;