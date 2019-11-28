library IEEE;
use IEEE.std_logic_1164.all;

entity BREG is
	generic (BitsPerOneWord : integer := 8);
	port (
		CLK, LB_Neg : in std_logic;
		InData : in std_logic_vector(BitsPerOneWord-1 downto 0);
		OutData : out std_logic_vector(BitsPerOneWord-1 downto 0)
	);
end BREG;

architecture RTL of BREG is
begin
	process(CLK)
	begin
		if (CLK'event and CLK = '1') then
			if (LB_Neg = '0') then
				OutData <= InData;
			end if;
		end if;
	end process;
end RTL;
		