library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ControlUnit is
  Port (clk: IN STD_LOGIC;
        start: IN STD_LOGIC := '0';
        reset: IN STD_LOGIC := '0');
end ControlUnit;

architecture Behavioral of ControlUnit is
    signal aluMode: STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal RFEnable: STD_LOGIC := '0';
    signal ALUtoRFEnable: STD_LOGIC := '0';
    signal rfwea2: STD_LOGIC := '0';
    signal rfaddr1: STD_LOGIC_VECTOR(4 downto 0) := "00000";
    signal rfaddr2: STD_LOGIC_VECTOR(4 downto 0) := "00000";
    signal MUtoCU: STD_LOGIC_VECTOR(4 downto 0) := "00000"; 
    signal rfWrite2: STD_LOGIC_VECTOR(4 downto 0) := "00000";      
    signal RFtoALU1: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal RFtoALU2: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    
    signal muwea: STD_LOGIC := '0';
    signal MUReadEnable: STD_LOGIC := '0';
    signal MUtoRFAddress, muaddrr2: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal muaddrw: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal muin: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal muout1, muout2: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
 
    signal aluEnable: STD_LOGIC := '0';
    
    -- muout1 goes to control
    -- muout2 goes to rf
    -- rfin1 goes to alu
    -- rfin2 goes to memory
    
    component ALU is port(
            clk, enb : IN STD_LOGIC;
            R1, R2 : IN STD_LOGIC_VECTOR(31 downto 0);
            mode : IN STD_LOGIC_VECTOR(1 downto 0);
            O1: OUT STD_LOGIC_VECTOR(31 downto 0)
         );
         
    end component;
    
    component Memory is port(
            clka,clkb, wea, enb : IN STD_LOGIC;
            addra, addrb1, addrb2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            dina : IN STD_LOGIC_VECTOR(31 downto 0);
            doutb1, doutb2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    end component;
    
    component RegisterFile is port(
        clk, wea1, wea2, enb : IN STD_LOGIC;
        addra1, addra2, addrb1, addrb2, addrb3 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        dina1, dina2 : IN STD_LOGIC_VECTOR(31 downto 0);
        doutb1, doutb2, doutb3 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    end component;
    type p_state is (idle, loadingaluInstruction, decode, aluRegistersLoaded, aluDone, swLoaded, lwLoaded, registerOverwritten, swLoadFinish, lwLoadFinish, increment, stopped);
    constant zero: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal state: p_state := idle;
    signal progCounter : integer := 0;
    signal ALUtoRF : std_logic_vector(31 downto 0) := (others => '0');
begin
    alu_comp: ALU port map(clk => clk, enb => aluEnable, R1 => RFtoALU1, R2 =>RFtoALU2, mode => aluMode, O1 => ALUtoRF);

    mu_comp: Memory port map(clka => clk, clkb => clk, wea => MUWriteEnable, enb => MUReadEnable, 
                            addra => MUWriteAddress, addrb1 => MUReadAddress1, addrb2 => MUReadAddress2, 
                            dina => RFtoMU, doutb1 => MUtoCU, doutb2 => MUtoRF);

    rf_comp: RegisterFile port map(clk =>clk, wea1 => RFWriteEnable1, wea2 => RFWriteEnable2, enb => RFReadEnable, 
                                    addra1 => RFWriteAddress1, addra2 => RFWriteAddress2, addrb1 => RFReadAddress1, addrb2 => RFReadAddress2, addbr3 => RFReadAddress3
                                    dina1 => ALUtoRF, dina2 => MUtoRF, doutb1 => RFtoALU1, doutb2 => RFtoALU2, doutb3 => RFtoMU);

    process(clk)
    begin
        if(reset = '1') then 
            state <= idle;
            progCounter <= 0;
        end if;
        if(rising_edge(clk)) then 
            if(state = idle) then 
                if(start = '1') then
                    MUReadEnable <= '1';
                    MUReadAddress1 <= std_logic_vector(to_unsigned(progCounter, 16));
                    state <= loadingaluInstruction;
                end if;
            -- Just after this clock cycle, the signal MUReadEnable will be enabled. 
            -- The next program aluModeuction will be loaded into regWrite after two clock cycles.


            elsif(state = loadingaluInstruction) then 
                state <= decode;
            -- Just after this clock cycle, the aluModeuction has been loaded into regWrite


            elsif(state = decode) then
                if(MUtoCU = zero) then
                    state <= stopped;
                elsif(MUtoCU(31 downto 26) = "000000") then 
                    if(MUtoCU(5 downto 0) = "000000") then
                        aluMode <= "10";
                        RFReadAddress1 <= MUtoCU(15 downto 11);
                        RFReadAddress2 <= MUtoCU(20 downto 16);
                        RFWriteAddress2 <= MUtoCU(10 downto 6);
                    elsif(MUtoCU(5 downto 0) = "000010") then 
                        aluMode <= "11";
                        RFReadAddress1 <= MUtoCU(15 downto 11);
                        RFReadAddress2 <= MUtoCU(20 downto 16);
                        RFWriteAddress2 <= MUtoCU(10 downto 6);
                    elsif(MUtoCU(5 downto 0) = "100000") then
                        aluMode <= "00";
                        RFWriteAddress1 <= MUtoCU(15 downto 11);
                        RFReadAddress1 <= MUtoCU(25 downto 21);
                        RFReadAddress2 <= MUtoCU(20 downto 16);
                    elsif(MUtoCU(5 downto 0) = "100010") then 
                        aluMode <= "01";
                        RFWriteAddress1 <= MUtoCU(15 downto 11);
                        RFReadAddress1 <= MUtoCU(25 downto 21);
                        RFReadAddress2 <= MUtoCU(20 downto 16);
                    else
                        state <= stopped;
                    end if;
                    RFReadEnable <= '1';
                    state <= aluRegistersLoaded;
                elsif(MUtoCU(31 downto 26) = "101011") then
                    RFReadEnable <= '1';
                    RFReadAddress3 <= MUtoCU(20 downto 16);
                    state <= swLoaded;
                    MUWriteAddress <= MUtoCU(15 downto 0);
                elsif(MUtoCU(31 downto 26) = "100011") then
                    MUReadEnable <= '1';
                    MUReadAddress2 <= MUtoCU(15 downto 0);
                    state <= lwLoaded;
                    RFWriteAddress2 <= MUtoCU(20 downto 16);
                else
                    state <= stopped;
                end if;

            elsif(state = aluRegistersLoaded) then
                aluEnable <= '1';
                state <= aluDone;
    
            elsif(state = aluDone) then
                RFWriteEnable1 <= '1';
                aluEnable <= '0';
                state <= registerOverwritten;
            
            elsif(state = registerOverwritten) then     
                RFWriteEnable1 <= '0';
                state <= increment;
                
            elsif(state = swLoaded) then 
                MUWriteEnable <= '1';
                state <= swLoadFinish;
                MUReadEnable <= '0';

            elsif(state = lwLoaded) then 
                RFWriteEnable2 <= '1';
                state <= lwLoadFinish;
                MUReadEnable <= '0';
                
            elsif(state = swLoadFinish) then
                MUWriteEnable <= '0';
                state <= increment;

            elsif(state = lwLoadFinish) then
                RFWriteEnable2 <= '0';
                state <= increment;
            
            elsif(state = increment) then
                progCounter <= progCounter + 1;
                state <= idle;
            end if;

        end if;
    end process;



end Behavioral;
