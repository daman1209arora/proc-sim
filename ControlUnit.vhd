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
    signal MUReadEnable, MUWriteEnable1, RFWriteEnable1, RFWriteEnable2, RFReadEnable1, RFReadEnable2, RFReadEnable3, aluEnable, ALUtoRFEnable, RFEnable, MUWriteEnable2: STD_LOGIC := '0';
    signal RFReadAddress1, RFReadAddress2, RFReadAddress3, RFWriteAddress1, RFWriteAddress2 : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal MUWriteAddress1, MUReadAddress1, MUReadAddress2, MUtoRFAddress, MUWriteAddress2: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal MUtoCU, MUtoRF, RFtoMU, RFtoALU1, RFtoALU2, CUtoMU: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    
    
    component ALU is port(
            clk, enb : IN STD_LOGIC;
            R1, R2 : IN STD_LOGIC_VECTOR(31 downto 0);
            mode : IN STD_LOGIC_VECTOR(1 downto 0);
            O1: OUT STD_LOGIC_VECTOR(31 downto 0)
         );
         
    end component;
    
    component Memory is port(
            clka,clkb, wea1, wea2, enb : IN STD_LOGIC;
            addra1, addra2, addrb1, addrb2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            dina1, dina2 : IN STD_LOGIC_VECTOR(31 downto 0);
            doutb1, doutb2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    end component;
    
    component RegisterFile is port(
        clk, wea1, wea2, enb1, enb2, enb3 : IN STD_LOGIC;
        addra1, addra2, addrb1, addrb2, addrb3 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        dina1, dina2 : IN STD_LOGIC_VECTOR(31 downto 0);
        doutb1, doutb2, doutb3 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    end component;
    type p_state is (idle, loadingaluInstruction, loadOffset, decode, aluRegistersLoaded, aluDone, swLoaded, lwLoaded, registerOverwritten, swLoadFinish, lwLoadFinish, increment, stopped);
    constant zero: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal state: p_state := idle;
    signal progCounter : integer := 0;
    signal ALUtoRF : std_logic_vector(31 downto 0) := (others => '0');
    signal instruction : std_logic_vector(31 downto 0) := (others => '0');
    signal ALU2: std_logic_vector(31 downto 0) := (others => '0');
begin
    alu_comp: ALU port map(clk => clk, enb => aluEnable, R1 => RFtoALU1, R2 =>RFtoALU2, mode => aluMode, O1 => ALUtoRF);

    mu_comp: Memory port map(clka => clk, clkb => clk, wea1 => MUWriteEnable1, wea2 => MUWriteEnable2, enb => MUReadEnable, 
                            addra1 => MUWriteAddress1, addra2 => MUWriteAddress2, addrb1 => MUReadAddress1, addrb2 => MUReadAddress2, 
                            dina1 => RFtoMU, dina2 => CUtoMU, doutb1 => MUtoCU, doutb2 => MUtoRF);

    rf_comp: RegisterFile port map(clk => clk, wea1 => RFWriteEnable1, wea2 => RFWriteEnable2, enb1 => RFReadEnable1, enb2 => RFReadEnable2, enb3 => RFReadEnable3,
                                    addra1 => RFWriteAddress1, addra2 => RFWriteAddress2, addrb1 => RFReadAddress1, addrb2 => RFReadAddress2, addrb3 => RFReadAddress3,
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

            elsif(state = loadingaluInstruction) then 
                state <= decode;
                
            elsif(state = decode) then
                if(MUtoCU = zero) then
                    state <= stopped;
                elsif(MUtoCU(31 downto 26) = "000000") then 
                    if(MUtoCU(5 downto 0) = "000000") then
                        aluMode <= "10";
                        RFReadAddress1 <= MUtoCU(20 downto 16);
                        RFReadAddress2 <= MUtoCU(20 downto 16);              
                        RFWriteAddress2 <= MUtoCU(15 downto 11);
                    elsif(MUtoCU(5 downto 0) = "000010") then 
                        aluMode <= "11";
                        RFReadAddress1 <= MUtoCU(20 downto 16);
                        RFReadAddress2 <= MUtoCU(20 downto 16);  
                        RFWriteAddress2 <= MUtoCU(15 downto 11);
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
                    RFReadEnable1 <= '1';
                    RFReadEnable2 <= '1';
                    state <= aluRegistersLoaded;
                elsif(MUtoCU(31 downto 26) = "101011") then
                    RFReadEnable3 <= '1';
                    RFReadAddress3 <= MUtoCU(20 downto 16);
                    state <= swLoaded;
                    MUWriteAddress1 <= MUtoCU(15 downto 0);
                elsif(MUtoCU(31 downto 26) = "100011") then
                    MUReadEnable <= '1';
                    MUReadAddress2 <= MUtoCU(15 downto 0);
                    state <= lwLoaded;
                    RFWriteAddress2 <= MUtoCU(20 downto 16);
                else
                    state <= stopped;
                end if;
                      
            elsif(state = aluRegistersLoaded) then
                RFReadEnable1 <= '0';
                RFReadEnable2 <= '0';
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
                MUWriteEnable1 <= '1';
                state <= swLoadFinish;
                MUReadEnable <= '0';

            elsif(state = lwLoaded) then 
                RFWriteEnable2 <= '1';
                state <= lwLoadFinish;
                MUReadEnable <= '0';
                
            elsif(state = swLoadFinish) then
                MUWriteEnable1 <= '0';
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
