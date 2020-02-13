----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:30:00 06/18/2019 
-- Design Name: 
-- Module Name:    TEMP_TOP - Behavioral 
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
use IEEE.numeric_std.ALL; 

use work.pkg_pB6.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity temp_sensor is
	 Generic(F_Hz: positive := 5e6;
		Baudrate: positive := 9600);
    Port ( clk_i : in STD_LOGIC;
				rstn_i : in  std_logic;
				uart_rx : in std_logic;
				uart_tx : out std_logic;
				tmp_scl : inout  STD_LOGIC;
				tmp_sda : inout  STD_LOGIC;
				T : out std_logic_vector(12 downto 0)
			 ); 
           --tmp_int : in  STD_LOGIC;
           --tmp_ct : in  STD_LOGIC)
end temp_sensor;

architecture Behavioral of temp_sensor is

constant BaudCntrMax: natural := (F_Hz/(16*Baudrate))-1;
subtype byte is std_logic_vector(7 downto 0);

	component TempSensorCtl is
		Generic (CLOCKFREQ : natural := 100); -- input CLK frequency in MHz
		Port (
			TMP_SCL : inout STD_LOGIC;
			TMP_SDA : inout STD_LOGIC;
			-- The Interrupt and Critical Temperature Signals
			-- from the ADT7420 Temperature Sensor are not used in this design
			--TMP_INT : in STD_LOGIC;
			--TMP_CT : in STD_LOGIC;		
			TEMP_O : out STD_LOGIC_VECTOR(12 downto 0); --12-bit two's complement temperature with sign bit
			RDY_O : out STD_LOGIC;	--'1' when there is a valid temperature reading on TEMP_O
			ERR_O : out STD_LOGIC; --'1' if communication error
			CLK_I : in STD_LOGIC;
			SRST_I : in STD_LOGIC
		);
	end component;
	
	-- Inverted input reset signal
	signal rst        : std_logic;
	--
	-- ADT7420 Temperature Sensor raw Data Signal
	--
	signal tempValue : std_logic_vector(12 downto 0);
	signal tempRdy, tempErr : std_logic;
	signal tempToSend : integer;
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
	--
	signal tx_data : std_logic_vector(7 downto 0);
	
	type state is (S_WAIT, S_ANSWER);
	signal cstate,nstate: state := S_WAIT;
	
begin

	-- The Reset Button on the Nexys4 board is active-low,
   -- however many components need an active-high reset
   rst <= not rstn_i;
	t(7 downto 0) <= tx_data;

----------------------------------------------------------------------------------
-- Temperature Sensor Controller
----------------------------------------------------------------------------------
		Inst_TempSensorCtl: TempSensorCtl
		GENERIC MAP (CLOCKFREQ => 100)
		PORT MAP(
			TMP_SCL => tmp_scl,
			TMP_SDA => tmp_sda,
			--TMP_INT => tmp_int,
			--TMP_CT => tmp_ct,		
			TEMP_O => tempValue,
			RDY_O => tempRdy,
			ERR_O => tempErr,
			CLK_I => clk_i,
			SRST_I => rstn_i
		);
----------------------------------------------------------------------------------
-- UART
----------------------------------------------------------------------------------		
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
		  clk => clk_i);

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
		  clk => clk_i);

  uart_rx_reset <= rstn_i;
  uart_tx_reset <= rstn_i;
  
  tempToSend <= to_integer(unsigned(tempValue(tempValue'high-1 downto 0)));
  tx_data <= std_logic_vector(to_unsigned(tempToSend/16, 8));

	fsm : process (cstate,uart_rx_data_present) is
	begin
		 read_from_uart_rx<='0'; write_to_uart_tx <= '1';
	  case cstate is
		when S_WAIT =>
		  if uart_rx_data_present='1' then
			nstate<=S_ANSWER;
			read_from_uart_rx <= '1';
		  else 
			nstate<=S_WAIT;
		  end if;
		  when S_ANSWER =>
			if uart_rx_data_out = "00000001" then
				write_to_uart_tx <= '1';
				nstate <= S_WAIT;
			else
				nstate <= S_WAIT;
		  end if;
		end case;
	end process;
	
	uart_tx_data_in <= tx_data;

	-- time generator
	baud_rate: process(clk_i)
	  begin
		 if rising_edge(clk_i) then
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
end Behavioral;


