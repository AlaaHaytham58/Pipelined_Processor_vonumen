library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Forward_unit is
    Port (
        -- Inputs
        EX_MEM_RegWrite : in STD_LOGIC;
        MEM_WB_RegWrite : in STD_LOGIC;
        EX_MEM_Rdst     : in STD_LOGIC_VECTOR(2 downto 0);
        MEM_WB_Rdst     : in STD_LOGIC_VECTOR(2 downto 0);
        ID_EX_Rsrc1     : in STD_LOGIC_VECTOR(2 downto 0);
        ID_EX_Rsrc2     : in STD_LOGIC_VECTOR(2 downto 0);
        
        -- Outputs
        ForwardA        : out STD_LOGIC_VECTOR(1 downto 0);  -- 00: Normal, 01: EX/MEM, 10: MEM/WB
        ForwardB        : out STD_LOGIC_VECTOR(1 downto 0)
    );
end Forward_unit;

architecture forward_unit_arch of Forward_unit is
begin
    process(EX_MEM_RegWrite, MEM_WB_RegWrite, EX_MEM_Rdst, MEM_WB_Rdst, ID_EX_Rsrc1, ID_EX_Rsrc2)
    begin
        ForwardA <= "00";
        ForwardB <= "00";
        
         --forwarding to ALU input A
        if EX_MEM_RegWrite = '1' and (EX_MEM_Rdst /= "000") then
            if EX_MEM_Rdst = ID_EX_Rsrc1 then
                ForwardA <= "01";  
            end if;
            if EX_MEM_Rdst = ID_EX_Rsrc2 then
                ForwardB <= "01";  
            end if;
        end if;
        
        -- MEM/WB forwarding to ALU input A (lower priority)
        if MEM_WB_RegWrite = '1' and (MEM_WB_Rdst /= "000") then
            if not(EX_MEM_RegWrite = '1' and (EX_MEM_Rdst /= "000") and (EX_MEM_Rdst = ID_EX_Rsrc1)) then
                if MEM_WB_Rdst = ID_EX_Rsrc1 then
                    ForwardA <= "10";  -- Forward from MEM/WB
                end if;
            end if;
            if not(EX_MEM_RegWrite = '1' and (EX_MEM_Rdst /= "000") and (EX_MEM_Rdst = ID_EX_Rsrc2)) then
                if MEM_WB_Rdst = ID_EX_Rsrc2 then
                    ForwardB <= "10";  -- Forward from MEM/WB
                end if;
            end if;
        end if;
    end process;
end architecture forward_unit_arch;
