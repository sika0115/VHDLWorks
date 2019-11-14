library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity ALU is
	generic (BitsPerOneWord : integer := 8);

	port (
		SU, EU: in std_logic;
		InDataA, InDataB : in std_logic_vector(BitsPerOneWord-1 downto 0);
		CFlag : out std_logic;
		OutData : out std_logic_vector(BitsPerOneWord-1 downto 0)
	);
end ALU;

architecture RTL of ALU is
signal solution:std_logic_vector(BitsPerOneWord downto 0);
begin
	process(EU,SU)
	begin
		if (EU = '1' and SU = '0') then
			solution <= ('0' & InDataA) + ('0' & InDataB);
			OutData <= solution(BitsPerOneWord-1 downto 0);
			CFlag <= solution(BitsPerOneWord);
			
		elsif (EU = '1' and SU = '1') then
			solution <= ('1' & InDataA) - ('0' & InDataB);
			OutData <= solution(BitsPerOneWord-1 downto 0);
			CFlag <= not solution(BitsPerOneWord);
			
		elsif (EU = '0' and SU = '0') then
			solution <= ('0' & InDataA) - ('0' & InDataB);
			OutData <= (others => 'Z');
			CFlag <= solution(BitsPerOneWord);
			
		else
			solution <= ('1' & InDataA) - ('0' & InDataB);
			OutData <= (others => 'Z');
			CFlag <= not solution(BitsPerOneWord);
		end if;
	end process;
end RTL;
		
		