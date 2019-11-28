library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity SEQ is 
	port(
			InCLK,RESET_Neg : in std_logic;
			OutCLRToPC_Neg, OutCLRToIREG : out std_logic;
			OutControlSignal : out std_logic_vector(7 downto 0)
	);
end SEQ;
	
architecture RTL of SEQ is
type t_type_state is(T0,T1,T2,T3,T4,T5,T6,STBY_CLR);
signal t_state : t_type_state;	
begin
process(InCLK)
begin
	if(InCLK'event and InCLK = '0') then
		if(RESET_Neg = '0') then
			t_state <= STBY_CLR;
		else
			case t_state is
				when STBY_CLR => t_state <= T1;
				when T1 		  => t_state <= T2;
				when T2 		  => t_state <= T3;
				when T3 		  => t_state <= T4;
				when T4 		  => t_state <= T5;
				when T5 		  => t_state <= T6;
				when T6 		  => t_state <= T0;
				when others   => t_state <= T0;	
			end case;
		end if;
	end if;
end process;
OutCLRToPC_Neg   <= '0' when (t_state = STBY_CLR) else
                 	  '1';
OutCLRToIREG     <= '1' when (t_state = STBY_CLR) else 
                    '0';
OutControlSignal <= "10100001" when (t_state = T1) else 
						  "10100010" when (t_state = T2) else
						  "10100011" when (t_state = T3) else
						  "10100100" when (t_state = T4) else
						  "10100101" when (t_state = T5) else
						  "10100110" when (t_state = T6) else
						  "11000000" when (t_state = STBY_CLR) else
						  "10101010";
end RTL;
	 
					