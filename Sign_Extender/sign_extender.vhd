library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Sign_Extender is
    Port (
        imm_in  : in  STD_LOGIC_VECTOR(15 downto 0);  
        imm_out : out STD_LOGIC_VECTOR(31 downto 0)   
    );
end Sign_Extender;

architecture Behavioral of Sign_Extender is
begin
    
    imm_out <= std_logic_vector(resize(signed(imm_in), 32));
end Behavioral;