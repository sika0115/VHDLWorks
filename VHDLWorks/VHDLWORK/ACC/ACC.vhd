library IEEE;
use IEEE.std_logic_1164.all;

entity ACC is
	generic (BitsPerOneWord : integer := 8);
	port (
		CLK, LA_Neg,EA : in std_logic;
		InData : in std_logic_vector(BitsPerOneWord-1 downto 0);
		OutDataToALU,OutDataToBUS : out std_logic_vector(BitsPerOneWord-1 downto 0)
	);
end ACC;

architecture RTL of ACC is
signal accumulator:std_logic_vector(BitsPerOneWord-1 downto 0);
begin
	process(CLK)
	begin
		if (CLK'event and CLK = '1' and LA_Neg = '0') then
			accumulator <= InData;
		end if;
	end process;
	
	OutDataToALU <= accumulator;
	
	process(EA)
	begin
		if(EA = '1') then
			OutDataToBUS <= accumulator;
		else 
			OutDataToBUS <= (others => 'Z');
		end if;
	end process;
end RTL;
		
		