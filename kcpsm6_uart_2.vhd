--
-- uart_clock for KCPSM6
-- 2017
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
entity kcpsm6_uart_2 is
    Port (uart_tx1: out std_logic;
          uart_rx1: in std_logic;
          uart_tx2: out std_logic;
          uart_rx2: in std_logic;
			 uart_tx3: out std_logic;
          uart_rx3: in std_logic;
			 uart_tx4: out std_logic;
          uart_rx4: in std_logic;
             clk : in std_logic;
         reset_b : in std_logic); -- active low
    end kcpsm6_uart_2;
--
------------------------------------------------------------------------------------
--
-- Start of test achitecture
--
architecture Behavioral of kcpsm6_uart_2 is
--
constant BaudCntrMax1: natural := (FREQ/(16*BAUD_RATE1))-1;
constant BaudCntrMax2: natural := (FREQ/(16*BAUD_RATE2))-1;
constant BaudCntrMax3: natural := (FREQ/(16*BAUD_RATE3))-1;
constant BaudCntrMax4: natural := (FREQ/(16*BAUD_RATE4))-1;

--
signal              address : std_logic_vector(11 downto 0);
signal          instruction : std_logic_vector(17 downto 0);
signal          bram_enable : std_logic;
signal              in_port : std_logic_vector(7 downto 0);
signal             out_port : std_logic_vector(7 downto 0);
signal              port_id : std_logic_vector(7 downto 0);
signal         write_strobe : std_logic;
signal       k_write_strobe : std_logic;
signal          read_strobe : std_logic;
signal            interrupt : std_logic := '0';
signal        interrupt_ack : std_logic;
signal         kcpsm6_sleep : std_logic;
signal         kcpsm6_reset : std_logic;
signal                  rdl : std_logic;
--
-- Signals used to connect UART_TX6
--
signal      uart_tx_data_in1 : std_logic_vector(7 downto 0);
signal     write_to_uart_tx1 : std_logic;
signal uart_tx_data_present1 : std_logic;
signal    uart_tx_half_full1 : std_logic;
signal         uart_tx_full1 : std_logic;
signal         uart_tx_reset : std_logic;
signal      uart_tx_data_in2 : std_logic_vector(7 downto 0);
signal     write_to_uart_tx2 : std_logic;
signal uart_tx_data_present2 : std_logic;
signal    uart_tx_half_full2 : std_logic;
signal         uart_tx_full2 : std_logic;
signal      uart_tx_data_in3 : std_logic_vector(7 downto 0);
signal     write_to_uart_tx3 : std_logic;
signal uart_tx_data_present3 : std_logic;
signal    uart_tx_half_full3 : std_logic;
signal         uart_tx_full3 : std_logic;
signal      uart_tx_data_in4 : std_logic_vector(7 downto 0);
signal     write_to_uart_tx4 : std_logic;
signal uart_tx_data_present4 : std_logic;
signal    uart_tx_half_full4 : std_logic;
signal         uart_tx_full4 : std_logic;
--
-- Signals used to connect UART_RX6
--
signal     uart_rx_data_out4 : std_logic_vector(7 downto 0);
signal    read_from_uart_rx4 : std_logic;
signal uart_rx_data_present4 : std_logic;
signal    uart_rx_half_full4 : std_logic;
signal         uart_rx_full4 : std_logic;
signal     uart_rx_data_out3 : std_logic_vector(7 downto 0);
signal    read_from_uart_rx3 : std_logic;
signal uart_rx_data_present3 : std_logic;
signal    uart_rx_half_full3 : std_logic;
signal         uart_rx_full3 : std_logic;
signal     uart_rx_data_out2 : std_logic_vector(7 downto 0);
signal    read_from_uart_rx2 : std_logic;
signal uart_rx_data_present2 : std_logic;
signal    uart_rx_half_full2 : std_logic;
signal         uart_rx_full2 : std_logic;
signal        uart_rx_reset : std_logic;
signal     uart_rx_data_out1 : std_logic_vector(7 downto 0);
signal    read_from_uart_rx1 : std_logic;
signal uart_rx_data_present1 : std_logic;
signal    uart_rx_half_full1 : std_logic;
signal         uart_rx_full1 : std_logic;

--
-- Signals used to define baud rate
--
signal           baud_count1 : integer range 0 to BaudCntrMax1 := 0; 
signal         en_16_x_baud1 : std_logic := '0';
signal           baud_count2 : integer range 0 to BaudCntrMax2 := 0; 
signal         en_16_x_baud2 : std_logic := '0';
signal           baud_count3 : integer range 0 to BaudCntrMax3 := 0; 
signal         en_16_x_baud3 : std_logic := '0';
signal           baud_count4 : integer range 0 to BaudCntrMax4 := 0; 
signal         en_16_x_baud4 : std_logic := '0';

--
--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- Start of circuit description
--
begin

  processor: kcpsm6
    generic map ( hwbuild => HW_VERSION, 
                  interrupt_vector => INTR_VEC,   
                  scratch_pad_memory_size => SP_MEMORY)
    port map(      address => address,
               instruction => instruction,
               bram_enable => bram_enable,
                   port_id => port_id,
              write_strobe => write_strobe,
            k_write_strobe => k_write_strobe,
                  out_port => out_port,
               read_strobe => read_strobe,
                   in_port => in_port,
                 interrupt => interrupt,
             interrupt_ack => interrupt_ack,
                     sleep => kcpsm6_sleep,
                     reset => kcpsm6_reset,
                       clk => clk);
 
  -- Reset by press button (active Low) or JTAG Loader enabled Program Memory 
  --reset_b <= not reset;
  kcpsm6_reset <= rdl or not(reset_b);

  -- Tying to other signals used to minimise warning messages.
  kcpsm6_sleep <= write_strobe and k_write_strobe;  -- Always '0'

  program_rom: program_ROM7_debug
    generic map( C_FAMILY => "7S", 
                 C_RAM_SIZE_KWORDS => RAM_SIZE_KWORDS,
                 C_JTAG_LOADER_ENABLE => JTAG_LOADER)
    port map(      address => address,      
               instruction => instruction,
                    enable => bram_enable,
                       rdl => rdl,
                       clk => clk);

  --
  -----------------------------------------------------------------------------------------
  -- General Purpose Input Ports. 
  -----------------------------------------------------------------------------------------
  --
  -- Two input ports are used with the UART macros. The first is used to monitor the flags
  -- on both the UART transmitter and receiver. The second is used to read the data from 
  -- the UART receiver. Note that the read also requires a 'buffer_read' pulse to be 
  -- generated.

  input_ports: process(clk)
  begin
    if clk'event and clk = '1' then
      case port_id(3 downto 0) is

        -- Read UART1 status at port address 00 hex
        when x"0" =>  in_port(0) <= uart_tx_data_present1;
                      in_port(1) <= uart_tx_half_full1;
                      in_port(2) <= uart_tx_full1; 
                      in_port(3) <= uart_rx_data_present1;
                      in_port(4) <= uart_rx_half_full1;
                      in_port(5) <= uart_rx_full1;
        -- Read UART1_RX6 data at port address 01 hex
        -- (see 'buffer_read' pulse generation below) 
        when x"1" =>       in_port <= uart_rx_data_out1;
        -- Read UART2 status at port address 02 hex
        when x"2" =>  in_port(0) <= uart_tx_data_present2;
                      in_port(1) <= uart_tx_half_full2;
                      in_port(2) <= uart_tx_full2; 
                      in_port(3) <= uart_rx_data_present2;
                      in_port(4) <= uart_rx_half_full2;
                      in_port(5) <= uart_rx_full2;
        -- Read UART2_RX6 data at port address 02 hex
        -- (see 'buffer_read' pulse generation below) 
        when x"3" =>       in_port <= uart_rx_data_out2;
        -- Don't Care for unused case(s) ensures minimum logic implementation
		   -- Read UART3 status at port address 04 hex
		  when x"4" =>  in_port(0) <= uart_tx_data_present3;
                      in_port(1) <= uart_tx_half_full3;
                      in_port(2) <= uart_tx_full3; 
                      in_port(3) <= uart_rx_data_present3;
                      in_port(4) <= uart_rx_half_full3;
                      in_port(5) <= uart_rx_full3;
        -- Read UART3_RX6 data at port address 04 hex
        -- (see 'buffer_read' pulse generation below) 
        when x"5" =>       in_port <= uart_rx_data_out3;
		  -- Read UART4 status at port address 06 hex
		  when x"6" =>  in_port(0) <= uart_tx_data_present4;
                      in_port(1) <= uart_tx_half_full4;
                      in_port(2) <= uart_tx_full4; 
                      in_port(3) <= uart_rx_data_present4;
                      in_port(4) <= uart_rx_half_full4;
                      in_port(5) <= uart_rx_full4;
        -- Read UART4_RX6 data at port address 06 hex
        -- (see 'buffer_read' pulse generation below) 
        when x"7" =>       in_port <= uart_rx_data_out4;
        when others =>    in_port <= "--------";  
      end case;

      -- Generate 'buffer_read' pulse following read from port address 01
      if (read_strobe = '1') and (port_id(3 downto 0) = x"1") then
        read_from_uart_rx1 <= '1';
       else
        read_from_uart_rx1 <= '0';
      end if;
 
      -- Generate 'buffer_read' pulse following read from port address 03
      if (read_strobe = '1') and (port_id(3 downto 0) = x"3") then
        read_from_uart_rx2 <= '1';
       else
        read_from_uart_rx2 <= '0';
      end if;
		
		-- Generate 'buffer_read' pulse following read from port address 05
      if (read_strobe = '1') and (port_id(7 downto 0) = x"05") then
        read_from_uart_rx3 <= '1';
       else
        read_from_uart_rx3 <= '0';
      end if;
		-- Generate 'buffer_read' pulse following read from port address 07
      if (read_strobe = '1') and (port_id(7 downto 0) = x"07") then
        read_from_uart_rx4 <= '1';
       else
        read_from_uart_rx4 <= '0';
      end if;
    end if;
  end process input_ports;
  --
  -----------------------------------------------------------------------------------------
  -- General Purpose Output Ports 
  -----------------------------------------------------------------------------------------
  --   reset low
  --   A port used to write data directly to the FIFO buffer within 'uart_tx6' macro. 

  output_ports: process(clk)
  begin
    if clk'event and clk = '1' then
      -- 'write_strobe' is used to qualify all writes to general output ports.
      if write_strobe = '1' then

      end if;      
    end if; 
  end process output_ports;
  --
  -- Write directly to the FIFO buffer within 'uart_tx6' macro at port address 01 hex.
  -- Note the direct connection of 'out_port' to the UART transmitter macro and the 
  -- way that a single clock cycle write pulse is generated to capture the data.
  -- 
  uart_tx_data_in1 <= out_port;
  write_to_uart_tx1  <= '1' when (write_strobe = '1') and (port_id(3 downto 0) = x"1")
                           else '0';                     
  uart_tx_data_in2 <= out_port;
  write_to_uart_tx2  <= '1' when (write_strobe = '1') and (port_id(3 downto 0) = x"3")
                           else '0';
  uart_tx_data_in3 <= out_port;
  write_to_uart_tx3  <= '1' when (write_strobe = '1') and (port_id(7 downto 0) = x"05")
                           else '0'; 
  uart_tx_data_in4 <= out_port;
  write_to_uart_tx4  <= '1' when (write_strobe = '1') and (port_id(7 downto 0) = x"07")
                           else '0';  									

  --
  -- Write to buffer in UART Transmitter at port address 01 hex
  --
  tx1: uart_tx6 
  port map (              data_in => uart_tx_data_in1,
                     en_16_x_baud => en_16_x_baud1,
                       serial_out => uart_tx1,
                     buffer_write => write_to_uart_tx1,
              buffer_data_present => uart_tx_data_present1,
                 buffer_half_full => uart_tx_half_full1,
                      buffer_full => uart_tx_full1,
                     buffer_reset => uart_tx_reset,              
                              clk => clk);

  --
  -- Read from buffer in UART Receiver at port address 01 hex.
  --
  rx1: uart_rx6 
  port map (            serial_in => uart_rx1,
                     en_16_x_baud => en_16_x_baud1,
                         data_out => uart_rx_data_out1,
                      buffer_read => read_from_uart_rx1,
              buffer_data_present => uart_rx_data_present1,
                 buffer_half_full => uart_rx_half_full1,
                      buffer_full => uart_rx_full1,
                     buffer_reset => uart_rx_reset,              
                              clk => clk);

  --
  -- Write to buffer in UART Transmitter at port address 02 hex
  --
  tx2: uart_tx6 
  port map (              data_in => uart_tx_data_in2,
                     en_16_x_baud => en_16_x_baud2,
                       serial_out => uart_tx2,
                     buffer_write => write_to_uart_tx2,
              buffer_data_present => uart_tx_data_present2,
                 buffer_half_full => uart_tx_half_full2,
                      buffer_full => uart_tx_full2,
                     buffer_reset => uart_tx_reset,              
                              clk => clk);

  --
  -- Read from buffer in UART Receiver at port address 02 hex.
  --
  rx2: uart_rx6 
  port map (            serial_in => uart_rx2,
                     en_16_x_baud => en_16_x_baud2,
                         data_out => uart_rx_data_out2,
                      buffer_read => read_from_uart_rx2,
              buffer_data_present => uart_rx_data_present2,
                 buffer_half_full => uart_rx_half_full2,
                      buffer_full => uart_rx_full2,
                     buffer_reset => uart_rx_reset,              
                              clk => clk);
										
  --
  -- Write to buffer in UART Transmitter at port address 04 hex
  --
  tx3: uart_tx6 
  port map (              data_in => uart_tx_data_in3,
                     en_16_x_baud => en_16_x_baud3,
                       serial_out => uart_tx3,
                     buffer_write => write_to_uart_tx3,
              buffer_data_present => uart_tx_data_present3,
                 buffer_half_full => uart_tx_half_full3,
                      buffer_full => uart_tx_full3,
                     buffer_reset => uart_tx_reset,              
                              clk => clk);

  --
  -- Read from buffer in UART Receiver at port address 04 hex.
  --
  rx3: uart_rx6 
  port map (            serial_in => uart_rx3,
                     en_16_x_baud => en_16_x_baud3,
                         data_out => uart_rx_data_out3,
                      buffer_read => read_from_uart_rx3,
              buffer_data_present => uart_rx_data_present3,
                 buffer_half_full => uart_rx_half_full3,
                      buffer_full => uart_rx_full3,
                     buffer_reset => uart_rx_reset,              
                              clk => clk);		
  --
  -- Write to buffer in UART Transmitter at port address 06 hex
  --
  tx4: uart_tx6 
  port map (              data_in => uart_tx_data_in4,
                     en_16_x_baud => en_16_x_baud4,
                       serial_out => uart_tx4,
                     buffer_write => write_to_uart_tx4,
              buffer_data_present => uart_tx_data_present4,
                 buffer_half_full => uart_tx_half_full4,
                      buffer_full => uart_tx_full4,
                     buffer_reset => uart_tx_reset,              
                              clk => clk);

  --
  -- Read from buffer in UART Receiver at port address 06 hex.
  --
  rx4: uart_rx6 
  port map (            serial_in => uart_rx4,
                     en_16_x_baud => en_16_x_baud4,
                         data_out => uart_rx_data_out4,
                      buffer_read => read_from_uart_rx4,
              buffer_data_present => uart_rx_data_present4,
                 buffer_half_full => uart_rx_half_full4,
                      buffer_full => uart_rx_full4,
                     buffer_reset => uart_rx_reset,              
                              clk => clk);										

  baud_rate1: process(clk)
  begin
    if clk'event and clk = '1' then
      if baud_count1 = BaudCntrMax1 then
        baud_count1 <= 0;
        en_16_x_baud1 <= '1';
       else
        baud_count1 <= baud_count1 + 1;
        en_16_x_baud1 <= '0';
      end if;
    end if;
  end process baud_rate1;

  baud_rate2: process(clk)
  begin
    if clk'event and clk = '1' then
      if baud_count2 = BaudCntrMax2 then
        baud_count2 <= 0;
        en_16_x_baud2 <= '1';
       else
        baud_count2 <= baud_count2 + 1;
        en_16_x_baud2 <= '0';
      end if;
    end if;
  end process baud_rate2;
  
  baud_rate3: process(clk)
  begin
    if clk'event and clk = '1' then
      if baud_count3 = BaudCntrMax3 then
        baud_count3 <= 0;
        en_16_x_baud3 <= '1';
       else
        baud_count3 <= baud_count3 + 1;
        en_16_x_baud3 <= '0';
      end if;
    end if;
  end process baud_rate3;
  
  baud_rate4: process(clk)
  begin
    if clk'event and clk = '1' then
      if baud_count4 = BaudCntrMax4 then
        baud_count4 <= 0;
        en_16_x_baud4 <= '1';
       else
        baud_count4 <= baud_count4 + 1;
        en_16_x_baud4 <= '0';
      end if;
    end if;
  end process baud_rate4;

  -----------------------------------------------------------------------------------------
  -- Constant-Optimised Output Ports 
  -----------------------------------------------------------------------------------------
  --
  -- One constant-optimised output port is used to facilitate resetting of the UART macros.
  --

  constant_output_ports: process(clk)
  begin
    if clk'event and clk = '1' then
      if k_write_strobe = '1' then

        if port_id(0) = '1' then
          uart_tx_reset <= out_port(0);
          uart_rx_reset <= out_port(1);
        end if;

      end if;
    end if; 
  end process constant_output_ports;

end Behavioral;

------------------------------------------------------------------------------------
--
--
------------------------------------------------------------------------------------