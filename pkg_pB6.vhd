-------------------------------------------------------------------------------
-- Project: pBlaze6 controller
-- Author(s): HusTakocem
-- Created: Jan 2016 
-------------------------------------------------------------------------------
-- pBlaze6 components pkg
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Package pkg_pB6 Is

 constant BAUD_RATE: positive := 115200; -- baud rate
 constant BAUD_RATE1: positive := 115200; -- baud rate
 constant BAUD_RATE2: positive := 2400; -- baud rate
 constant BAUD_RATE3: positive := 19200; -- baud rate
 constant BAUD_RATE4: positive := 19200; -- baud rate
 constant FREQ: positive := 50e6; -- processor clock in Hz
 constant HW_VERSION: std_logic_vector(7 downto 0) := x"48";  
 constant INTR_VEC: std_logic_vector(11 downto 0) := X"3FF"; -- 64 instr to end
 constant SP_MEMORY: positive := 64;
 constant RAM_SIZE_KWORDS : integer := 1; -- in k-words
 constant JTAG_LOADER : integer := 1;

 -- processor
 component kcpsm6
    generic(                 hwbuild : std_logic_vector(7 downto 0) := HW_VERSION;
                    interrupt_vector : std_logic_vector(11 downto 0) := INTR_VEC;
             scratch_pad_memory_size : integer := SP_MEMORY);
    port (                   address : out std_logic_vector(11 downto 0);
                         instruction : in std_logic_vector(17 downto 0);
                         bram_enable : out std_logic;
                             in_port : in std_logic_vector(7 downto 0);
                            out_port : out std_logic_vector(7 downto 0);
                             port_id : out std_logic_vector(7 downto 0);
                        write_strobe : out std_logic;
                      k_write_strobe : out std_logic;
                         read_strobe : out std_logic;
                           interrupt : in std_logic;
                       interrupt_ack : out std_logic;
                               sleep : in std_logic;
                               reset : in std_logic;
                                 clk : in std_logic);
    end component;

-- Development Program Memory
 component program_ROM7_debug
    generic(             C_FAMILY : string := "7S"; 
                C_RAM_SIZE_KWORDS : integer := RAM_SIZE_KWORDS;
             C_JTAG_LOADER_ENABLE : integer := JTAG_LOADER);
    Port (      address : in std_logic_vector(11 downto 0);
            instruction : out std_logic_vector(17 downto 0);
                 enable : in std_logic;
                    rdl : out std_logic;                    
                    clk : in std_logic);
    end component;

--
-- UART Transmitter with integral 16 byte FIFO buffer
 component uart_tx6 
    Port (             data_in : in std_logic_vector(7 downto 0);
                  en_16_x_baud : in std_logic;
                    serial_out : out std_logic;
                  buffer_write : in std_logic;
           buffer_data_present : out std_logic;
              buffer_half_full : out std_logic;
                   buffer_full : out std_logic;
                  buffer_reset : in std_logic;
                           clk : in std_logic);
    end component;

--
-- UART Receiver with integral 16 byte FIFO buffer
 component uart_rx6
    Port (           serial_in : in std_logic;
                  en_16_x_baud : in std_logic;
                      data_out : out std_logic_vector(7 downto 0);
                   buffer_read : in std_logic;
           buffer_data_present : out std_logic;
              buffer_half_full : out std_logic;
                   buffer_full : out std_logic;
                  buffer_reset : in std_logic;
                           clk : in std_logic);
    end component;

-- picoBlaze controller platform v1
 component pB6_uart_v1 is
  Port ( uart_rx : in std_logic;
         uart_tx : out std_logic;
             NPs : out std_logic_vector(15 downto 0);
         reset_b : in std_logic;
             clk : in std_logic);
  end component;

    -- hw timer for picoBlaze
    component timer_v1 is
        generic(N: natural := 32);
        port(clk: in std_logic;
             rst: in std_logic;
             ce: in std_logic;
             flag: out std_logic;
             T_sec : in std_logic_vector(N-1 downto 0);
             timer: out std_logic_vector(N-1 downto 0)
             );
    end component;

    -- baud counter for uart (special cases)
    component baud_cntr is
    generic(SPEED: string := "fast"; -- or "slow"
            M: natural := 4;
            D: natural := 5);
    port(clk: in std_logic;
         en_16_x_baud: out std_logic
         );
    end component;

End Package pkg_pB6;
