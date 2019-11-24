library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity RAM is
	generic (BitsPerOneWord : integer := 8; NumOfAddressLines : integer := 4);
	port (
		CLK, CE_Neg, RAMAccessMode_Neg, WR_Neg : in std_logic;
		InAddressFromMAR, InAddressFromUser : in std_logic_vector(NumOfAddressLines - 1 downto 0);
		InData : in std_logic_vector(BitsPerOneWord - 1 downto 0);
		OutData : out std_logic_vector(BitsPerOneWord - 1 downto 0)
	);
end RAM;

architecture RTL of RAM is
subtype REG is std_logic_vector(BitsPerOneword -1 downto 0);
type ARRAY_REGS is array(0 to 2**NumOfAddressLines - 1)of REG;
signal regfile : ARRAY_REGS;
begin
	process(CLK)
	begin
		if(CLK'event and CLK = '1') then 
			if (CE_Neg = '0' and WR_Neg = '0') then
				regfile(conv_integer(InAddressFromUser)) <= Indata;
			end if;
		end if;
	end process;
	
	process(CE_Neg, RAMAccessMode_Neg)
	begin
		if(CE_Neg = '0' and RAMAccessMode_Neg = '0') then
			OutData <= regfile(conv_integer(InAddressFromUser));
		elsif(CE_Neg = '0' and RAMAccessMode_Neg = '1') then
			OutData <= regfile(conv_integer(InAddressFromMAR));	
		else 
			OutData <= (others => 'Z');
		end if;
	end process;
end RTL;