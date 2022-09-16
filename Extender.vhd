library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Extender is port
	(
			clk               	:in std_logic;
			reset						:in std_logic;
			ext_pos					:in std_logic_vector (3 downto 0);
			extender					:in std_logic;
			extender_en				:in std_logic;
			extender_out			:out std_logic;
			grappler_en				:out std_logic;
			clk_en, left_right	:out std_logic		
		);
	end Entity;
	
ARCHITECTURE Extender_logic OF Extender IS

--Signal sreg 				: std_logic_vector(7 downto 0);




 
 --TYPE STATE_NAMES IS (retracted, extending1, extending2, extending3, retracting1, retracting2, retracting3 extended);   -- list all the STATE_NAMES values
TYPE STATE_NAMES IS (retracted, waiting_extend, extending, waiting_retract, retracting, extended);
 
 SIGNAL current_state, next_state	:  STATE_NAMES;     	-- signals of type STATE_NAMES

BEGIN
 
 
 --------------------------------------------------------------------------------
 --State Machine: Moore Machine
 --------------------------------------------------------------------------------

 -- REGISTER_LOGIC PROCESS:
 
Register_Section: PROCESS (clk, reset, next_state)  -- this process synchronizes the activity to a clock
BEGIN
	IF (reset = '1') THEN
		current_state <= retracted;
	ELSIF(rising_edge(clk)) THEN
		current_state <= next_State;
	END IF;
END PROCESS;	

-- TRANSITION LOGIC PROCESS

Transition_Section: PROCESS (extender, extender_en, ext_pos, current_state) 

BEGIN
     CASE current_state IS
	 
			WHEN retracted =>
				IF((extender='1') AND (extender_en = '1')) THEN
					next_state <= waiting_extend;
				ELSE
					next_state <= retracted;
				END IF;

			WHEN waiting_extend =>
				IF (extender='0') THEN
					next_state <= extending;
				ELSE
					next_state <= waiting_extend;
				END IF;

         WHEN extending =>	
				IF (ext_pos ="1111") THEN
					next_state <= extended;
				ELSE
					next_state<= extending;
				END IF;	

         WHEN extended =>		
				IF((extender='1') AND (extender_en = '1')) THEN
					next_state <= waiting_retract;
				ELSE
					next_state <= extended;
				END IF;
			
			WHEN waiting_retract =>
				IF (extender = '0') THEN
					next_state <= retracting;
				ELSE 
					next_state <= waiting_retract;
				END IF;
			
         WHEN retracting =>	
				IF (ext_pos ="0000") THEN
					next_state <= retracted;
				ELSE
					next_state<= retracting;
				END IF;

				WHEN OTHERS =>
					next_state <= retracted;           --????
 		

	  END CASE;
 END PROCESS;		

-- DECODER SECTION PROCESS

Decoder_Section: PROCESS (current_state) 

BEGIN

		CASE current_state IS

         WHEN retracted =>		
				extender_out <= '0';
				grappler_en <= '0';
				clk_en <= '0';
				left_right <= '1';
			
			WHEN waiting_extend =>
				extender_out <= '0';
				grappler_en <= '0';
				clk_en <= '0';
				left_right <= '1';
			
			WHEN waiting_retract =>
				extender_out <= '1';
				grappler_en <= '0';           --can it grapple when you have extender button pushed down
				clk_en <= '0';
				left_right <= '1';
				
         WHEN extending =>
				extender_out <= '1';
				grappler_en <= '0';
				left_right <= '1';
				clk_en <= '1';
			
			WHEN retracting =>
				extender_out <= '1';
				grappler_en <= '0';
				left_right <= '0';
				clk_en <= '1';
				
         WHEN extended =>	
				extender_out <= '1';
				grappler_en <= '1';
				clk_en <= '0';
				left_right <= '0'; -- doesnt matter

	  END CASE;
 END PROCESS;

 END ARCHITECTURE Extender_logic; 