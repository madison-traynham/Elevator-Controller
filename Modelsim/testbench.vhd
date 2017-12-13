library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


ENTITY test_bench IS
END test_bench;

ARCHITECTURE behavior of test_bench is
  
  component c1 is 
    port(
      --inputs
      clk: in std_logic;
      reset : in std_logic;
      em_s: in std_logic;
      buttons: in std_logic_vector(3 downto 0);
      open_close: in std_logic := '0';
    
      --outputs
      zout : out std_logic_vector( 3 downto 0);
      stop:out std_logic;
      door:out std_logic;
      motor_up:out std_logic;
      motor_down:out std_logic
    );
  end component;
  
    --declare inputs and initialize them
    signal clk: std_logic := '1';
    signal reset: std_logic := '0';
    signal em_s: std_logic;
    signal buttons: std_logic_vector(3 downto 0);
    signal open_close: std_logic;
    
    --declare outputs and initialize them
    signal zout : std_logic_vector( 3 downto 0);
    signal stop: std_logic;
    signal door: std_logic;
    signal motor_up: std_logic;
    signal motor_down: std_logic;
    

  
  constant clk_period: time := 100 ps;
    FOR ALL :c1  use entity work.synchr_state_mach;
  begin
    
    g0: c1 PORT MAP (clk, reset, em_s, buttons, open_close, zout, stop, door, motor_up, motor_down);

    clk_process: process
    begin
      clk <= '0';
      wait for clk_period/2;
      clk <= '1';
      wait for clk_period/2;
    end process;
    
    --test bench routine:
    --go up to first floor
    --clear input
    --go up to 4
    --clear input
    --go down to 3
    --clear button input
    --continues 3 down to 1
    --em stop during 3 down to 1
    --contines on 3 down to 1
    --clears input
    --sets open/close to 1 and holds door open untill 8200
    --goes 1st to 3rd and 4th (multiple requests in up)
    --clears buttons
    --goes 4th down to 2nd and 1st(multiple requests in down)
    --sets buttons to 0
    
    buttons <= "0000",
              "0010" after 100 ps,--proves it increments
              "0000" after 200 ps,--reforces 0 on the button input
              "1000" after 1900 ps,--Takes elevator from 2nd floor to 4th floor
              "0000" after 2000 ps,--reforces 0 on the button input to prevent loop
              "0100" after 2100 ps,--4th down to 3rd
              "0000" after 2200 ps,--reforces 0 on the button input to prevent loop
              "0001" after 5000 ps,--3rd down to 1st floor
              "0000" after 5100 ps,--reforces 0 on the button input to prevent loop
              "1100" after 8300 ps,--1st floor to 3rd and 4th (mulitple requests in  up queue)
              "0000" after 8400 ps,
              "0011" after 9000 ps,--4th floor to 2nd and 1st (mulitple requests in  down queue)
              "0000" after 9100 ps;
              
    em_s <= '0',
            '1' after 6000 ps,
            '0' after 6500 ps;
            
    open_close <= '0',
                  '1' after 7800 ps,
                  '0' after 8200 ps;
    
      
      
    
  END behavior;