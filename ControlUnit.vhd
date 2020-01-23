library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ControlUnit is
  Port (clk: IN STD_LOGIC;
        start: IN STD_LOGIC;
        reset: IN STD_LOGIC);
end ControlUnit;

architecture Behavioral of ControlUnit is
    signal aluMode: STD_LOGIC_VECTOR(1 downto 0);
    signal rfenb: STD_LOGIC;
    signal rfwea: STD_LOGIC;
    signal rfaddr1: STD_LOGIC_VECTOR(4 downto 0);
    signal rfaddr2: STD_LOGIC_VECTOR(4 downto 0);
    signal rfWrite: STD_LOGIC_VECTOR(4 downto 0);    
    signal reg1: STD_LOGIC_VECTOR(31 downto 0);
    signal reg2: STD_LOGIC_VECTOR(31 downto 0);
    signal regWrite: STD_LOGIC_VECTOR(31 downto 0);
    
    signal muwea: STD_LOGIC;
    signal muenb: STD_LOGIC;
    signal muaddrr: STD_LOGIC_VECTOR(15 downto 0);
    signal muaddrw: STD_LOGIC_VECTOR(15 downto 0);
    signal muin: STD_LOGIC_VECTOR(31 downto 0);
    signal muout: STD_LOGIC_VECTOR(31 downto 0);
 
    signal aluenb: STD_LOGIC;
    
    
    component ALU is port(
            clk, enb : IN STD_LOGIC;
            R1, R2 : IN STD_LOGIC_VECTOR(31 downto 0);
            mode : IN STD_LOGIC_VECTOR(1 downto 0);
            O1: OUT STD_LOGIC_VECTOR(31 downto 0)
         );
    end component;
    
    component Memory is port(
            clka,clkb, wea, enb : IN STD_LOGIC;
            addra, addrb : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            dina : IN STD_LOGIC_VECTOR(31 downto 0);
            doutb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    end component;
    
    component RegisterFile is port(
        clk, wea, enb : IN STD_LOGIC;
        addra, addrb1, addrb2 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(31 downto 0);
        doutb1, doutb2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    end component;
    type p_state is (idle, loadingaluModeuction, decode, aluRegistersLoaded, aluDone, swLoaded, lwLoaded, registerOverwritten, swLoadFinish, lwLoadFinish, increment, stopped);
    constant zero: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal state: p_state := idle;
    signal progCounter : integer := 1;
    signal aluOut : std_logic_vector(31 downto 0);
begin
    alu_comp: ALU port map(clk => clk, enb => aluenb, R1 => reg1, R2 =>reg2, mode => aluMode, O1 => aluOut);
    mu_comp: Memory port map(clka => clk, clkb => clk, wea => muwea, enb => muenb, addra => muaddrw, addrb => muaddrr, dina => reg1, doutb => regWrite);
    rf_comp: RegisterFile port map(clk =>clk, wea => rfwea, enb => rfenb, addra => rfWrite, addrb1 => rfaddr1, addrb2 => rfaddr2, dina => aluOut, doutb1 => reg1, doutb2 => reg2);


    process(clk)
    begin
        if(rising_edge(clk)) then 
            if(state = idle) then 
                if(start = '1') then
                    muenb <= '1';
                    muaddrr <= std_logic_vector(to_unsigned(progCounter, 16));
                    state <= loadingaluModeuction;
                end if;
            -- Just after this clock cycle, the signal muenb will be enabled. 
            -- The next program aluModeuction will be loaded into regWrite after two clock cycles.


            elsif(state = loadingaluModeuction) then 
                state <= decode;
            -- Just after this clock cycle, the aluModeuction has been loaded into regWrite


            elsif(state = decode) then
                if(regWrite = zero) then
                    state <= stopped;
                elsif(regWrite(31 downto 26) = "000000") then 
                    aluenb <= '1';
                    if(regWrite(5 downto 0) = "000000") then
                        aluMode <= "10";
                    elsif(regWrite(5 downto 0) = "000010") then 
                        aluMode <= "11";
                    elsif(regWrite(5 downto 0) = "100000") then
                        aluMode <= "00";
                    elsif(regWrite(5 downto 0) = "100010") then 
                        aluMode <= "01";
                    else
                        state <= stopped;
                    end if;
                    rfenb <= '1';
                    rfaddr1 <= regWrite(25 downto 21);
                    rfaddr2 <= regWrite(20 downto 16);
                    state <= aluRegistersLoaded;
                elsif(regWrite(31 downto 26) = "101011") then
                    rfenb <= '1';
                    rfaddr1 <= regWrite(25 downto 21);
                    state <= swLoaded;
                    muaddrw <= regWrite(15 downto 0);
                elsif(regWrite(31 downto 26) = "100011") then
                    muenb <= '1';
                    muaddrr <= regWrite(15 downto 0);
                    state <= lwLoaded;
                    rfaddr2 <= regWrite(15 downto 11);
                else
                    state <= stopped;
                end if;

            elsif(state = aluRegistersLoaded) then
                aluenb <= '0';
                state <= aluDone;
    
            elsif(state = aluDone) then
                rfenb <= '1';
                state <= registerOverwritten;
            
            elsif(state = registerOverwritten) then     
                state <= increment;
                
            elsif(state = swLoaded) then 
                muwea <= '1';
                state <= swLoadFinish;
                muenb <= '0';

            elsif(state = lwLoaded) then 
                rfwea <= '1';
                state <= lwLoadFinish;
                muenb <= '0';

            elsif(state = swLoadFinish) then
                muwea <= '0';
                state <= increment;

            elsif(state = swLoadFinish) then
                rfwea <= '0';
                state <= increment;
            
            elsif(state = increment) then
                progCounter <= progCounter + 1;
                state <= idle;
            end if;

        end if;
    end process;



end Behavioral;
