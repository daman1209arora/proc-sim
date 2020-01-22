library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
  PORT (
    clk : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    R1 : IN STD_LOGIC_VECTOR(31 downto 0);
    R2 : IN STD_LOGIC_VECTOR(31 downto 0);
    mode : IN STD_LOGIC_VECTOR(1 downto 0);
 	O1: OUT STD_LOGIC_VECTOR(31 downto 0)
  );
end ALU;


	--Mode encoding:
	--0 - add
	--1 - sub
	--2 - sll
	--3 - srl
	--Before output is changed enb must be set to one. 
	--In the next clock cycle, the output is changed.

architecture Behavioral of ALU is
	signal shamt : integer := 0;
begin
	process (clk)
	begin
		if rising_edge(clk) then	
			if(enb = '1') then
				if(mode = "00") then 
					O1 <= R1 + R2;
				elsif(mode = "01") then 	
					O1 <= R1 - R2;
				else if(mode = "10") then 
				-- Fill these modes after confirming syntactical issues in Lab.
					O1 <= "00";
				else
					O1 <= "00";	
				end if;
			end if;
		end if;
	end process;
end Behavioral;