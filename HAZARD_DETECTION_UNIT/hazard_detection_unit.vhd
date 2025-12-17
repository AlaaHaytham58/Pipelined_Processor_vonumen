library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Hazard_Detection_Unit is
    Port (
        -- Inputs
        ID_EX_MemRead : in STD_LOGIC;
        ID_EX_Rdst    : in STD_LOGIC_VECTOR(2 downto 0);
        IF_ID_Rsrc1   : in STD_LOGIC_VECTOR(2 downto 0);
        IF_ID_Rsrc2   : in STD_LOGIC_VECTOR(2 downto 0);
        Branch        : in STD_LOGIC;
        Jump          : in STD_LOGIC;
        
        -- Outputs
        PC_Write      : out STD_LOGIC;
        IF_ID_Write   : out STD_LOGIC;
        Control_Mux   : out STD_LOGIC  -- 0: Normal, 1: Insert NOP
    );
end Hazard_Detection_Unit;

architecture Hazard_detection_arch of Hazard_Detection_Unit is
begin
    process(ID_EX_MemRead, ID_EX_Rdst, IF_ID_Rsrc1, IF_ID_Rsrc2, Branch, Jump)
    begin
        PC_Write <= '1';
        IF_ID_Write <= '1';
        Control_Mux <= '0';
        
        -- Load-Use 
        if ID_EX_MemRead = '1' then
            if (ID_EX_Rdst = IF_ID_Rsrc1) or (ID_EX_Rdst = IF_ID_Rsrc2) then
                -- Stall 
                PC_Write <= '0';
                IF_ID_Write <= '0';
                Control_Mux <= '1';  -- Insert NOP in ID/EX
            end if;
        end if;
        
        -- Control Hazard(Branch/Jmp)
        if Branch = '1' or Jump = '1' then
            -- Flush the instruction after branch/jmp
            Control_Mux <= '1';
        end if;
    end process;
end Hazard_detection_arch;