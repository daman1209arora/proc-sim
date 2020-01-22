library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RegisterFile is
  PORT (
    clk : IN STD_LOGIC;
    wea : IN STD_LOGIC;
    increment: IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    enb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    reset: IN std_logic
  );
end RegisterFile;

architecture Behavioral of RegisterFile is
	-- Reserve address 31 for the program counter.
	-- Every time a '1' on increment is observed 
	-- on the rising edge of the clock, increment  
	-- memory(31) by 1. Reset sets it back to 0.
	--		Confirm syntax in lab. 

	type Memory_type is array (0 to 31) of std_logic_vector (31 downto 0);
	signal Memory_array : Memory_type;
	signal address : unsigned (7 downto 0);

begin
	doutb <= Memory_array (to_integer(address));
	process (clk)
	begin
	    if rising_edge(clk) then    
	        if (enb = '1') then
	            address <= unsigned(addrb);    
	        end if;	

	        if(increment = '1')
	        	Memory_array(31) <= Memory_array(31) + 1;
	        end if;

			if(reset = '1') then 
				Memory_array(31) <= "00000000";
			end if;

			if (wea = '1') then
					Memory_array (to_integer(unsigned(addra))) <= dina (7 downto 0);	
		    end if;

		end if;
	end process;
end Behavioral;