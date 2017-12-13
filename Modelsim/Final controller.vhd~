library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_logic_arith.All;

--defines ports 
ENTITY synchr_state_mach IS
  PORT(
        --in
        clk: in std_logic;
        reset : in std_logic := '0';
        em_s: in std_logic := '0';
        buttons: in std_logic_vector(3 downto 0) := "0000";
        open_close: in std_logic := '0';
       
       --out
        zout : out std_logic_vector( 3 downto 0) := "0000";		--change back to inout
        stop:out std_logic := '0';
        door:out std_logic := '0';
        motor_up:out std_logic := '0';
        motor_down:out std_logic := '0';   
        
        --seven segment display 
        display_floor: inout std_logic_vector (1 downto 0);		-- used for 7 seg to display current floor, this replaces the led's on the nexsys
        seven_segment_disp: out std_logic_vector(6 downto 0);		--controls which bits turn on and off on the display
        anode:out std_logic_vector(3 downto 0);				--common anode control vector
	
);
END synchr_state_mach;

ARCHITECTURE behavioral OF synchr_state_mach IS
    TYPE state IS (idle, queue, up_st, up_update, e_stop, down_st, down_update, open_st, close_st);
      
    signal current_state, next_state : state := idle;			--defines current and next state as signal as the type state intialized to idle
    signal cur_floor : integer := 0;					--keeps current floor stored as a integer variable
    signal floor : std_logic_vector(3 downto 0) := "0000";		--keeps floor queue
    signal timer_close : std_logic  := '0';				--creates timer for close door
    signal timer_open : std_logic := '0';				--creates timer for open door
    signal el_top : std_logic := '0';					--signal to simulate elevator top sensor
    signal up, down : std_logic := '0';					--up and down signals

    

BEGIN
display_floor <= conv_std_logic_vector(cur_floor,2);
combat_proc :PROCESS(current_state, up,down, el_top, em_s, timer_open, timer_close, open_close) IS

BEGIN
CASE current_state is
 --IDLE state
    when idle =>
      zout<="0000";
      motor_up<='0';
      motor_down<='0';
      stop<='0';
        
      if(up='1'or down='1')then
        next_state <= queue;
      else
        next_state<=idle;
      END IF;
      
--QUEUE State      
    when queue => 
      zout<="0001";
      motor_up<='0';
      motor_down<='0';
      stop<='0';
     
--determines next state based on inputs 
      if(up='1') then
        next_state<=up_st;
      elsif (up='0' and down ='1')then
        next_state<=down_st;
      else
        next_state <=idle;
      END IF;
    
--Up state     
    when up_st => 
      zout<="0010";
      motor_up<='1';
      motor_down<='0';
      stop<='0';
      
--determines next state based on inputs
      if (em_s='1')then
        next_state<=e_stop;
       elsif(floor(cur_floor) = '1') then 
        next_state <= open_st; 
      elsif(el_top='1') then
        next_state<=up_update;
      else
        next_state<=up_st;
      
      End if;

--UPDATE FLoor 1
    when up_update => 
        zout<= "0011";
        if(el_top = '0')then
          next_state <= up_st;
        else
          next_state <= up_update;
        end if;
        
        
       

    
--Down State     
    when down_st => 
      zout <= "0100";
      motor_up<='0';
      motor_down<='1';
      stop<='0';
 
--determines next state based on inputs     
      if(em_s = '1') then
        next_state <= e_stop;
      elsif(floor(cur_floor) ='1')then
        next_state<=open_st;
      elsif(el_top='1')then 
        next_state <= down_update;
      else
        next_state<= down_st;        
      end if;
         

--Update Floor 2 State
    when down_update => 
        zout<= "0101";
--determines next state based on inputs        
	if(el_top = '0')then
          next_state <= down_st;
        else
          next_state <= down_update;
        end if;
        
      

--Emergency Stop       
    when e_stop =>
      zout<= "0110"; 
      motor_up<='0';
      motor_down<='0';
      stop<='1';
--determines next state based on inputs      
      if(em_s ='0' and up ='0'and down ='1') then
        next_state<= down_st;
      elsif(em_s ='0' and up ='1') then
        next_state <= up_st;
      else
        next_state <= e_stop;
      end if;


--Open Doors    
    when open_st =>
      zout<= "0111";
      motor_up<='0';
      motor_down<='0';
      stop<='0';
      door<='1';
--determines next state based on inputs     
      if(timer_open = '1' or open_close ='1')then -- open/close = 1 ------ door is open
        next_state <=open_st;
      elsif(timer_open = '0' and open_close = '0') then
        next_state <= close_st;
      END IF; 
    
--Close doors    
    when close_st =>
      zout<= "1000";
      motor_up<='0';
      motor_down<='0';
      stop<='0';
      door<='0';
--determines next state based on inputs      
      if(timer_close = '1' and open_close ='1')then
        next_state <= open_st;
      elsif(timer_close = '1' and open_close ='0') then 
        next_state <= close_st;
      elsif(timer_close ='0' and open_close = '0') then
        next_state<= queue;
      end if;         
        
END CASE;
END PROCESS combat_proc;


Clk_proc : process(reset, clk) is-- does this every clock cycle
Begin
      if (reset = '1' ) then
          current_state <= idle;
      elsif (clk'event and clk = '1') then
          current_state <= next_state;  
      end if;       
          
        -- Loop to determine direction, up or down, checked every clock 
          up <='0';
          down <= '0';
           
            for I in 0 to 3 loop--loop structure to count through each floor iteration
              
              if(I >= cur_floor)then --if the floor iteration is greater than or equal to the current floor  and the floor iteration is =1 then up =1, go up
                if(floor(I) = '1')then
                  up <= '1';
                end if;
              else
                if(floor(I) = '1')then-- else if the floor iteration is still 1 set down =1,go down
                  down <='1';
                end if;
              end if;
            end loop;
       
       

End process clk_proc;



floor_process: process(clk,current_state)
begin
 --FLOOR 0
  if(clk'event and clk = '1')then
  
    if(buttons(0) = '1') then 
      floor(0) <='1';
    end if;
    if(current_state = close_st and cur_floor= 0) then
      floor(0) <= '0';
    End if;
 
 -- FLOOR 1
    if(buttons(1) = '1') then 
      floor(1) <='1';
    end if;
    if(current_state = close_st and cur_floor= 1) then
      floor(1) <= '0';
    End if;
  
-- FLOOR 2
    if(buttons(2) = '1') then 
      floor(2) <='1';
    end if;
    if(current_state = close_st and cur_floor= 2) then
      floor(2) <= '0';
    End if;
  
-- FLOOR 3
    if(buttons(3) = '1') then 
      floor(3) <='1';
    end if;
    if(current_state = close_st and cur_floor= 3) then
      floor(3) <= '0';
    End if; 
  end if; 
  
End process floor_process;  


--timers open Process
timer_open_proc: process(current_state,clk) is

--variable count_open : integer := 100000000;--used for xilinx
variable count_open : integer := 2;--used for modelsim
Begin
  if(clk'event and clk='0')then
    if(current_state = open_st)then
     if(count_open=0)then
        timer_open<='0';
        --count_open:= 100000000;--used for xilinx
        count_open:=2;--used for modelsim
      else
        timer_open<= '1';
        count_open:=count_open-1;  
      End if; 
    End if;
  End if;  
End Process timer_open_proc;


--timer close Process
timer_close_proc: process(current_state,clk) is

--variable count_close : integer := 100000000;--used for xilinx
variable count_close: integer :=2;--used for modelsim

Begin
   if(clk'event and clk='0')then
    if(current_state = close_st)then
     if(count_close=0)then
        timer_close<='0';
        --count_close := 100000000;--used for xilinx
        count_close := 2;--used for modelsim
      else
        timer_close<= '1';
        count_close:=count_close-1;  
      End if; 
    End if;
  End if;  
End Process timer_close_proc;

 
--timer to el_top sensor Process
sensor_timer: process(current_state,clk) is

--variable count : integer := 100000000;--used for xilinx
Variable count: integer :=2;--used for modelsim
Begin
  if(clk'event and clk = '0')then
    if(current_state = up_st or current_state = down_st)then
      if(count = 0)then
        --count := 100000000;--used for xilinx
        count := 2;--used for modelsim
        el_top <= '1';
      else
        count := count -1;
      end if;
    elsif(current_state = up_update)then
      if(count = 0)then
      --count := 100000000;--used for xilinx
        count := 2;--used for modelsim
        el_top <= '0';
        cur_floor <= cur_floor + 1;
      else
        count := count -1;
      end if;
    elsif(current_state = down_update)then
      if(count = 0)then
        --count := 100000000;--used for xilinx
        count := 2;--used for modelsim
        el_top <= '0';
        cur_floor <= cur_floor -1;
      else
        count := count - 1;
      end if;
    end if;
  end if;

End Process sensor_timer;

seven_seg_proc: process(clk, display_floor)
begin
  if(clk'event and clk='0')then
    case display_floor is 
      when "00" =>
      seven_segment_disp <="1001111";
      anode<= "1110";
        
      when "01" =>
      seven_segment_disp <="0010010";
      anode<="1110";  
        
      when "10" =>
      seven_segment_disp <="0000110";
      anode<="1110";
        
      when "11" =>
      seven_segment_disp <="1001100";
      anode<="1110";
		
      when others =>
      seven_segment_disp<="1111111";
      anode<= "1111";
		
		
  end case;
  end if;
end process;

End behavioral;

