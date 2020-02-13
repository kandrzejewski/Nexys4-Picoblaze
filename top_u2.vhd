------------------------------------------------------------
-- Marek Kropidlowski, CCE 2018
--
-- test pB6 2xUART
--
------------------------------------------------------------
-- 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--
------------------------------------------------------------------------------------
--
--
entity top_u2 is
    Port (  led : out std_logic_vector(12 downto 0);
				uart_txd_in : in std_logic;
            uart_rxd_out : out std_logic;
            btnc : in std_logic;
				btnu : in std_logic;
				btnr : in std_logic;
				btnl : in std_logic;
				reset  : in std_logic;
            clk : in std_logic;
				tmp_scl : inout  STD_LOGIC;
				tmp_sda : inout  STD_LOGIC;
            sseg : out std_logic_vector(6 downto 0);
            an : out std_logic_vector(7 downto 0)
            );
    end top_u2;
--
------------------------------------------------------------------------------------
--
architecture struct of top_u2 is

signal clk_fx, clk50, clk25, clk125, clk625, clk5: std_logic;
signal locked, uart_to_led, uart_from_led : std_logic;
signal uart_to_temp, uart_from_temp : std_logic;
signal uart_to_buttons, uart_from_buttons : std_logic;
signal nreset : std_logic;

signal t : std_logic_vector(12 downto 0);

begin

led <= t;


nreset <=  not reset;

procesor: entity work.kcpsm6_uart_2
 port map (
    reset_b => locked,
    clk => clk50,
	 uart_tx4 => uart_to_buttons,
    uart_rx4 => uart_from_buttons,
	 uart_tx3 => uart_to_temp,
    uart_rx3 => uart_from_temp,
    uart_tx2 => uart_to_led,
    uart_rx2 => uart_from_led,
    uart_tx1 => uart_rxd_out,
    uart_rx1 => uart_txd_in);

dcm_inst : entity work.dcm_gen
  port map
   (
    CLK_IN => CLK,
    CLK_OUT => clk_fx,
    clk_out25 => clk25,
    clk_out50 => clk50,
    clk_out12_5 => clk125,
    clk_out6_25 => clk625,
    clk_out5 => clk5,
    RESET  => nreset,
    LOCKED => LOCKED);

inst_led_serial: entity work.led8drv_uart 
   generic map(5e6,2400)
   PORT MAP(
		clk_in => clk5,
		sseg => sseg,
		an => an,
      reset => nreset,
		uart_tx => uart_from_led,
		uart_rx => uart_to_led);

inst_temp_sensor: entity work.temp_sensor
	 generic map(5e6, 9600)
    Port map ( clk_i => clk5,
				rstn_i => nreset,
				uart_rx => uart_to_temp,
				uart_tx => uart_from_temp,
				tmp_scl => tmp_scl,
				tmp_sda => tmp_sda,
				T => t
			 ); 
           --tmp_int : in  STD_LOGIC;
           --tmp_ct : in  STD_LOGIC)
			  
inst_buttons: entity work.buttons
   generic map(5e6,19200)
   PORT MAP(
		clk => clk5,
		uart_rx => uart_to_buttons,
		uart_tx => uart_from_buttons,
		change => btnu,
		reset => btnc,
		left => btnl,
		clear => btnr
);
end struct;