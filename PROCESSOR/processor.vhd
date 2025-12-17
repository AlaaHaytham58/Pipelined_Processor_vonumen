LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY processor IS
    PORT(
        clk       : IN std_logic;
        reset     : IN std_logic;
        
        -- I/O Ports
        IN_PORT   : IN std_logic_vector(31 downto 0);
        OUT_PORT  : OUT std_logic_vector(31 downto 0);
        
        -- Interrupt signals
        INTR_IN   : IN std_logic;
        
        -- debugging
        PC_debug       : OUT std_logic_vector(31 downto 0);
        instruction_debug : OUT std_logic_vector(31 downto 0);
        ALU_result_debug : OUT std_logic_vector(31 downto 0);
        CCR_debug       : OUT std_logic_vector(3 downto 0)
    );
END processor;

ARCHITECTURE processor_arch OF processor IS
    
    -- Constants
    constant RESET_VECTOR : std_logic_vector(31 downto 0) := x"00000000";
    constant INTR_VECTOR  : std_logic_vector(31 downto 0) := x"00000004";
    
    -- IF Stage Signals
    signal PC_value, PC_plus_4, next_PC : std_logic_vector(31 downto 0);
    signal instruction, PC_branch_addr : std_logic_vector(31 downto 0);
    signal PC_stall, PC_write_enable : std_logic;
    
    -- IF/ID Pipeline Register Signals
    signal IF_ID_Inst, IF_ID_PCPlus4, IF_ID_IN_PORT : std_logic_vector(31 downto 0);
    signal IF_ID_Write, IF_ID_Flush : std_logic;
    
    -- ID Stage Signals
    signal opcode : std_logic_vector(6 downto 0);
    signal Rsrc1,Rdst,Rsrc2 : std_logic_vector(2 downto 0);
    signal imm_16bit : std_logic_vector(15 downto 0);
    signal offset_16bit : std_logic_vector(15 downto 0);
    
    -- Control Unit Signals
    signal Raddr_Sel, RTI_sig, Branch_sig : std_logic;
    signal Int_Jump_Sel, ALU_A, ALU_B, CCR_En : std_logic;
    signal Int_Idx, J_Type : std_logic_vector(1 downto 0);
    signal ALU_Op : std_logic_vector(2 downto 0);
    signal Mem_Write_En, Mem_Read_En, Stack_En, PCsrc : std_logic;
    signal Stack_Inc, Mem_Op : std_logic;
    signal Mem_Addr_Sel, Mem_Write_Sel : std_logic_vector(1 downto 0);
    signal WE1, WE2, OUT_En, HLT_sig : std_logic;
    signal WB_Wadrr_Sel : std_logic_vector(1 downto 0);
    signal WB_Wdata_Sel : std_logic_vector(2 downto 0);
    
    -- Register File Signals
    signal Reg_Rdata1, Reg_Rdata2 : std_logic_vector(15 downto 0);  -- 16-bit from register file
    signal Rdata1_32bit, Rdata2_32bit : std_logic_vector(31 downto 0);  -- 32-bit converted
    signal Reg_WE1, Reg_WE2 : std_logic;
    signal Reg_Waddr1, Reg_Waddr2 : std_logic_vector(2 downto 0);
    signal Reg_Wdata1, Reg_Wdata2 : std_logic_vector(15 downto 0);
    
    -- Mux for Raddr1 selection (based on Raddr_Sel)
    signal Raddr1_selected : std_logic_vector(2 downto 0);
    
    signal CCR_in, CCR_out_sig : std_logic_vector(3 downto 0);
    signal PC_we, SP_we, CCR_we : std_logic;
    
    -- Sign Extender Signals
    signal imm_extended, offset_extended : std_logic_vector(31 downto 0);
    
    -- Hazard Detection Signals
    signal control_mux, insert_nop : std_logic;
    
    -- ID/EX Pipeline Register Signals
    signal ID_EX_CCR_En, ID_EX_RTI, ID_EX_Int_Jump, ID_EX_Branch : std_logic;
    signal ID_EX_Int_Idx, ID_EX_J_Type : std_logic_vector(1 downto 0);
    signal ID_EX_Mem_Write_En, ID_EX_Mem_Read_En, ID_EX_Stack_En : std_logic;
    signal ID_EX_PCsrc, ID_EX_Stack_Inc, ID_EX_Mem_Op, ID_EX_ALU_A, ID_EX_ALU_B : std_logic;
    signal ID_EX_ALU_Op : std_logic_vector(2 downto 0);
    signal ID_EX_WE1, ID_EX_WE2, ID_EX_OUT_En : std_logic;
    signal ID_EX_WB_Wadrr_Sel : std_logic_vector(1 downto 0);
    signal ID_EX_WB_Wdata_Sel : std_logic_vector(2 downto 0);
    signal ID_EX_PCPlus4, ID_EX_Rdata1, ID_EX_Rdata2 : std_logic_vector(31 downto 0);
    signal ID_EX_Rsrc1, ID_EX_Rsrc2, ID_EX_Rdst : std_logic_vector(2 downto 0);
    signal ID_EX_imm, ID_EX_offset : std_logic_vector(15 downto 0);
    signal ID_EX_IN_PORT : std_logic_vector(31 downto 0);
    
    -- EX Stage Signals
    signal ALU_op1, ALU_op2, ALU_result : std_logic_vector(31 downto 0);
    signal CCR_updated : std_logic_vector(3 downto 0);
    signal branch_taken, jump_target_sel : std_logic;
    signal jump_target : std_logic_vector(31 downto 0);
    
    -- Forwarding Signals
    signal ForwardA, ForwardB : std_logic_vector(1 downto 0);
    signal EX_MEM_RegWrite, MEM_WB_RegWrite : std_logic;
    
    -- EX/MEM Pipeline Register Signals
    signal EX_MEM_Mem_Write_En, EX_MEM_Mem_Read_En, EX_MEM_Stack_En : std_logic;
    signal EX_MEM_PCsrc, EX_MEM_WE1, EX_MEM_WE2, EX_MEM_OUT_En : std_logic;
    signal EX_MEM_ALU_result, EX_MEM_Rdata1, EX_MEM_Rdata2 : std_logic_vector(31 downto 0);
    signal EX_MEM_Rdst, EX_MEM_Rsrc1, EX_MEM_Rsrc2 : std_logic_vector(2 downto 0);
    signal EX_MEM_imm : std_logic_vector(15 downto 0);
    signal EX_MEM_PCPlus4 : std_logic_vector(31 downto 0);
    
    -- MEM Stage Signals
    signal Mem_Addr, Mem_Write_Data, Mem_Read_Data : std_logic_vector(31 downto 0);
    signal SP_value, SP_next : std_logic_vector(31 downto 0);
    signal SP_enable, SP_load : std_logic;
    
    -- MEM/WB Pipeline Register Signals
    signal MEM_WB_WE1, MEM_WB_WE2, MEM_WB_OUT_En : std_logic;
    signal MEM_WB_ALU_result, MEM_WB_Mem_Data, MEM_WB_Rdata1 : std_logic_vector(31 downto 0);
    signal MEM_WB_Rdst : std_logic_vector(2 downto 0);
    signal MEM_WB_imm : std_logic_vector(15 downto 0);
    signal MEM_WB_IN_PORT : std_logic_vector(31 downto 0);
    signal MEM_WB_WB_Wdata_Sel : std_logic_vector(2 downto 0);
    
    -- WB Stage Signals
    signal WB_Write_Data, WB_Write_Addr : std_logic_vector(31 downto 0);
    signal WB_WE, WB_WE2_sig : std_logic;
    
BEGIN
    
    -- ====== INSTRUCTION FETCH ======
    
    -- PC
    PC_Unit_inst: entity work.PC_Unit
        Port Map(
            clk => clk,
            reset => reset,
            stall => PC_stall,
            int => INTR_IN,
            PCSrc => PCsrc,
            ImmExt => jump_target,
            M0 => RESET_VECTOR,
            M1 => INTR_VECTOR,
            PC_out => PC_value
        );
    
    PC_debug <= PC_value;
    -- Calculate PC+4
    PC_plus_4 <= std_logic_vector(unsigned(PC_value) + 4);
    
    -- Memory 
    Memory_inst: entity work.Memory
        Port Map(
            clk => clk,
            reset=>  reset,
            PC_addr => PC_value(31 downto 0),
            instruction => instruction,
            Mem_write => EX_MEM_Mem_Write_En,
            Mem_Read => EX_MEM_Mem_Read_En,
            Mem_Addr => Mem_Addr(31 downto 0),
            Write_data => Mem_Write_Data,
            Read_data => Mem_Read_Data,
            intr_vector0 => RESET_VECTOR,
            intr_vector1 => INTR_VECTOR
        );
    
    instruction_debug <= instruction;
    
    -- ====== IF/ID REGISTER ======
    
    F_D_Register_inst: entity work.F_D_Register
        Port Map(
            CLK => clk,
            RST => reset,
            EN => IF_ID_Write,
            CLR => IF_ID_Flush,
            Inst => instruction,
            PCPlus4 => PC_plus_4,
            IN_Port => IN_PORT,
            Inst_Out => IF_ID_Inst,
            PCPlus4_Out => IF_ID_PCPlus4,
            IN_Out => IF_ID_IN_PORT
        );
    
    -- ====== STAGE 2: INSTRUCTION DECODE ======
    
    -- Instruction
    opcode <= IF_ID_Inst(6 downto 0);
    Rsrc1 <= IF_ID_Inst(9 downto 7);
    Rsrc2 <= IF_ID_Inst(12 downto 10);
    Rdst <= IF_ID_Inst(15 downto 13);
    imm_16bit <= IF_ID_Inst(15 downto 0);
    offset_16bit <= IF_ID_Inst(15 downto 0);
    
    -- Control Unit
    Control_Unit_inst: entity work.Control_Unit
        Port Map(
            opcode => opcode,
            HW_INT => INTR_IN,
            SW_INT => '0',
            Raddr_Sel => Raddr_Sel,
            RTI => RTI_sig,
            Branch => Branch_sig,
            Int_Jump_Sel => Int_Jump_Sel,
            Int_Idx => Int_Idx,
            J_Type => J_Type,
            ALU_A => ALU_A,
            ALU_B => ALU_B,
            ALU_Op => ALU_Op,
            CCR_En => CCR_En,
            Mem_Write_En => Mem_Write_En,
            Mem_Read_En => Mem_Read_En,
            Stack_En => Stack_En,
            PCsrc => PCsrc,
            Stack_Inc => Stack_Inc,
            Mem_Op => Mem_Op,
            Mem_Addr_Sel => Mem_Addr_Sel,
            Mem_Write_Sel => Mem_Write_Sel,
            WE1 => WE1,
            WE2 => WE2,
            WB_Wadrr_Sel => WB_Wadrr_Sel,
            OUT_En => OUT_En,
            WB_Wdata_Sel => WB_Wdata_Sel,
            HLT => HLT_sig
        );
    
    
    
    -- 1. Mux for Raddr1 selection (Raddr_Sel)
    -- 0: Read from Rsrc1, 1: Read from Rdst
    Raddr1_selected <= Rsrc1 when Raddr_Sel = '0' else Rdst;
    
    -- 2. Register File with correct connections
    Register_file_inst: entity work.Register_file
        Port Map(
            clk => clk,
            rst => reset,
            WE1 => Reg_WE1,
            WE2 => Reg_WE2,
            Raddr1 => Raddr1_selected,  
            Raddr2 => Rsrc2,             
            Waddr1 => Reg_Waddr1,
            Waddr2 => Reg_Waddr2,
            Wdata1 => Reg_Wdata1,
            Wdata2 => Reg_Wdata2,
            Rdata1 => Reg_Rdata1,
            Rdata2 => Reg_Rdata2
        );
    
    -- Convert 16-bit register outputs to 32-bit for ALU
    --Rdata1_32bit <= std_logic_vector(resize(signed(Reg_Rdata1), 32));
    --Rdata2_32bit <= std_logic_vector(resize(signed(Reg_Rdata2), 32));
    
    CCR_debug <= CCR_in;
    
    -- Sign Extenders
    Sign_Extender_imm: entity work.Sign_Extender
        Port Map(
            imm_in => imm_16bit,
            imm_out => imm_extended
        );
    
    Sign_Extender_offset: entity work.Sign_Extender
        Port Map(
            imm_in => offset_16bit,
            imm_out => offset_extended
        );
    
    --  Hazard Detection Unit 
    Hazard_Detection_Unit_inst: entity work.Hazard_Detection_Unit
        Port Map(
            ID_EX_MemRead => ID_EX_Mem_Read_En,
            ID_EX_Rdst => ID_EX_Rdst,
            IF_ID_Rsrc1 => Rsrc1,      
            IF_ID_Rsrc2 => Rsrc2,      
            Branch => Branch_sig,
            Jump => PCsrc,
            PC_Write => PC_write_enable,
            IF_ID_Write => IF_ID_Write,
            Control_Mux => control_mux
        );
    
    PC_stall <= not PC_write_enable;
    insert_nop <= control_mux;
    
    -- ====== ID/EX REGISTER ======
    
    D_E_Register_inst: entity work.D_E_Register
        Port Map(
            CLK => clk,
            RST => reset,
            EN => '1',
            CLR => insert_nop,
            CCR_EN => CCR_En,
            RTI => RTI_sig,
            INT_Jump => Int_Jump_Sel,
            INT_IDX => Int_Idx,
            MEM_W => Mem_Write_En,
            Branch => Branch_sig,
            WriteData => '0',  
            MemRead => Mem_Read_En,
            J_Type => J_Type,
            STACK => Stack_En,
            MEM_OP => Mem_Op,
            MEM_SEL => Mem_Addr_Sel,
            OUT_EN => OUT_En,
            ALU_A => ALU_A,
            ALUOp => ALU_Op,
            WE1 => WE1,
            WE2 => WE2,
            MEM_R => '0',  
            PCSRC => PCsrc,
            PCPlus4 => IF_ID_PCPlus4,
            Rdata1 => Rdata1_32bit,    
            Rdata2 => Rdata2_32bit,    
            Raddr1 => Rsrc1,           
            Raddr2 => Rsrc2,          
            Rdst => Rdst,
            Imm => imm_16bit,
            IN_Port => IF_ID_IN_PORT,
            ALU_B => ALU_B,
            CCR_EN_Out => ID_EX_CCR_En,
            RTI_Out => ID_EX_RTI,
            INT_Jump_Out => ID_EX_Int_Jump,
            INT_IDX_Out => ID_EX_Int_Idx,
            MEM_W_Out => ID_EX_Mem_Write_En,
            Branch_Out => ID_EX_Branch,
            WriteData_Out => open,
            MemRead_Out => ID_EX_Mem_Read_En,
            J_Type_Out => ID_EX_J_Type,
            STACK_Out => ID_EX_Stack_En,
            MEM_OP_Out => ID_EX_Mem_Op,
            MEM_SEL_Out => open,
            OUT_EN_Out => ID_EX_OUT_En,
            ALU_A_Out => ID_EX_ALU_A,
            ALUOp_Out => ID_EX_ALU_Op,
            WE1_Out => ID_EX_WE1,
            WE2_Out => ID_EX_WE2,
            MEM_R_Out => open,
            PCSRC_Out => ID_EX_PCsrc,
            
            PCPlus4_Out => ID_EX_PCPlus4,
            Rdata1_Out => ID_EX_Rdata1,
            Rdata2_Out => ID_EX_Rdata2,
            Raddr1_Out => ID_EX_Rsrc1,     
            Raddr2_Out => ID_EX_Rsrc2,     
            Rdst_Out => ID_EX_Rdst,
            Imm_Out => ID_EX_imm,
            IN_Out => ID_EX_IN_PORT,
            ALU_B_Out => ID_EX_ALU_B
        );
    
    -- ====== EXECUTE ======
    
    -- 4. Forwarding Unit with Rsrc1 and Rsrc2
    Forwarding_Unit_inst: entity work.Forward_unit
        Port Map(
            EX_MEM_RegWrite => EX_MEM_WE1,
            MEM_WB_RegWrite => MEM_WB_WE1,
            EX_MEM_Rdst => EX_MEM_Rdst,
            MEM_WB_Rdst => MEM_WB_Rdst,
            ID_EX_Rsrc1 => ID_EX_Rsrc1,    
            ID_EX_Rsrc2 => ID_EX_Rsrc2,    
            ForwardA => ForwardA,
            ForwardB => ForwardB
        );
    
    -- ALU  Mux (Forwarding)
    process(ForwardA, ForwardB, ID_EX_Rdata1, ID_EX_Rdata2, 
            EX_MEM_ALU_result, MEM_WB_ALU_result, ID_EX_ALU_B, ID_EX_imm)
    begin
        -- ALU Operand A (rsrc1)
        case ForwardA is
            when "00" => ALU_op1 <= ID_EX_Rdata1;
            when "01" => ALU_op1 <= EX_MEM_ALU_result;
            when "10" => ALU_op1 <= MEM_WB_ALU_result;
            when others => ALU_op1 <= ID_EX_Rdata1;
        end case;
        
        -- ALU Operand B (rsrc2 or immediate)
        if ID_EX_ALU_B = '1' then
            -- Use immediate
            ALU_op2 <= std_logic_vector(resize(signed(ID_EX_imm), 32));
        else
            -- Use Rsrc2 
            case ForwardB is
                when "00" => ALU_op2 <= ID_EX_Rdata2;
                when "01" => ALU_op2 <= EX_MEM_ALU_result;
                when "10" => ALU_op2 <= MEM_WB_ALU_result;
                when others => ALU_op2 <= ID_EX_Rdata2;
            end case;
        end if;
    end process;
    
    -- ALU
    ALU_inst: entity work.ALU
        Port Map(
            op1 => ALU_op1,
            op2 => ALU_op2,
            alu_op => ID_EX_ALU_Op,  
            offset => ID_EX_imm,
            imm => ID_EX_imm,
            alu_out => ALU_result,
            ccr => CCR_updated
        );
    
    ALU_result_debug <= ALU_result;
    
    -- CCR update
    CCR_we <= ID_EX_CCR_En;
    
    -- Branch 
    process(ID_EX_J_Type, CCR_in, ID_EX_imm, ID_EX_PCPlus4)
    begin
        branch_taken <= '0';
        jump_target <= (others => '0');
        
        case ID_EX_J_Type is
            when "00" =>  -- JZ
                if CCR_in(0) = '1' then
                    branch_taken <= '1';
                end if;
            when "01" =>  -- JN
                if CCR_in(1) = '1' then
                    branch_taken <= '1';
                end if;
            when "10" =>  -- JC
                if CCR_in(2) = '1' then
                    branch_taken <= '1';
                end if;
            when "11" =>  -- JMP
                branch_taken <= '1';
            when others =>
                branch_taken <= '0';
        end case;
        
        if branch_taken = '1' then
            jump_target <= std_logic_vector(signed(ID_EX_PCPlus4) + 
                          resize(signed(ID_EX_imm), 32));
        end if;
    end process;
    
    -- ====== EX/MEM REGISTER ======
    
    E_M_Register_inst: entity work.E_M_Register
        Port Map(
            CLK => clk,
            RST => reset,
            EN => '1',
            MemRead => ID_EX_Mem_Read_En,
            MEM_OP => ID_EX_Mem_Op,
            MEM_SEL => '0',  
            MEM_R => '0',
            ALURes => ALU_result,
            Raddr1 => ID_EX_Rsrc1,     
            Raddr2 => ID_EX_Rsrc2,     
            Rdst => ID_EX_Rdst,
            Rdata1 => ID_EX_Rdata1,
            Rdata2 => ID_EX_Rdata2,
            WriteData => '0',
            WE1 => ID_EX_WE1,
            WE2 => ID_EX_WE2,
            IN_Port => '0',
            PCSRC => ID_EX_PCsrc,
            STACK => ID_EX_Stack_En,
            BR_ADDR => jump_target,
            MEM_W => ID_EX_Mem_Write_En,
            Imm => ID_EX_imm,
            OUT_EN => ID_EX_OUT_En,
            CLR => '0',
            PCPlus4 => ID_EX_PCPlus4,
            MemRead_Out => EX_MEM_Mem_Read_En,
            MEM_OP_Out => open,
            MEM_SEL_Out => open,
            MEM_R_Out => open,
            ALURes_Out => EX_MEM_ALU_result,
            Raddr1_Out => EX_MEM_Rsrc1,    
            Raddr2_Out => EX_MEM_Rsrc2,    
            Rdst_Out => EX_MEM_Rdst,
            PCPlus4_Out => EX_MEM_PCPlus4,
            PCSRC_Out => open,
            STACK_Out => EX_MEM_Stack_En,
            BR_ADDR_Out => open,
            Rdata1_Out => EX_MEM_Rdata1,
            Rdata2_Out => EX_MEM_Rdata2,
            WriteData_Out => open,
            WE1_Out => EX_MEM_WE1,
            WE2_Out => EX_MEM_WE2,
            MEM_W_Out => EX_MEM_Mem_Write_En,
            IN_Port_Out => open,
            Imm_Out => EX_MEM_imm,
            OUT_EN_Out => EX_MEM_OUT_En
        );
    
    EX_MEM_RegWrite <= EX_MEM_WE1;
    
    -- ====== MEMORY ======
    
    -- Stack Pointer
    SP_enable <= EX_MEM_Stack_En;

STACK_inst: entity work.STACK
    Port Map(
        clk => clk,
        reset => reset,
        SP_enable => SP_enable,
        SP_INC => Stack_Inc,          
        SP_DEC => not Stack_Inc,      
        SP_mem => EX_MEM_ALU_result(31 downto 0),   
        SP_out => SP_value
    );
    
    -- Memory Address Mux
    process(Mem_Addr_Sel, EX_MEM_ALU_result, SP_value, EX_MEM_PCPlus4)
    begin
        case Mem_Addr_Sel is
            when "00" =>   Mem_Addr <= EX_MEM_PCPlus4;
            when "01" =>   Mem_Addr <= EX_MEM_ALU_result;
            when "10" =>   Mem_Addr <= SP_value;
            when others => Mem_Addr <= EX_MEM_ALU_result;
        end case;
    end process;
    
    -- Memory Write Data Mux
    process(Mem_Write_Sel, EX_MEM_Rdata1, EX_MEM_Rdata2, EX_MEM_PCPlus4)
    begin
        case Mem_Write_Sel is
            when "00" =>   Mem_Write_Data <= EX_MEM_Rdata1;
            when "01" =>   Mem_Write_Data <= EX_MEM_Rdata2;
            when "10" =>   Mem_Write_Data <= EX_MEM_PCPlus4;
            when others => Mem_Write_Data <= EX_MEM_Rdata1;
        end case;
    end process;
    
    -- SP update logic
    SP_next <= std_logic_vector(unsigned(SP_value) - 4) when Stack_Inc = '1' else
               std_logic_vector(unsigned(SP_value) + 4);
    SP_we <= EX_MEM_Stack_En;
    
    -- ====== MEM/WB PIPELINE REGISTER ======
    
    M_W_Register_inst: entity work.M_W_Register
        Port Map(
            CLK => clk,
            RST => reset,
            EN => '1',
            ALURes => EX_MEM_ALU_result,
            Raddr1 => EX_MEM_Rdst,
            Raddr2 => (others => '0'),
            Rdst => EX_MEM_Rdst,
            Rdata1 => EX_MEM_Rdata1,
            Rdata2 => EX_MEM_Rdata2,
            WE1 => EX_MEM_WE1,
            WE2 => EX_MEM_WE2,
            IN_Port => '0',
            RT_ADDR => EX_MEM_PCPlus4,
            LD_DATA => Mem_Read_Data,
            Imm => EX_MEM_imm,
            OUT_EN => EX_MEM_OUT_En,
            CLR => '0',
            ALURes_Out => MEM_WB_ALU_result,
            Raddr1_Out => open,
            Raddr2_Out => open,
            Rdst_Out => MEM_WB_Rdst,
            RT_ADDR_Out => open,
            Rdata1_Out => MEM_WB_Rdata1,
            Rdata2_Out => open,
            WE1_Out => MEM_WB_WE1,
            WE2_Out => MEM_WB_WE2,
            IN_Port_Out => open,
            LD_DATA_Out => MEM_WB_Mem_Data,
            Imm_Out => MEM_WB_imm,
            OUT_EN_Out => MEM_WB_OUT_En
        );
    
    MEM_WB_RegWrite <= MEM_WB_WE1;
    
    -- ====== WRITE BACK ======
    
    -- Write Back Data Mux 
    process(WB_Wdata_Sel, MEM_WB_ALU_result, MEM_WB_Rdata1, MEM_WB_Mem_Data, 
            MEM_WB_imm, IN_PORT, MEM_WB_IN_PORT)
    begin
        case WB_Wdata_Sel is
            when "000" =>   Reg_Wdata1 <= MEM_WB_ALU_result(15 downto 0);
            when "001" =>   Reg_Wdata1 <= MEM_WB_Rdata1(15 downto 0);
            when "010" =>   Reg_Wdata1 <= (others => '0');
            when "011" =>   Reg_Wdata1 <= MEM_WB_imm;
            when "100" =>   Reg_Wdata1 <= MEM_WB_ALU_result(15 downto 0);
            when "101" =>   Reg_Wdata1 <= MEM_WB_Mem_Data(15 downto 0);
            when "110" =>   Reg_Wdata1 <= IN_PORT(15 downto 0);
            when others =>  Reg_Wdata1 <= MEM_WB_ALU_result(15 downto 0);
        end case;
    end process;
    
    -- Write Back Address Mux
    process(WB_Wadrr_Sel, MEM_WB_Rdst, ID_EX_Rsrc1, ID_EX_Rdst)
    begin
        case WB_Wadrr_Sel is
            when "00" =>   Reg_Waddr1 <= MEM_WB_Rdst;
            when "01" =>   Reg_Waddr1 <= ID_EX_Rsrc1;    
            when "10" =>   Reg_Waddr1 <= ID_EX_Rdst;
            when others => Reg_Waddr1 <= MEM_WB_Rdst;
        end case;
    end process;
    
    -- Write Enable signals
    Reg_WE1 <= MEM_WB_WE1;
    Reg_WE2 <= MEM_WB_WE2;
    Reg_Waddr2 <= (others => '0');
    Reg_Wdata2 <= (others => '0');
    
    -- Output Port
    process(clk, reset)
    begin
        if reset = '1' then
            OUT_PORT <= (others => '0');
        elsif rising_edge(clk) then
            if MEM_WB_OUT_En = '1' then
                OUT_PORT <= MEM_WB_ALU_result;
            end if;
        end if;
    end process;
    
    -- PC Write Enable
    PC_we <= '1' when PCsrc = '1' and branch_taken = '1' else '0';
    
    -- Flush IF/ID on branch
    IF_ID_Flush <= '1' when (PCsrc = '1' and branch_taken = '1') else '0';
    
END processor_arch;