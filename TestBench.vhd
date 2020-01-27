library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Test is
end Test;

architecture Behavioral of Test is
    signal clk, start, reset, writeRF, writeMem : std_logic := '0';
    signal addrM : STD_LOGIC_VECTOR(15 downto 0);
    signal addrRF : STD_LOGIC_VECTOR(4 downto 0);
    signal memData, rfData : STD_LOGIC_VECTOR(31 downto 0);
    constant half_period: time := 50ns;
    constant period: time := 100ns;
    signal vec: STD_LOGIC_VECTOR(31 downto 0);
    type Memory_type is array (0 to 4095) of std_logic_vector (31 downto 0);
    signal memory : Memory_type := (            0 => "00000000001000100000000000100000", --r0 = r1 + r2
                                                1 => "00000000001000100000000000100010", --r0 = r1 - r2
                                                2 => "00000000000000010001100010000000", --r3 = r1 << 2
                                                3 => "10101100000000000000100000000000", --mem(2048 + r0) = r0 
                                                4 => "10001100000000010000100000000000", --r1 = mem(2048 + r0)
                                                5 => "00000000000000000000000000100000", -- r0 = r0 + r0
                                                6 => "00000000000000000000000010000010", -- r0 = r0 >> 2
                                                7 => "00000000000000100001000000000010", -- r2 = r2 >> 0                                                 
                                                others => (others => '0'));
                                                
    type RF_type is array (0 to 31) of std_logic_vector (31 downto 0);
    signal registerFile : RF_type := (        0 => "00000000000000000000000000100000", 
                                              1 => "00000000000000000000000000011111", 
                                              2 => "00000000000000000000000000001010",
                                              others => "00000000000000000000000000000000");
                                              
begin
    Processor: entity work.Processor port map (clk => clk,
                                    start => start,
                                    reset => reset,
                                    writeMem => writeMem,
                                    writeRF => writeRF,
                                    addrM => addrM,
                                    addrRF => addrRF,
                                    memData => memData,
                                    rfData => rfData);
    process
    begin
        init: for i in 0 to 5 loop
                clk <= '1';
                wait for half_period;
                clk <= '0';
                wait for half_period;
        end loop init;
        
        memLoop: for i in 0 to 4095 loop
            clk <= '1';
            writeMem <= '1';
            addrM <= std_logic_vector(to_unsigned(i, 16));
            memData <= memory(i);
            wait for half_period;
            clk <= '0';
            writeMem <= '0';
            wait for half_period;
        end loop memLoop;
        
        
        rfLoop: for i in 0 to 31 loop
            clk <= '1';
            writeRF <= '1';
            addrRF <= std_logic_vector(to_unsigned(i, 5));
            rfData <= registerFile(i);
            wait for half_period;
            clk <= '0';
            wait for half_period;
        end loop rfLoop;
        
        writeRF <= '0';
        
        runLoop: for i in 0 to 4095 loop
            clk <= '1';
            start <= '1';
            wait for half_period;
            clk <= '0';
            wait for half_period;
        end loop runLoop;
        
    end process;
end Behavioral;
