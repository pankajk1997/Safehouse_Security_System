library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity safehouse is
    Port ( keypad : in BIT_VECTOR(0 to 7);
			  getin : in BIT;
			  getout : in BIT;
			  fire : in BIT;
			  gas : in BIT;
			  pir : in BIT;
			  keyled : out  BIT_VECTOR(0 TO 4);
			  buzzer : out BIT_VECTOR(0 to 3);
			  relay : out BIT;
			  relay1 : out BIT;
			  servo : out BIT;
			  servo1 : out BIT;
			  clk : in STD_LOGIC );
end safehouse;

architecture safehouse of safehouse is

signal temp : bit_vector(0 to 7) := "00000000";
signal i : integer range 0 to 5 := 0;
signal dcount : integer range 0 to 50000001 := 0;
signal ncount : integer range 0 to 10 := 0;
signal temp1 : bit := '1';
signal temp2 : bit := '1';
signal people : integer range 0 to 100 := 0;
signal capture : bit := '0';
signal temp3 : bit_vector(0 to 7) := "00000000";
signal d1count : integer range 0 to 50000001 := 0;
signal n1count : integer range 0 to 10 := 0;
signal capture1 : bit := '0';
signal unlock : bit := '0';

begin

buzzer_alarm: process(clk,keypad,fire,gas,pir,unlock,temp3,d1count,n1count,capture1)
begin
	if (rising_edge(clk)) then
		
		if keypad /= temp3 then		
			if keypad = "00010010" then
				if capture1 = '1' then
					capture1 <= '0';	
				else
					capture1 <= '1';
				end if;
			end if;
			temp3 <= keypad;
		end if;	
		
		if (( fire = '1' )or( gas = '1' )) then
			capture1 <= '1';
		end if;
		
		if ((pir = '1')and(unlock = '0')) then
			capture1 <= '1';
		end if;
				
		if capture1 = '1' then		
		
			relay1 <= '1';
			d1count <= d1count + 1;
			if d1count >= 50000000 then
				if (n1count rem 2) = 0 then		
					buzzer(0) <= '1';
					buzzer(1) <= '1';
					buzzer(2) <= '1';
					buzzer(3) <= '1';								
				else
					buzzer(0) <= '0';
					buzzer(1) <= '0';
					buzzer(2) <= '0';
					buzzer(3) <= '0';							
				end if;
				d1count <= 0;
				n1count <= n1count + 1;
					
				if n1count > 8 then
					n1count <= 0;
				end if;
			end if;	
				
		else
		
			relay1 <= '0';
								
			buzzer(0) <= '0';
			buzzer(1) <= '0';
			buzzer(2) <= '0';
			buzzer(3) <= '0';				
					
		end if;
	end if;
end process buzzer_alarm;


passwd_interface: process(clk,keypad,getin,getout,temp,i,dcount,ncount,temp1,temp2,people,capture)

	type integer_vector is array (0 to 3) of integer;
	constant passoriginal : integer_vector := (2,5,2,6);
	variable passcode : integer_vector := (0,0,0,0);

begin
	if (rising_edge(clk)) then
	
		keyled(4) <= '1';
							
		if i < 4 then
			
			keyled(0) <= '1';
			unlock <= '0';
			servo <= '0';
			servo1 <= '0';
			
			if (temp /= keypad) then
				case temp is
					when "10001000" => 
						passcode(i) := 1;
						keyled(i+1) <= '1';
						i <= i + 1;
					when "10000100" => 
						passcode(i) := 2;
						keyled(i+1) <= '1';
						i <= i + 1;
					when "10000010" => 
						passcode(i) := 3;
						keyled(i+1) <= '1';
						i <= i + 1;
					when "01001000" => 
						passcode(i) := 4;
						keyled(i+1) <= '1';
						i <= i + 1;
					when "01000100" => 
						passcode(i) := 5;
						keyled(i+1) <= '1';
						i <= i + 1;
					when "01000010" => 
						passcode(i) := 6;
						keyled(i+1) <= '1';
						i <= i + 1;
					when "00101000" => 
						passcode(i) := 7;
						keyled(i+1) <= '1';
						i <= i + 1;
					when "00100100" => 
						passcode(i) := 8;
						keyled(i+1) <= '1';
						i <= i + 1;
					when "00100010" => 
						passcode(i) := 9;
						keyled(i+1) <= '1';
						i <= i + 1;
					when "00010100" => 
						passcode(i) := 0;
						keyled(i+1) <= '1';
						i <= i + 1;
					when others => null;
				end case;
				temp <= keypad;
			end if;
			
		else
			
			if passcode = passoriginal then
			
				relay <= '1';
				unlock <= '1';
				servo <= '1';
				servo1 <= '1';
					
				if getin /= temp1 then
					if getin = '0' then
						people <= people + 1;
					end if;
					temp1 <= getin;
				end if;
					
				if getout /= temp2 then
					if getout = '0' then
						people <= people - 1;
					end if;
					temp2 <= getout;
				end if;
					
				if keypad = "00011000" then
					capture <= '1';
				end if;
									
				if capture = '1' then
					if people <= 0 then
					
						capture <= '0';
						passcode := (0,0,0,0);
						i <= 0;
						
						relay <= '0';
						keyled <= ('1','0','0','0','1');
							
					else
						
						dcount <= dcount + 1;
						if dcount >= 50000000 then
							if (ncount rem 2) = 0 then		
								keyled <= ('1','1','1','1','1');
							else
								keyled <= ('0','0','0','0','1');
							end if;
							dcount <= 0;
							ncount <= ncount + 1;
								
							if ncount >= 8 then
								ncount <= 0;
								capture <= '0';
							end if;
						end if;		
					end if;
					
				else
				
					keyled <= ('1','1','1','1','1');

				end if;
										
			else
			
				dcount <= dcount + 1;
				if dcount >= 50000000 then
					if (ncount rem 2) = 0 then	
						keyled <= ('1','1','1','1','1');
					else
						keyled <= ('0','0','0','0','1');
					end if;
					dcount <= 0;
					ncount <= ncount + 1;
						
					if ncount >= 8 then
						ncount <= 0;
						passcode := (0,0,0,0);
						i <= 0;
						
						keyled <= ('1','0','0','0','1');
					end if;
				end if;																				
			end if;		
		end if;		
	end if;
		
end process passwd_interface;

end safehouse;