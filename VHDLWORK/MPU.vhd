library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity MPU is
	generic(BitsPerOneWord:integer:=8; BitsOfOpCode:integer:=4;
			  NumOfAddressLines:integer:=4; NumOfControlLines:integer:=12);
			  
	port(
				SysCLK, RAMAccessMode_Neg, WRToRAM_Neg, RESET_Neg     : in std_logic;
				InAddressToRAM												      : in std_logic_vector(NumOfAddressLines-1 downto 0);
				InDataToRAM													      : in std_logic_vector(BitsPerOneWord-1 downto 0);
				OutCLKToMPU, OutCLKToRAM, OutCLRToPC_Neg, OutCLRToIREG : out std_logic;
				OutWBUS, OutBinaryDisplay, OutACCToALU, OutBREGToALU  : out std_logic_vector(BitsPerOneWord-1 downto 0);
				OutMARToRAM                                           : out std_logic_vector(NumOfAddressLines-1 downto 0);
				OutIREGToSEQ                                          : out std_logic_vector(BitsOfOpCode-1 downto 0);
				OutControlSignal                                      : out std_logic_vector(NumOfControlLines-1 downto 0)
	);
end MPU;

architecture Structure of MPU is
component PC
		generic (NumOfAddressLines : integer := 4);
		
		port(
			CLK, CLR_Neg, CP, EP : in std_logic;
			OutAddress : out std_logic_vector(NumOfAddressLines-1 downto 0)
	   );
end component;

component MAR
		generic (NumOfAddressLines : integer := 4);
		
		port (
			CLK, LM_Neg : in std_logic;
			InAdress : in std_logic_vector(NumOfAddressLines-1 downto 0);
			OutAdress : out std_logic_vector(NumOfAddressLines-1 downto 0)
		);
end component;

component RAM	
		generic (BitsPerOneWord : integer := 8;
					NumOfAddressLines:integer :=4);
					
		port (
			CLK,CE_Neg,RAMAccessMode_Neg,WR_Neg: in std_logic;
			InAddressFromMAR, InAddressFromUser : in std_logic_vector(NumOfAddressLines-1 downto 0);
			InData : in std_logic_vector(BitsPerOneWord-1 downto 0);
			OutData : out std_logic_vector(BitsPerOneWord-1 downto 0)
		);
end component;

component IREG
		generic (
			BitsPerOneWord : integer := 8;
			BitsOfOpCode : integer := 4;
			NumOfaddressLines : integer := 4
		);
		
		port (
			CLK, CLR, LI_Neg, EI_Neg : in std_logic;
			InInsturuction : in std_logic_vector(BitsPerOneWord-1 downto 0);
			OutOpCode : out std_logic_vector(BitsOfOpCode-1 downto 0);
			OutOperand : out std_logic_vector(NumOfAddressLines-1 downto 0)
		);
end component;

component SEQ	
		generic(BitsOfOpcode : integer := 4; 
				  NumOfControlLines : integer := 12
		);
		
		port(
			InCLK,RESET_Neg, RAMAccess_Neg : in std_logic;
			InOpeCode : in std_logic_vector(BitsOfOpCode - 1 downto 0);
			OutCLKToMPU, OutCLKToRAM : out std_logic;
			OutCLRToPC_Neg, OutCLRToIREG : out std_logic;
			OutControlSignal : out std_logic_vector(NumOfControlLines-1 downto 0)
		);
end component;

component ACC	
		generic (BitsPerOneWord : integer := 8);
		
		port (
			CLK, LA_Neg,EA : in std_logic;
			InData : in std_logic_vector(BitsPerOneWord-1 downto 0);
			OutDataToALU,OutDataToBUS : out std_logic_vector(BitsPerOneWord-1 downto 0)
		);
end component;

component ALU
		generic (BitsPerOneWord : integer := 8);
		
		port (
			SU, EU: in std_logic;
			InDataA, InDataB : in std_logic_vector(BitsPerOneWord-1 downto 0);
			CFlag : out std_logic;
			OutData : out std_logic_vector(BitsPerOneWord-1 downto 0)
		);
end component;

component BREG
		generic (BitsPerOneWord : integer := 8);
		
		port (
			CLK, LB_Neg : in std_logic;
			InData : in std_logic_vector(BitsPerOneWord-1 downto 0);
			OutData : out std_logic_vector(BitsPerOneWord-1 downto 0)
		);
end component;

component OREG	
		generic (BitsPerOneWord : integer := 8);
		
		port (
			CLK, LO_Neg : in std_logic;
			InData : in std_logic_vector(BitsPerOneWord-1 downto 0);
			OutData : out std_logic_vector(BitsPerOneWord-1 downto 0)
		);
end component;

		
signal CLKToMPU, CLKToRAM, CLRToPC_Neg, CLRToIREG, CFlag          : std_logic;
signal WBUS, ACCToALU, BREGToALU, OREGToBinaryDisplay             : std_logic_vector(BitsPerOneWord-1 downto 0);
signal MARToRAM																	: std_logic_vector(NumOfAddressLines-1 downto 0);
signal ControlSignal																: std_logic_vector(NumOfControlLines-1 downto 0);
signal IREGToSEQ																	: std_logic_vector(BitsOfOpCode-1 downto 0);

begin 
		PC0   : PC   port map(CLKToMPU, CLRToPC_Neg, ControlSignal(11), ControlSignal(10), WBUS(NumOfAddressLines-1 downto 0));
		
		MAR0  : MAR  port map(CLKToMPU, ControlSignal(9),WBUS(NumOfAddressLines-1 downto 0), MARToRAM);
		
		RAM0  : RAM  port map(CLKToRAM, ControlSignal(8), RAMAccessMode_Neg, WRToRAM_Neg, MARToRAM, InAddressToRAM, InDataToRAM, WBUS);
		
		IREG0 : IREG port map(CLKToMPU, CLRToIREG, ControlSignal(7),ControlSignal(6), WBUS, IREGToSEQ, WBUS(NumOfAddressLines-1 downto 0));
									 
		SEQ0  : SEQ  port map(SysCLK, RESET_Neg, RAMAccessMode_Neg, IREGToSEQ, CLKToMPU, CLKToRAM, CLRToPC_Neg, CLRToIREG, ControlSignal);
					
		ACC0  : ACC  port map(CLKToMPU, ControlSignal(5), ControlSignal(4), WBUS, ACCToALU, WBUS);
		
		ALU0  : ALU  port map(ControlSignal(3), ControlSignal(2), ACCToALU, BREGToALU, CFlag, WBUS);
		
		BREG0 : BREG port map(CLKToMPU, ControlSignal(1), WBUS, BREGToALU);
		
		OREG0 : OREG port map(CLKToMPU, ControlSignal(0), WBUS, OREGToBinaryDisplay);
									 
		OutWBUS 				 <= WBUS;
		OutControlSignal	 <= ControlSignal;
		OutCLKToMPU			 <= CLKToMPU;
		OutCLKToRAM 		 <= CLKToRAM;
		OutCLRToPC_Neg		 <= CLRToPC_Neg;
		OutCLRToIREG		 <= CLRToIREG;
		OutMARToRAM			 <= MARToRAM;
		OutIREGToSEQ		 <= IREGToSEQ;
		OutACCToALU			 <= ACCToALU;
		OutBREGToALU		 <= BREGToALU;
		OutBinaryDisplay	 <= OREGToBinaryDisplay;
end Structure;

		
									 
		
		
		
		
		
		
