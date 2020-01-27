library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Processor is
  Port (clk: IN STD_LOGIC;
        start: IN STD_LOGIC := '0';
        reset: IN STD_LOGIC := '0');
end Processor;


architecture Behavioral of Processor is 
	signal count : integer := 0;
	signal memory : array (0 to 4095) of std_logic_vector (31 downto 0) : = (others => (others => '0'));
	signal registerFile : array (0 to 31) of std_logic_vector (31 downto 0) : = (others => (others => '0'));
	type state is (idle, readInstr, add, sub, shiftl, shiftr, writeInMem, loadFromMemory, stopped);	
	signal addIn1, addIn2, addOut: std_logic_vector(31 downto 0);
	signal subIn1, subIn2, subOut: std_logic_vector(31 downto 0);
	signal zero: std_logic_vector(31 downto 0) := (others => '0');
	signal shamt: std_logic_vector(4 downto 0);
	signal shiftIn
	begin

	process(clk)
	begin
		if(clk'event) then
			if(clk = '1') then 
				if(state = idle and start = '1') then 
					state <= readInstr;
				endif;
				if(state = readInstr) then 
					if(memory(count)(31 downto 26) = "000000" and memory(count)(5 downto 0) = "100000") then 
						registerFile(to_integer(unsigned(memory(15 downto 11)))) <= registerFile(to_integer(unsigned(memory(25 downto 21)))) + registerFile(to_integer(unsigned(memory(20 downto 16))));
					end if;
					if(memory(count)(31 downto 26) = "000000" and memory(count)(5 downto 0) = "100010") then 
						registerFile(to_integer(unsigned(memory(15 downto 11)))) <= registerFile(to_integer(unsigned(memory(25 downto 21)))) - registerFile(to_integer(unsigned(memory(20 downto 16))));
					end if;
					if(memory(count)(31 downto 26) = "000000" and memory(count)(5 downto 0) = "000000") then 
						registerFile(to_integer(unsigned(memory(15 downto 11)))) <= registerFile(31 - to_integer(unsigned(memory(10 downto 6))) downto 0) & zero(to_integer(unsigned(memory(10 downto 6))) - 1 downto 0);
					end if;
					if(memory(count)(31 downto 26) = "000000" and memory(count)(5 downto 0) = "000010") then 
						registerFile(to_integer(unsigned(memory(15 downto 11)))) <= zero(to_integer(unsigned(memory(10 downto 6))) - 1, 0) & registerFile(31 downto to_integer(unsigned(memory(10 downto 6)))) ;
					end if;
					if(memory(count)(31 downto 26) = "101011") then 
						memory(to_integer(unsigned(memory(count)(15 downto 0))) + registerFile(to_integer(unsigned(memory(count)(25 downto 21)))) <= registerFile()
					end if;
					if(memory(count)(31 downto 26) = "100011") then 
						addIn1 <= memory(count)(25 downto 21);
						addIn2 <= memory(count)(20 downto 16);
						addOut <= memory(count)(15 downto 11);
					end if;
				end if;
			end if;

			if(clk = '0') then 
			end if;
		end if;
	end process;
end Behavioral;