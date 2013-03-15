LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY cache_tb IS
END cache_tb;
 
ARCHITECTURE behavior OF cache_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT cache
    Generic (WIDTH : natural := 13; -- Length of address
             DWIDTH : natural := 13; -- Length of one entry
             ADR_LENGTH : natural := 4); -- Log2 of number of entries in the cache
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         addr : IN  std_logic_vector(12 downto 0);
         din : IN  std_logic_vector(12 downto 0);
         push : IN  std_logic;
         valid : OUT  std_logic;
         dout : OUT  std_logic_vector(12 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal addr : std_logic_vector(12 downto 0) := (others => '0');
   signal din : std_logic_vector(12 downto 0) := (others => '0');
   signal push : std_logic := '0';

 	--Outputs
   signal valid : std_logic;
   signal dout : std_logic_vector(12 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: cache 
   Generic map (WIDTH => 13, -- Length of address
             DWIDTH => 13, -- Length of one entry
             ADR_LENGTH => 4) -- Log2 of number of entries in the cache
   PORT MAP (
          clk => clk,
          reset => reset,
          addr => addr,
          din => din,
          push => push,
          valid => valid,
          dout => dout
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      reset <= '1';
      -- hold reset state for 100 ns.
      wait for 100 ns;	
      reset <= '0';
      
      addr <= (others => '0');
      din <= "0000000000001";
-- Write one entry
      push <= '1';
-- Check that valid is zero
      assert valid = '0' report "valid not zero" severity failure;
      wait for clk_period;
      push <= '0'; -- Deassert push
      wait for clk_period;
-- Test correctness
      assert valid = '1' report "valid not one" severity failure;
      assert dout = "0000000000001" report "Output invalid" severity failure;
      
-- Set addr and din for new entry
      addr <= (1 => '1', others => '0');
      din <= "1111111111111";
      wait for clk_period;
-- Add second entry
      push <= '1';
      assert valid = '0' report "valid not zero" severity failure;
      wait for clk_period;
      push <= '0'; -- Deassert push
      wait for clk_period;
-- Test correctness
      assert valid = '1' report "valid not one" severity failure;
      assert dout = "1111111111111" report "Output invalid" severity failure;
      
-- Test correctness of the first entry
      addr <= (others => '0');
      wait for clk_period;
      assert valid = '1' report "valid not one" severity failure;
      assert dout = "0000000000001" report "Output invalid" severity failure;
-- Try addr with lower bits same
      addr <= "1000000000000";
      wait for clk_period;
      
      assert valid = '0' report "valid not zero, different tag bits test" severity failure;
      wait for clk_period;
      assert false report "Completed succesfully" severity failure;
      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
