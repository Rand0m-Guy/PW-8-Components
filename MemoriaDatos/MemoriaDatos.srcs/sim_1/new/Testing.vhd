library IEEE;
library WORK;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.RV8Integer.ALL;

entity MemDatos_tb is
end MemDatos_tb;

architecture TB of MemDatos_tb is

    -- DUT Signals
    signal CLK : STD_LOGIC := '0';
    signal WE  : STD_LOGIC := '0';
    signal A   : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal WD  : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal RD  : STD_LOGIC_VECTOR (7 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    ----------------------------------------------------------------
    -- DUT INSTANTIATION
    ----------------------------------------------------------------
    DUT: entity work.MemDatos
        port map (
            CLK => CLK,
            WE  => WE,
            A   => A,
            WD  => WD,
            RD  => RD
        );

    ----------------------------------------------------------------
    -- CLOCK GENERATION
    ----------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            CLK <= '0';
            wait for CLK_PERIOD/2;
            CLK <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process;

    ----------------------------------------------------------------
    -- STIMULUS
    ----------------------------------------------------------------
    stim_proc: process

        ----------------------------------------------------------------
        -- LOCAL PROCEDURES (Vivado-safe)
        ----------------------------------------------------------------

        -- WRITE (synchronous)
        procedure WRITE_MEM(
            constant addr : STD_LOGIC_VECTOR(7 downto 0);
            constant data : STD_LOGIC_VECTOR(7 downto 0)
        ) is
        begin
            A  <= addr;
            WD <= data;
            WE <= '1';
            wait until rising_edge(CLK);
            WE <= '0';
        end procedure;

        -- READ + CHECK (synchronous!)
        procedure READ_CHECK(
            constant addr : STD_LOGIC_VECTOR(7 downto 0);
            constant expected : STD_LOGIC_VECTOR(7 downto 0)
        ) is
        begin
            A  <= addr;
            WE <= '0';
        
            wait until rising_edge(CLK); -- issue read
            wait until rising_edge(CLK); -- allow RD to update
        
            assert RD = expected
            report "Read mismatch at address " &
                   integer'image(to_integer(unsigned(addr)))
            severity error;
        end procedure;

    begin

        ----------------------------------------------------------------
        -- INITIAL DELAY
        ----------------------------------------------------------------
        wait for 20 ns;

        ----------------------------------------------------------------
        -- TEST 1: Basic Write/Read
        ----------------------------------------------------------------
        WRITE_MEM(x"01", x"AA");
        READ_CHECK(x"01", x"AA");

        ----------------------------------------------------------------
        -- TEST 2: Multiple Writes
        ----------------------------------------------------------------
        WRITE_MEM(x"02", x"55");
        WRITE_MEM(x"03", x"FF");

        READ_CHECK(x"02", x"55");
        READ_CHECK(x"03", x"FF");

        ----------------------------------------------------------------
        -- TEST 3: Overwrite Same Address
        ----------------------------------------------------------------
        WRITE_MEM(x"02", x"11");
        READ_CHECK(x"02", x"11");

        ----------------------------------------------------------------
        -- TEST 4: Boundary Addresses
        ----------------------------------------------------------------
        WRITE_MEM(x"00", x"99");
        WRITE_MEM(x"FF", x"77");

        READ_CHECK(x"00", x"99");
        READ_CHECK(x"FF", x"77");

        ----------------------------------------------------------------
        -- TEST 5: SEQUENTIAL ACCESS (important)
        ----------------------------------------------------------------
        for i in 0 to 15 loop
            WRITE_MEM(std_logic_vector(to_unsigned(i,8)),
                      std_logic_vector(to_unsigned(i*2,8)));
        end loop;

        for i in 0 to 15 loop
            READ_CHECK(std_logic_vector(to_unsigned(i,8)),
                       std_logic_vector(to_unsigned(i*2,8)));
        end loop;

        ----------------------------------------------------------------
        -- DONE
        ----------------------------------------------------------------
        report "All tests completed" severity note;

        wait;
    end process;

end TB;