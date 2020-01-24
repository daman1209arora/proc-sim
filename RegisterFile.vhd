library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RegisterFile is
  PORT (
    clk : IN STD_LOGIC;
    wea1 : IN STD_LOGIC;
    addra1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    dina1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    
    wea2: IN STD_LOGIC;
    addra2: IN STD_LOGIC_VECTOR(4 downto 0);
    dina2 : IN STD_LOGIC_VECTOR(31 downto 0); 
    
    enb : IN STD_LOGIC;
    addrb1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    doutb1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    
    addrb2 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    doutb2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    
    addrb3 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    doutb3 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
end RegisterFile;

architecture Behavioral of RegisterFile is

	type Memory_type is array (0 to 31) of std_logic_vector (31 downto 0) ;
	signal Memory_array : Memory_type := (0 => "00000000000000000000000000000010",
	                                       1 =>  "00000000000000000000000000000101",
	                                       others => "00000000000000000000000000000000");
	signal address1 : unsigned (4 downto 0);
    signal address2 : unsigned (4 downto 0);
    signal address3 : unsigned (4 downto 0);

begin
	doutb3 <= Memory_array (to_integer(address3));
	doutb2 <= Memory_array (to_integer(address2));
	doutb1 <= Memory_array (to_integer(address1));
	
	
	process (clk)
	begin
	    if rising_edge(clk) then    
	        if (enb = '1') then
	            address3 <= unsigned(addrb3);
	            address2 <= unsigned(addrb2);
	            address1 <= unsigned(addrb1);    
	        end if;	

			if (wea1 = '1') then
                Memory_array (to_integer(unsigned(addra1))) <= dina1;   	
		    end if;
            
            if (wea2 = '1') then
                Memory_array (to_integer(unsigned(addra2))) <= dina2;       
            end if;

            if (wea3 = '1') then
                Memory_array (to_integer(unsigned(addra3))) <= dina3;       
            end if;
		end if;
	end process;
end Behavioral;
