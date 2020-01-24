library ieee;
use ieee.std_logic_1164.all;


entity Test is
end Test;

architecture Behavioral of Test is
    signal clk, start, reset : std_logic := '0';
    constant half_period: time := 50ns;
    constant period: time := 100ns;
    signal vec: STD_LOGIC_VECTOR(31 downto 0);
begin
    UUT : entity work.ControlUnit port map (clk => clk, reset => reset, start => start);
    process
    begin
        myLoop: for i in 0 to 1000 loop
            clk <= '1';
            if(i = 0) then
                start <= '0';
            else
                start <= '1';
            end if;
            reset <= '0';
            wait for half_period;
            clk <= '0';
            wait for half_period;
        end loop myLoop;
    end process;
end Behavioral;
