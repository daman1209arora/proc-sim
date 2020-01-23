library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

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
	constant mode0 : std_logic_vector(31 downto 0) := (others => '0');
	constant mode1 : std_logic_vector(31 downto 0) := (0 => '1', others => '0');
    constant mode2 : std_logic_vector(31 downto 0) := (1 => '1', others => '0');
    constant mode3 : std_logic_vector(31 downto 0) := (0 => '1', 1 => '1', others => '0');
            
	constant zero: std_logic_vector(31 downto 0) := (others => '0');
begin
	process (clk)
	begin
		if rising_edge(clk) then	
			if(enb = '1') then
				if(mode = mode0) then 
					O1 <= R1 + R2;
				elsif(mode = mode1) then 	
					O1 <= R1 - R2;
				elsif(mode = mode2) then 
				-- Fill these modes after confirming syntactical issues in Lab.
					O1 <= R1(31 - (to_integer(unsigned(R2))) downto 0 ) & zero( (to_integer(unsigned(R2)) - 1) downto 0);
				else
					O1 <= zero( (to_integer(unsigned(R2)) - 1) downto 0) & R1(31 downto (to_integer(unsigned(R2))) );
				end if;
			end if;
		end if;
	end process;
end Behavioral;
