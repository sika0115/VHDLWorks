library IEEE;
use IEEE.std_logic_1164.all;

entity IREG is
	generic (
		BitsPerOneWord : integer := 8;
		BitsOfOpCode : integer := 4;
		NumOfAddressLines : integer := 4
	);
	--confirm (BitsPerOneWord)=(BitsOfOpCode)+(NumOdAddressLines)!!
	port (
		CLK, CLR, LI_Neg, EI_Neg : in std_logic;
		InInstruction : in std_logic_vector(BitsPerOneWord-1 downto 0);
		OutOpCode : out std_logic_vector(BitsOfOpCode-1 downto 0);
		OutOperand : out std_logic_vector(NumOfAddressLines-1 downto 0)
	);
end IREG;

architecture RTL of IREG is
signal instruction : std_logic_vector(BitsPerOneWord-1 downto 0);
begin
	process(CLK)
	begin
		if (CLK'event and CLK = '1') then 
			if (CLR = '1') then
				instruction <= (others =>'0');
			elsif (CLR = '0' and LI_Neg = '0') then
				instruction <= InInstruction;
			end if;
		end if; 
	end process;
	
	OutOpCode <= instruction(BitsPerOneWord-1 downto BitsPerOneWord - BitsOfOpCode);
	
	process(EI_Neg)
	begin
		if(EI_Neg = '0') then
			OutOperand <= instruction(NumOfAddressLines - 1 downto 0);
		else 
			OutOperand <= (others => 'Z');
		end if;
	end process;
end RTL;
		
		