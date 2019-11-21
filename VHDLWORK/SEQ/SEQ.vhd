library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity SEQ is 
	generic(BitsOfOpcode : integer := 4 NumOfControlLines : integer := 12);
	port(
			InCLK,RESET_Neg, RAMAccess_Neg : in std_logic;
			InOpeCode : in std_logic_vector(BitsOfOpCode - 1 downto 0);
			OutCLKToMPU, OutCLKToRAM : out std_logic;
			OutCLRToPC_Neg, OutCLRToIREG : out std_logic;
			OutControlSignal : out std_logic_vector(NumOfControlLines-1 downto 0)
	);
end SEQ;
	
architecture RTL of SEQ is
type t_type_state is(T0,T1,T2,T3,T4_LDA,T5_LDA,T6_LDA,
											T4_ADD,T5_ADD,T6_ADD,
											T4_SUB,T5_SUB,T6_SUB,
											T4_OUT,T5_OUT,T6_OUT,
											T4_HLT,T5_HLT,T6_HLT,
											STBY_RAM,STBY_CLR);
signal t_state : t_type_state;	
begin
process(InCLK)
begin
	if(InCLK'event and InCLK = '0') then
		if (RAMAccess_Neg = '0') then
			t_state <= STBY_RAM;
		elsif (RAMAccess_Neg = '1' and RESET_Neg = '0') then
			t_state <= STBY_CLR;
		else
			case t_state is
				when STBY_RAM => if(RAMAccess_Neg = '1' and RESET_Neg = '1') then
											t_state <= T0;
										end if;
				
				when STBY_CLR => t_state <= T1;
				when T1 		  => t_state <= T2;
				when T2 		  => t_state <= T3;
				when T3 		  => 
									   if (InOpeCode = "0000") then
											t_state <= T4_LDA;
										elsif (InOpeCode = "0001") then
											t_state <= T4_ADD;
										elsif (InOpeCode = "0010") then
											t_state <= T4_SUB;
										elsif (InOpeCode = "1110") then
											t_state <= T4_OUT;
										else
											t_state <= T4_HLT;
										end if;
				when T4_LDA 	=> t_state <= T5_LDA;
				when T5_LDA		=> t_state <= T6_LDA;
				when T6_LDA		=> t_state <= T1;
				
				when T4_ADD 	=> t_state <= T5_ADD;
				when T5_ADD		=> t_state <= T6_ADD;
				when T6_ADD		=> t_state <= T1;
				
				when T4_SUB 	=> t_state <= T5_SUB;
				when T5_SUB		=> t_state <= T6_SUB;
				when T6_SUB		=> t_state <= T1;
				
				when T4_OUT 	=> t_state <= T5_OUT;
				when T5_OUT		=> t_state <= T6_OUT;
				when T6_OUT		=> t_state <= T1;
				
				when T4_HLT 	=> t_state <= T5_HLT;
				when T5_HLT		=> t_state <= T6_HLT;
				when T6_HLT		=> t_state <= T0;
				when others   => t_state <= T0;	
			end case;
		end if;
	end if;
end process;

OutCLKToRAM      <= InCLK when (t_state = STBY_RAM) else
						  '0';
OutCLKToMPU		  <= '0' when (t_state = T0) or 
									  (t_state = STBY_RAM) or
									  (t_state = STBY_CLR) else
									  InCLK;
OutCLRToPC_Neg   <= '0' when (t_state = STBY_CLR) else
                 	  '1';
OutCLRToIREG     <= '1' when (t_state = STBY_CLR) else 
                    '0';
OutControlSignal <= "0101111000011" when (t_state = T1) else 
						  "10100010" when (t_state = T2) else
						  "10100011" when (t_state = T3) else
						  
						  "00000100" when (t_state = T4_LDA) else
						  "00000101" when (t_state = T5_LDA) else
						  "00000110" when (t_state = T6_LDA) else
						  
						  "00010100" when (t_state = T4_ADD) else
						  "00010101" when (t_state = T5_ADD) else
						  "00010110" when (t_state = T6_ADD) else
						  
						  "00100100" when (t_state = T4_SUB) else
						  "00100101" when (t_state = T5_SUB) else
						  "00100110" when (t_state = T6_SUB) else
						  
						  "11100100" when (t_state = T4_OUT) else
						  "11100101" when (t_state = T5_OUT) else
						  "11100110" when (t_state = T6_OUT) else
						  
						  "11110100" when (t_state = T4_HLT) else
						  "11110101" when (t_state = T5_HLT) else
						  "11110110" when (t_state = T6_HLT) else
						  "01010101" when (t_state = STBY_RAM) else
						  "001111100011" when (t_state = STBY_CLR) else
						  "001111100011";
end RTL;
	 
					