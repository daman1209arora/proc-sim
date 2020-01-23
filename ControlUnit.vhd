library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ControlUnit is
  Port (clk: IN STD_LOGIC;
        start: IN STD_LOGIC;
        reset: IN STD_LOGIC);
end ControlUnit;

architecture Behavioral of ControlUnit is
    signal instr: STD_LOGIC_VECTOR(1 downto 0);
    signal rfenb: STD_LOGIC;
    signal rfwea: STD_LOGIC;
    signal rfaddr1: STD_LOGIC_VECTOR(7 downto 0);
    signal rfaddr2: STD_LOGIC_VECTOR(7 downto 0);
    signal rfWrite: STD_LOGIC_VECTOR(7 downto 0);    
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
    signal aluMode: STD_LOGIC_VECTOR(1 downto 0);
    
    
    component ALU is port(
            clk, enb : IN STD_LOGIC;
            R1, R2 : IN STD_LOGIC_VECTOR(31 downto 0);
            mode : IN STD_LOGIC_VECTOR(1 downto 0);
            O1: OUT STD_LOGIC_VECTOR(31 downto 0)
         );
    end component;
    
    component MU is port(
            clka,clkb, wea, enb : IN STD_LOGIC;
            addra, addrb : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            dina, doutb : IN STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    end component;
    
    component RF is port(
        clk, wea, enb : IN STD_LOGIC;
        addra, addrb1, addrb2 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        dina, doutb1, doutb2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    end component;
begin
    alu_comp: ALU port map(clk => clk, enb => aluenb, R1 => reg1, R2 =>reg2, mode => instr, O1 => regWrite);
    mu_comp: MU port map(clka => clk, clkb => clk, wea => muwea, enb => muenb, addra => muaddrr, addrb => muaddrw, dina => reg1, doutb => regWrite);
    rf_comp: RF port map(clk =>clk, wea => rfwea, enb => rfenb, addra => rfWrite, addrb1 => rfaddr1, addrb2 => rfaddr2, dina => regWrite, doutb1 => reg1, doutb2 => reg2);

end Behavioral;
