LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY Control_Unit IS
	PORT(	
            --Inputs
            opcode: IN std_logic_vector(6 downto 0);
            HW_INT: IN std_logic;
            SW_INT: IN std_logic;

            -- Rdst vs Rsrc mux selector
            Raddr_Sel: OUT STD_LOGIC; -- 0: Rsrc, 1: Rdst

            --Execute Signals
            RTI,Branch: OUT std_logic;
            Int_Jump_Sel: OUT std_logic;                -- 0 : IMM, 1: INTERRUPT
            Int_Idx : OUT STD_LOGIC_VECTOR(1 downto 0); -- 00: N/A, 01: 1, 10: 2, 11: 3
            J_Type: OUT STD_LOGIC_VECTOR(1 downto 0);   -- 00: Z, 01: N, 10: C, 11: 1
            ALU_A, ALU_B: OUT STD_LOGIC;                -- 0 : Rdata1/Rdata2, 1: Rdata2/Imm
            ALU_Op: OUT STD_LOGIC_VECTOR(2 downto 0);   -- REFER TO THE TABLE IN THE REPORT
            CCR_En: OUT STD_LOGIC;

            --Memory Signals
            Mem_Write_En, Mem_Read_En,Stack_En, PCsrc: OUT std_logic;
            Stack_Inc, Stack_Dec: OUT std_logic;             -- 0: +4, 1: -4
            Mem_Op: OUT std_logic;
            Mem_Addr_Sel: OUT STD_LOGIC_VECTOR(1 downto 0);  -- 00: PC 01: ALURes 10: SP  
            Mem_Write_Sel: OUT STD_LOGIC_VECTOR(1 downto 0); -- 00: Rdata1 01: Rdata2 10: PCPlus4
            
            --Write Back Signals
            WE1, WE2: OUT std_logic;

            -- 00: Rdst, 01: Raddr1, 10: Raddr2, 11: ALURes
            WB_Wadrr_Sel: OUT STD_LOGIC_VECTOR(1 downto 0); 
            OUT_En : OUT STD_LOGIC;

             -- 000: ALURes, 001: Rdata1, 010: Rdata2, 011: IMM, 100: ALURes, 101: LD_Data, 110: IN, 111: N/A
            WB_Wdata_Sel: OUT STD_LOGIC_VECTOR(2 downto 0); 

            -- HLT
            HLT : OUT STD_LOGIC
        );
END Control_Unit;

ARCHITECTURE Control_Unit_arch OF Control_Unit IS
BEGIN
    process(opcode) begin
        -- Default Values
        Raddr_Sel <= '0';

        RTI <= '0';
        Branch <= '0';
        Int_Idx <= "00";
        Int_Jump_Sel <= '0'; J_Type <= "00";
        ALU_A <= '0'; ALU_B <= '0';
        ALU_Op <= "000";
        CCR_En <= '0';

        Mem_Write_En <= '0'; Mem_Read_En <= '0'; Stack_En <= '0'; PCsrc <= '0';
        Stack_Inc <= '0'; Mem_Op <= '0'; Stack_Dec <= '0';
        Mem_Addr_Sel <= "00";
        Mem_Write_Sel <= "00";

        WE1 <= '0'; WE2 <= '0';
        WB_Wadrr_Sel <= "00";    
        WB_Wdata_Sel <= "000";
        OUT_en <= '0';     

        HLT <= '0';

        -- Higher priority to HW interrupt
            if (HW_INT = '1') then
                Int_Jump_Sel <= '1'; 
                Int_Idx <= "01";
                Branch <= '1';
            else 
                -- First 4 bits are fixed
                Mem_Op <= opcode(6);
                PCsrc  <= opcode(5);
                CCR_En <= opcode(4);
                WE1    <= opcode(3);

                -- Decode based on operation type
                case(opcode(6 downto 5)) is
                    -- ALU and Rtype operations
                    when "00" =>
                        -- ALU operations
                        if (opcode(4) = '1') then
                            -- Set opcode
                            ALU_Op <= opcode(2 downto 0);

                            -- One operand operations read from Rdst otherwise from Rsrc
                            if (opcode(2) = '1') then 
                                Raddr_Sel <= '1';
                            else
                                Raddr_Sel <= '0';
                            end if;

                            -- IADD takes immediate  in B, otherwise, rsrc2
                            if (opcode(2 downto 0) = "101") then 
                                ALU_B <= '1';
                            else
                                ALU_B <= '0';
                            end if;
                        else
                        -- Rtype operations

                            if (opcode(2 downto 0) = "001") then
                                HLT <= '1';
                            else 
                                HLT <= '0';
                            end if;

                            -- Read Rsrc for move otherwise read Rdst (or don't care for operations that don't use rdata1)
                            if (opcode(2 downto 0) = "011") then 
                                Raddr_Sel <= '0';
                            else 
                                Raddr_Sel <= '1'; 
                            end if;

                            -- Write in Rdst for operations with Write back
                            WB_Wadrr_Sel <= "00";

                            -- For writing to OUT port in write operations
                            if (opcode(2 downto 0) = "010") then 
                                OUT_En <= '1';
                            else 
                                OUT_En <= '0';
                            end if;

                            -- To write back data for Swap
                            if (opcode(2 downto 0) = "101") then 
                                WE2 <= '1';
                                WB_Wdata_Sel <= "010";
                            else
                                WE2 <= '0';
                            end if;

                            -- WB data selection: Imm in the case of LDM, IN for IN instruction, Rdata2 for swap ,Rdata1 otherwise
                            if (opcode(2 downto 0) = "110") then 
                                WB_Wdata_Sel <= "011";
                            elsif (opcode(2 downto 0) = "001") then
                                WB_Wdata_Sel <= "110";
                            elsif (opcode(2 downto 0) = "101") then
                                WB_Wdata_Sel <= "010";
                                WB_Wadrr_Sel <= "01";
                            else
                                WB_Wdata_Sel <= "001";
                            end if;
                                
                        end if;    

                    -- Branch Operations                       
                    when "01" =>
                        J_Type <= opcode(1 downto 0);
                        Branch <= '1';
                    -- Memory Operations
                    when "10" =>
                        -- Choose ALURes or SP
                        Mem_Addr_Sel <= opcode(2 downto 1);

                        -- Enable MemWrite for push and std
                        Mem_Write_En <= opcode(0);

                        -- Enable MemRead for op and ldd
                        Mem_Read_En <= not opcode(0);

                        -- Enable SP for push pop
                        Stack_En <= not opcode(1);

                        -- Choose increment or decrement SP
                        Stack_Inc <= not opcode(0);
                        Stack_Dec <=  opcode(0);
                        -- for load and store, ALU operands are rsrc2, Imm
                        ALU_A <= '1';
                        ALU_B <= '1';

                        -- to add offset and rsrc2 for load and store
                        ALU_OP <= "001";

                        -- to write back LD_Data for pop and ldd
                        WB_Wdata_Sel <= "101";

                        WB_Wadrr_Sel <= "00";

                    -- Branch with memory operations
                    when "11" =>
                        -- Branch during Execute in Call and INT
                        branch <= opcode(0);

                        -- Branching is always unconditional
                        J_Type <= "11";
                        
                        -- Choose intterupt or immediate for call/int (don't care otherwise)
                        Int_Jump_Sel <= opcode(1);

                        -- Choose the address that the interrupt jumps to (don't care if operation is not INT)
                        if (SW_INT = '0') then
                            Int_Idx <= "10";
                        else 
                            Int_Idx <= "11";
                        end if;

                        -- Choose Stack pointer in Memory Stage
                        Mem_Addr_Sel <= "10";

                        -- Enable MemWrite for call, int
                        Mem_Write_En <= opcode(0);

                        -- Enable MemRead for RET/RTI
                        Mem_Read_En <= not opcode(0);

                        -- Enable SP 
                        Stack_En <= '1';

                        -- Choose increment or decrement SP
                        Stack_Inc <= opcode(0);
                        Stack_Dec <= not opcode(0);
                        RTI <= opcode(1) and (not opcode(0));
                    when others =>
                end case;
            end if;
    end process;

END Control_Unit_arch;