----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    05:04:29 06/22/2019 
-- Design Name: 
-- Module Name:    buttons - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.pkg_pB6.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity buttons is
	generic(F_Hz: positive := 5e6;
			Baudrate: positive := 19200);
	port(
		clk : in std_logic;
		uart_rx : in std_logic;
		uart_tx : out std_logic;
		change : in std_logic;
		reset : in std_logic;
		left : in std_logic;
		clear : in std_logic
	);
end buttons;

architecture behav of buttons is
constant BaudCntrMax: natural := (F_Hz/(16*Baudrate))-1;
subtype byte is std_logic_vector(7 downto 0);
--
-- Signals used to connect UART_TX6
--
signal uart_tx_data_in : std_logic_vector(7 downto 0);
signal write_to_uart_tx : std_logic;
signal uart_tx_data_present : std_logic;
signal uart_tx_half_full : std_logic;
signal uart_tx_full : std_logic;
signal uart_tx_reset : std_logic;
--
-- Signals used to connect UART_RX6
--
signal uart_rx_data_out : std_logic_vector(7 downto 0);
signal read_from_uart_rx : std_logic;
signal uart_rx_data_present : std_logic;
signal uart_rx_half_full : std_logic;
signal uart_rx_full : std_logic;
signal uart_rx_reset : std_logic;
--
signal en_16_x_baud : std_logic := '0';
signal baud_count : integer range 0 to BaudCntrMax := 0; 
--
signal read_strobe : std_logic;

signal btn_out : std_logic_vector(7 downto 0);

type state is (NONE, SEND);
signal cstate,nstate: state := NONE;
begin

		tx: uart_tx6 
		port map ( 
		  data_in => uart_tx_data_in,
		  en_16_x_baud => en_16_x_baud,
		  serial_out => uart_tx,
		  buffer_write => write_to_uart_tx,
		  buffer_data_present => uart_tx_data_present,
		  buffer_half_full => uart_tx_half_full,
		  buffer_full => uart_tx_full,
		  buffer_reset => uart_tx_reset,              
		  clk => clk);

		rx: uart_rx6 
		port map (
		  serial_in => uart_rx,
		  en_16_x_baud => en_16_x_baud,
		  data_out => uart_rx_data_out,
		  buffer_read => read_from_uart_rx,
		  buffer_data_present => uart_rx_data_present,
		  buffer_half_full => uart_rx_half_full,
		  buffer_full => uart_rx_full,
		  buffer_reset => uart_rx_reset,              
		  clk => clk);

uart_rx_reset <= reset;
uart_tx_reset <= reset;

btn_out(0) <= change;
btn_out(1) <= reset;
btn_out(2) <= clear;
btn_out(3) <= left;

fsm : process (cstate,uart_rx_data_present) is
begin
	 read_from_uart_rx<='0'; write_to_uart_tx <= '1';
  case cstate is
    when NONE =>
      if uart_rx_data_present='1' then
        nstate<=SEND;
        read_from_uart_rx <= '1';
      else 
        nstate<=NONE;
      end if;
      when SEND =>
		if uart_rx_data_out = "00000001" then
			write_to_uart_tx <= '1';
			nstate <= NONE;
		else
			nstate <= NONE;
      end if;
	end case;
end process;

uart_tx_data_in <= btn_out;


-- time generator
baud_rate: process(clk)
  begin
    if rising_edge(clk) then
	 cstate <= nstate;
      if baud_count = BaudCntrMax then
        baud_count <= 0;
        en_16_x_baud <= '1';
       else
        baud_count <= baud_count + 1;
        en_16_x_baud <= '0';
      end if;
    end if;
  end process baud_rate;
end behav;

