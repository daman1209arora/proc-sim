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
    signal rfenb: STD_LOGIC := '0';
    signal ALUtoRFEnable: STD_LOGIC := '0';
    signal rfwea2: STD_LOGIC := '0';
    signal rfaddr1: STD_LOGIC_VECTOR(4 downto 0) := "00000";
    signal rfaddr2: STD_LOGIC_VECTOR(4 downto 0) := "00000";
    signal rfWrite1: STD_LOGIC_VECTOR(4 downto 0) := "00000"; 
    signal rfWrite2: STD_LOGIC_VECTOR(4 downto 0) := "00000";      
    signal RFtoALU1: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal RFtoALU2: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    
    signal muwea: STD_LOGIC := '0';
    signal MUReadEnable: STD_LOGIC := '0';
    signal MUtoRFAddress, muaddrr2: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal muaddrw: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal muin: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal muout1, muout2: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
 
    signal aluenb: STD_LOGIC := '0';
    
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
        addra1, addra2, addrb1, addrb2 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        dina1, dina2 : IN STD_LOGIC_VECTOR(31 downto 0);
        doutb1, doutb2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    end component;
    type p_state is (idle, loadingaluModeuction, decode, aluRegistersLoaded, aluDone, swLoaded, lwLoaded, registerOverwritten, swLoadFinish, lwLoadFinish, increment, stopped);
    constant zero: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal state: p_state := idle;
    signal progCounter : integer := 0;
    signal ALUtoRF : std_logic_vector(31 downto 0) := (others => '0');
begin
    alu_comp: ALU port map(clk => clk, enb => aluenb, R1 => RFtoALU1, R2 =>RFtoALU2, mode => aluMode, O1 => ALUtoRF);
    mu_comp: Memory port map(clka => clk, clkb => clk, wea => muwea, enb => MUReadEnable, addra => muaddrw, addrb1 => MUtoRFAddress, addrb2 => muout2, dina => RFtoALU1, doutb1 => MUtoRF, doutb2 => muout2);
    rf_comp: RegisterFile port map(clk =>clk, wea1 => ALUtoRFEnable, wea2 => rfwea2, enb => rfenb, addra1 => rfWrite1, addra2 => rfWrite2, addrb1 => rfaddr1, addrb2 => rfaddr2, dina => ALUtoRF, doutb1 => RFtoALU1, doutb2 => RFtoALU2);

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
                    MUtoRFAddress <= std_logic_vector(to_unsigned(progCounter, 16));
                    state <= loadingaluModeuction;
                end if;
            -- Just after this clock cycle, the signal MUReadEnable will be enabled. 
            -- The next program aluModeuction will be loaded into regWrite after two clock cycles.


            elsif(state = loadingaluModeuction) then 
                state <= decode;
            -- Just after this clock cycle, the aluModeuction has been loaded into regWrite


            elsif(state = decode) then
                if(rfWrite1 = zero) then
                    state <= stopped;
                elsif(rfWrite1(31 downto 26) = "000000") then 
                    if(rfWrite1(5 downto 0) = "000000") then
                        aluMode <= "10";
                        rfWrite1 <= rfWrite1(15 downto 11);
                        rfaddr1 <= rfWrite1(20 downto 16);
                        rfaddr2 <= rfWrite1(10 downto 6);
                    elsif(rfWrite1(5 downto 0) = "000010") then 
                        aluMode <= "11";
                        rfWrite1 <= rfWrite1(15 downto 11);
                        rfaddr1 <= rfWrite1(20 downto 16);
                        rfaddr2 <= rfWrite1(10 downto 6);
                    elsif(rfWrite1(5 downto 0) = "100000") then
                        aluMode <= "00";
                        rfWrite1 <= rfWrite1(15 downto 11);
                        rfaddr1 <= rfWrite1(25 downto 21);
                        rfaddr2 <= rfWrite1(20 downto 16);
                    elsif(rfWrite1(5 downto 0) = "100010") then 
                        aluMode <= "01"; 
                        rfWrite1 <= rfWrite1(15 downto 11);
                        rfaddr1 <= rfWrite1(25 downto 21);
                        rfaddr2 <= rfWrite1(20 downto 16);
                    else
                        state <= stopped;
                    end if;
                    rfenb <= '1';
                    state <= aluRegistersLoaded;
                elsif(rfWrite1(31 downto 26) = "101011") then
                    rfenb <= '1';
                    rfaddr1 <= rfWrite1(20 downto 16);
                    state <= swLoaded;
                    muaddrw <= rfWrite1(15 downto 0);
                elsif(rfWrite1(31 downto 26) = "100011") then
                    MUReadEnable <= '1';
                    MUtoRFAddress <= rfWrite1(15 downto 0);
                    state <= lwLoaded;
                    rfWrite1 <= rfWrite1(20 downto 16);
                else
                    state <= stopped;
                end if;

            elsif(state = aluRegistersLoaded) then
                aluenb <= '1';
                state <= aluDone;
    
            elsif(state = aluDone) then
                rfenb <= '1';
                aluenb <= '0';
                ALUtoRFEnable <= '1';
                
                state <= registerOverwritten;
            
            elsif(state = registerOverwritten) then     
                ALUtoRFEnable <= '0';
                state <= increment;
                
            elsif(state = swLoaded) then 
                muwea <= '1';
                state <= swLoadFinish;
                MUReadEnable <= '0';

            elsif(state = lwLoaded) then 
                ALUtoRFEnable <= '1';
                state <= lwLoadFinish;
                MUReadEnable <= '0';
                state <= increment;
                
            elsif(state = swLoadFinish) then
                muwea <= '0';
                state <= increment;

            elsif(state = swLoadFinish) then
                ALUtoRFEnable <= '0';
                state <= increment;
            
            elsif(state = increment) then
                progCounter <= progCounter + 1;
                state <= idle;
            end if;

        end if;
    end process;



end Behavioral;
