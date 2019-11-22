library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity PC is
	generic (NumOfAddressLines : integer := 4);

	port (
		CLK, CLR_Neg, CP, EP : in std_logic;
		OutAddress : out std_logic_vector(NumOfAddressLines-1 downto 0)
	);
end PC;

architecture RTL of PC is
signal count:std_logic_vector(NumOfAddressLines-1 downto 0);
begin
	process(CLK)
	begin
		if (CLK'event and CLK = '0' )then 
			if (CLR_Neg = '0') then
				count <= (others => '0');
			elsif (CLR_Neg = '1' and CP = '1') then 
				count <= count + '1';
			end if;
		end if;
	end process;
	
	process(EP)
	begin
		if(EP='1') then
			OutAddress <= count;
		else
			OutAddress <=(others => 'Z');
		end if;
		
	end process;
end RTL;
		
		
			
