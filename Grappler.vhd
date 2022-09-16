library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Grappler is port
	(
			clk               	:in std_logic;
			reset						:in std_logic;
			grappler					:in std_logic;
			grappler_en				:in std_logic;
			grappler_on				:out std_logic		
		);
	end Entity;

ARCHITECTURE Grappler_logic OF Grappler IS

TYPE STATE_NAMES IS (closed, waiting_open, opened, waiting_close);
 
 SIGNAL current_state, next_state	:  STATE_NAMES;     	-- signals of type STATE_NAMES

BEGIN
 
 
 --------------------------------------------------------------------------------
 --State Machine: Moore Machine
 --------------------------------------------------------------------------------

 -- REGISTER_LOGIC PROCESS:
 
Register_Section: PROCESS (clk, reset, next_state)  -- this process synchronizes the activity to a clock
BEGIN
	IF (reset = '1') THEN
		current_state <= closed;
	ELSIF(rising_edge(clk)) THEN
		current_state <= next_State;
	END IF;
END PROCESS;	


-- TRANSITION LOGIC PROCESS

Transition_Section: PROCESS (grappler, grappler_en, current_state) 

BEGIN
     CASE current_state IS
	 
			WHEN closed =>
				IF((grappler='1') AND (grappler_en = '1')) THEN
					next_state <= waiting_open;
				ELSE
					next_state <= closed;
				END IF;

			WHEN waiting_open =>
				IF (grappler='0') THEN
					next_state <= opened;
				ELSE
					next_state <= waiting_open;
				END IF;

         WHEN opened =>		
				IF((grappler='1') AND (grappler_en = '1')) THEN
					next_state <= waiting_close;
				ELSE
					next_state <= opened;
				END IF;
			
			WHEN waiting_close =>
				IF (grappler = '0') THEN
					next_state <= closed;
				ELSE 
					next_state <= waiting_close;
				END IF; 		

	  END CASE;
 END PROCESS;		
		
		
-- DECODER SECTION PROCESS

Decoder_Section: PROCESS (current_state) 

BEGIN

		CASE current_state IS
			WHEN closed =>
				grappler_on <= '0';
			WHEN waiting_open =>
				grappler_on <= '0';
			WHEN opened =>
				grappler_on <= '1';
			WHEN waiting_close =>
				grappler_on <= '1';
	  END CASE;
 END PROCESS;

 END ARCHITECTURE Grappler_logic; 