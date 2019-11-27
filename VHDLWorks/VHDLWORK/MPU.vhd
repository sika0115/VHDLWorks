library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity SEQ is 
	generic(BitsOfOpCode : integer := 4; NumOfControlLines : integer := 12);
	port(
			InCLK, RESET_Neg, RAMAccess_Neg : in std_logic;
			InOpCode : in std_logic_vector(BitsOfOpCode - 1 downto 0);
			OutCLKToMPU, OutCLKToRAM : out std_logic;
			OutCLRToPC_Neg, OutCLRToIREG : out std_logic;
			OutControlSignal : out std_logic_vector(NumOfControlLines-1 downto 0)
	);
end SEQ;
	
architecture RTL of SEQ is
type t_type_state is(T0,T1,T2,T3,
					 T4_LDA,T5_LDA,T6_LDA,
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
		elsif (t_state = STBY_RAM and RAMAccess_Neg = '1' and RESET_Neg = '1') then
			t_state <= T0; 
		else 
			case t_state is			
				when STBY_CLR => t_state <= T1;
				when T1 	  => t_state <= T2;
				when T2 	  => t_state <= T3;
				when T3 	  => if (InOpCode = "0000") then    
									t_state <= T4_LDA;
								 elsif (InOpCode = "0001") then
									t_state <= T4_ADD;
								 elsif (InOpCode = "0010") then
									t_state <= T4_SUB;
								 elsif (InOpCode = "1110") then
									t_state <= T4_OUT;
								 elsif (InOpCode = "1111") then
									t_state <= T4_HLT;
								 else 
									t_state <= T0;
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

OutCLKToRAM      <= InCLK when (t_state = STBY_RAM) else '0';
OutCLKToMPU		 <= '0' when (t_state = T0) or 
							 (t_state = STBY_RAM) or
							 (t_state = STBY_CLR) else
							  InCLK;
OutCLRToPC_Neg   <= '0' when (t_state = STBY_CLR) else '1';
OutCLRToIREG     <= '1' when (t_state = STBY_CLR) else '0';

OutControlSignal <= "010111100011" when (t_state = T1) else 
					"101111100011" when (t_state = T2) else
					"001001100011" when (t_state = T3) else
						  
					"000110100011" when (t_state = T4_LDA) else
					"001011000011" when (t_state = T5_LDA) else
					"001111100011" when (t_state = T6_LDA) else
			    
					"000110100011" when (t_state = T4_ADD) else
					"001011100001" when (t_state = T5_ADD) else
					"001111000111" when (t_state = T6_ADD) else

					"000110100011" when (t_state = T4_SUB) else
					"001011100001" when (t_state = T5_SUB) else
					"001111001111" when (t_state = T6_SUB) else
						  
					"001111110010" when (t_state = T4_OUT) else
					"001111100011" when (t_state = T5_OUT) else
					"001111100011" when (t_state = T6_OUT) else

					"001111100011" when (t_state = T4_HLT) else
					"001111100011" when (t_state = T5_HLT) else
					"001111100011" when (t_state = T6_HLT) else				
						  
					"001011100011" when (t_state = STBY_RAM) else
					"001111100011" when (t_state = STBY_CLR) else
					"001111100011";
end RTL;
