library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Processor is
  Port (clk: IN STD_LOGIC;
        start: IN STD_LOGIC := '0';
        reset: IN STD_LOGIC := '0';
        writeMem: IN STD_LOGIC := '0';
        writeRF: IN STD_LOGIC := '0';
        addrM: IN STD_LOGIC_VECTOR(15 downto 0);
        addrRF : IN STD_LOGIC_VECTOR(4 downto 0);
        memData : IN STD_LOGIC_VECTOR(31 downto 0);
        rfData : IN STD_LOGIC_VECTOR(31 downto 0));
end Processor;


architecture Behavioral of Processor is 
	signal count : integer := 0;
	type Memory_type is array (0 to 4095) of std_logic_vector (31 downto 0);
	signal memory : Memory_type := ( others => (others => '0'));
	type RF_type is array (0 to 31) of std_logic_vector (31 downto 0);
	signal registerFile : RF_type := ( others => (others => '0'));
	
	type stateType is (idle, readInstr, stopped);
	signal state : stateType := idle;	
	signal zero: std_logic_vector(31 downto 0) := (others => '0');
	begin

	process(clk)
	begin
		if(clk'event) then
			if(clk = '1') then 
			     if(reset = '1') then 
			         count <= 0;
			         state <= idle;
                 end if;
				if(state = idle) then
				    if(start = '1') then 
					   state <= readInstr;
					end if;
					if(writeMem = '1') then 
					   memory(to_integer(unsigned(addrM))) <= memData;
					end if;
					if(writeRF = '1') then 
                       registerFile(to_integer(unsigned(addrRF))) <= rfData;
                    end if;
				end if;
				if(state = readInstr) then 
					if(memory(count)(31 downto 26) = "000000" and memory(count)(5 downto 0) = "100000") then 
						registerFile(to_integer(unsigned(memory(count)(15 downto 11)))) <= registerFile(to_integer(unsigned(memory(count)(25 downto 21)))) + registerFile(to_integer(unsigned(memory(count)(20 downto 16))));
					end if;
					if(memory(count)(31 downto 26) = "000000" and memory(count)(5 downto 0) = "100010") then 
						registerFile(to_integer(unsigned(memory(count)(15 downto 11)))) <= registerFile(to_integer(unsigned(memory(count)(25 downto 21)))) - registerFile(to_integer(unsigned(memory(count)(20 downto 16))));
					end if;
					if(memory(count)(31 downto 26) = "000000" and memory(count)(5 downto 0) = "000000") then 
						registerFile(to_integer(unsigned(memory(count)(15 downto 11)))) <= registerFile(to_integer(unsigned(memory(count)(20 downto 16))))(31 - to_integer(unsigned(memory(count)(10 downto 6))) downto 0) & zero((to_integer(unsigned(memory(count)(10 downto 6))) - 1) downto 0);
					end if;
					if(memory(count)(31 downto 26) = "000000" and memory(count)(5 downto 0) = "000010") then 
						registerFile(to_integer(unsigned(memory(count)(15 downto 11)))) <=  zero(to_integer(unsigned(memory(count)(10 downto 6))) - 1 downto 0) & registerFile(to_integer(unsigned(memory(count)(20 downto 16))))(31 downto to_integer(unsigned(memory(count)(10 downto 6))));
					end if;
					if(memory(count)(31 downto 26) = "101011") then 
						memory(to_integer(unsigned(memory(count)(15 downto 0))) + to_integer(unsigned(registerFile(to_integer(unsigned(memory(count)(25 downto 21))))))) <= registerFile(to_integer(unsigned(memory(count)(20 downto 16))));
					end if;
					if(memory(count)(31 downto 26) = "100011") then 
						registerFile(to_integer(unsigned(memory(count)(20 downto 16)))) <= memory(to_integer(unsigned(memory(count)(15 downto 0))) + to_integer(unsigned(registerFile(to_integer(unsigned(memory(count)(25 downto 21)))))));
					end if;
					if(memory(count) = zero) then 
					   state <= stopped;
					end if;
					count <= count + 1;
				end if;
			end if;
		end if;
	end process;
end Behavioral;
