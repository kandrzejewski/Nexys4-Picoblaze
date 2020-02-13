--
-- uart_led_driver for KCPSM6
-- 2017
-- 5MHz, 2400 baudrate
-- 
-- format danych: adres wartosc dane wartosc (znaki ASCII)
--           np.: A0D4 - wyswietla liczbe 4 na pozycji 0 (lewa)
--                znak "7F" (DEL) resetuje rejestry i pamięć danych
-- 
------------------------------------------------------------------------------------
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--
use work.pkg_pB6.all;
------------------------------------------------------------------------------------
--
entity led8drv_uart is
    generic(F_Hz: positive := 5e6;
            Led_Baudrate: positive := 2400);
    Port (uart_tx: out std_logic;
          uart_rx: in std_logic;
          sseg : out  STD_LOGIC_VECTOR (6 downto 0);   -- active Low
          an : out  STD_LOGIC_VECTOR (7 downto 0);    -- active Low
          clk_in : in std_logic; 
          reset : in std_logic); -- active high
    end led8drv_uart;
--
------------------------------------------------------------------------------------
--
-- Start of test achitecture
--
architecture Behavioral of led8drv_uart is
--
constant BaudCntrMax: natural := (F_Hz/(16*Led_Baudrate))-1;
subtype byte is std_logic_vector(7 downto 0);
constant DEL: byte := x"7f";
constant AC:  byte := std_logic_vector(to_unsigned(character'pos('C'),8));
constant DC:  byte := std_logic_vector(to_unsigned(character'pos('F'),8));
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
signal clk, data_present, read_strobe : std_logic;
signal regA_en, regD_en, store_en, rst_int: std_logic;
signal data_in, regA, regD : std_logic_vector(7 downto 0):=x"00";
signal cel, far : std_logic := '0';
signal temperature: integer := 0;
--
type state is (C_WAIT, AV_WAIT, DV_WAIT, RD_C, RD_AV, RD_DV, STORE, SRESET);
signal cstate, nstate: state;
type mem is array (7 downto 0) of std_logic_vector(7 downto 0);
signal digit_store: mem:=(others=>(others=>'0'));

--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
begin
  --
  clk <= clk_in;
  uart_rx_reset <= reset;
  uart_tx_reset <= reset;
  --
  fsm: process (cstate, data_in, data_present) begin
    read_strobe<='0'; regA_en<='0'; regD_en<='0'; store_en<='0'; rst_int<='0';
    case cstate is
      when C_WAIT =>
        if data_present='1' then
          nstate<=RD_C;
          read_strobe<='1';
        else 
          nstate<=C_WAIT;
        end if;
      when RD_C =>
        if data_in= AC then
          nstate<=AV_WAIT;
		  cel <= '1';
		  far <= '0';
        elsif data_in= DC then
          nstate<=DV_WAIT;
		  far <= '1';
		  cel <= '0';
        elsif data_in= DEL then
          nstate<=SRESET;
        else 
          nstate<=C_WAIT;
        end if; 
      when AV_WAIT =>
        if data_present='1' then
          nstate<=RD_AV;
          read_strobe<='1';
        else 
          nstate<=AV_WAIT;
        end if;
      when DV_WAIT =>
        if data_present='1' then
          nstate<=RD_DV;
          read_strobe<='1';
        else 
          nstate<=DV_WAIT;
        end if;
      when RD_AV =>
        regA_en<='1'; nstate<=C_WAIT;        
      when RD_DV =>
        regD_en<='1'; nstate<=STORE;
      when STORE =>
        store_en<='1'; nstate<=C_WAIT;
      when SRESET => 
        nstate<=C_WAIT;
        rst_int<='1';
      end case;
  end process;

  reg_proc: process(clk) 
    variable address: natural range 0 to 7 := 0;
	variable temp, temp2: integer := 0;
    begin
    if rising_edge(clk) then
      cstate<=nstate;

      if rst_int='1' then regA<=x"00"; elsif regA_en='1' then regA<=data_in; end if;
      if rst_int='1' then regD<=x"00"; elsif regD_en='1' then regD<=data_in; end if;
      if rst_int='1' then digit_store<=(others=>(others=>'0')); elsif store_en='1' then
		if cel = '1' then
			temperature <= to_integer(unsigned(regA));
			digit_store(3)<=std_logic_vector(to_unsigned(temperature/10,8));
			digit_store(2)<=std_logic_vector(to_unsigned(temperature-to_integer(unsigned(digit_store(3))),8));
			--digit_store(3) <= std_logic_vector(to_unsigned(52,8));
			--digit_store(2) <= std_logic_vector(to_unsigned(53,8));
			digit_store(0)<=std_logic_vector(to_unsigned(character'pos('c'),8));
			--cel <= '0';
		elsif far = '1' then
			temp := to_integer(unsigned(regD)) mod 10;
			temperature <= temp + 48;
			digit_store(3)<=std_logic_vector(to_unsigned(temperature, 8));
			temp2 := temp * 10;
			temp := to_integer(unsigned(regD)) - temp2;
			temperature <= temp + 48; 
			digit_store(2)<=std_logic_vector(to_unsigned(temperature, 8));
			--digit_store(3) <= std_logic_vector(to_unsigned(56,8));
			--digit_store(2) <= std_logic_vector(to_unsigned(57,8));
			digit_store(0)<=std_logic_vector(to_unsigned(character'pos('f'),8));
			--Cfar <= '0';
		end if;
		--address:=to_integer(unsigned(regA));
        --digit_store(address)<=regD; 
      end if;

      if read_strobe='1' then 
        data_in<=uart_rx_data_out; 
        write_to_uart_tx <='1';
      else 
        write_to_uart_tx <= '0';
      end if;

    end if;
  end process;

  -- Generate 'buffer_read' pulse 
  read_from_uart_rx <= read_strobe;
  data_present <= uart_rx_data_present;
  -- bypass
  uart_tx_data_in <= data_in;

  -- time generator
  baud_rate: process(clk)
    begin
      if rising_edge(clk) then
        if baud_count = BaudCntrMax then
          baud_count <= 0;
          en_16_x_baud <= '1';
         else
          baud_count <= baud_count + 1;
          en_16_x_baud <= '0';
        end if;
      end if;
    end process baud_rate;
  --
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
  --
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
  --
  led_driver: entity work.led8a_driver 
    generic map(F_Hz, true)
    PORT MAP(
    a => digit_store(0),
    b => digit_store(1),
    c => digit_store(2),
    d => digit_store(3),
    e => digit_store(4),
    f => digit_store(5),
    g => digit_store(6),
    h => digit_store(7),
    clk_in => clk,
    sseg => sseg,
    an => an );

end Behavioral;

------------------------------------------------------------------------------------