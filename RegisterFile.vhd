library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RegisterFile is
  PORT (
    clk : IN STD_LOGIC;
    wea : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    
    enb : IN STD_LOGIC;
    addrb1 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    doutb1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    
    addrb2 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    doutb2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
end RegisterFile;

architecture Behavioral of RegisterFile is

	type Memory_type is array (0 to 31) of std_logic_vector (31 downto 0);
	signal Memory_array : Memory_type;
	signal address1 : unsigned (7 downto 0);
    signal address2 : unsigned (7 downto 0);

begin
	doutb2 <= Memory_array (to_integer(address2));
	doutb1 <= Memory_array (to_integer(address1));
	
	
	process (clk)
	begin
	    if rising_edge(clk) then    
	        if (enb = '1') then
	            address2 <= unsigned(addrb2);
	            address1 <= unsigned(addrb1);    
	        end if;	

			if (wea = '1') then
                Memory_array (to_integer(unsigned(addra))) <= dina;	
		    end if;

		end if;
	end process;
end Behavioral;
