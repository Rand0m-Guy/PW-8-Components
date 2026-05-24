library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MemDatos_tb is
end MemDatos_tb;

architecture TB of MemDatos_tb is
    constant N : integer := 8;
    
    signal A   : STD_LOGIC_VECTOR (N-1 downto 0) := (others => '0');
    signal RD  : STD_LOGIC_VECTOR (15 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin
    DUT: entity work.MemInstruc
        port map (
            A   => A,
            RD  => RD
        );

    stim_proc: process
        procedure READ_CHECK(
            constant addr : STD_LOGIC_VECTOR(N-1 downto 0);
            constant expected : STD_LOGIC_VECTOR(15 downto 0)
        ) is
        begin
            A  <= addr;
        
            wait for 2ns;
        
            assert RD = expected
            report "Read mismatch at address " &
                   integer'image(to_integer(unsigned(addr)))
            severity error;
        end procedure;

    begin
        wait for 20 ns;

        ----------------------------------------------------------------
        -- TEST 1: Lectura
        ----------------------------------------------------------------
        READ_CHECK(x"01", x"00AA");

        READ_CHECK(x"02", x"0055");
        READ_CHECK(x"03", x"00FF");

        ----------------------------------------------------------------
        -- TEST 4: Casos Límite
        ----------------------------------------------------------------
        READ_CHECK(x"00", x"0099");
        READ_CHECK(x"FF", x"0077");

        report "Pruebas Completadas" severity note;
        wait;
    end process;

end TB;