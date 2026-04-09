library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MemDatos_tb is
end MemDatos_tb;

architecture TB of MemDatos_tb is
    constant N : integer := 8;
    
    signal CLK : STD_LOGIC := '0';
    signal WE  : STD_LOGIC := '0';
    signal A   : STD_LOGIC_VECTOR (N-1 downto 0) := (others => '0');
    signal WD  : STD_LOGIC_VECTOR (N-1 downto 0) := (others => '0');
    signal RD  : STD_LOGIC_VECTOR (N-1 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin
    DUT: entity work.MemDatos
        port map (
            CLK => CLK,
            WE  => WE,
            A   => A,
            WD  => WD,
            RD  => RD
        );

    clk_process : process
    begin
        while true loop
            CLK <= '0';
            wait for CLK_PERIOD/2;
            CLK <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process;

    stim_proc: process
        procedure WRITE_MEM(
            constant addr : STD_LOGIC_VECTOR(N-1 downto 0);
            constant data : STD_LOGIC_VECTOR(N-1 downto 0)
        ) is
        begin
            A  <= addr;
            WD <= data;
            WE <= '1';
            wait until rising_edge(CLK);
            WE <= '0';
        end procedure;

        procedure READ_CHECK(
            constant addr : STD_LOGIC_VECTOR(N-1 downto 0);
            constant expected : STD_LOGIC_VECTOR(N-1 downto 0)
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
        wait for 20 ns;

        ----------------------------------------------------------------
        -- TEST 1: Escritura/Lectura
        ----------------------------------------------------------------
        WRITE_MEM(x"01", x"AA");
        READ_CHECK(x"01", x"AA");

        ----------------------------------------------------------------
        -- TEST 2: Escrituras Múltiples
        ----------------------------------------------------------------
        WRITE_MEM(x"02", x"55");
        WRITE_MEM(x"03", x"FF");

        READ_CHECK(x"02", x"55");
        READ_CHECK(x"03", x"FF");

        ----------------------------------------------------------------
        -- TEST 3: Sobreescribir dirección de memoria
        ----------------------------------------------------------------
        WRITE_MEM(x"02", x"11");
        READ_CHECK(x"02", x"11");

        ----------------------------------------------------------------
        -- TEST 4: Casos Límite
        ----------------------------------------------------------------
        WRITE_MEM(x"00", x"99");
        WRITE_MEM(x"FF", x"77");

        READ_CHECK(x"00", x"99");
        READ_CHECK(x"FF", x"77");

        ----------------------------------------------------------------
        -- TEST 5: Acceso Secuencial
        ----------------------------------------------------------------
        for i in 0 to 15 loop
            WRITE_MEM(std_logic_vector(to_unsigned(i,N)),
                      std_logic_vector(to_unsigned(i*2,N)));
        end loop;

        for i in 0 to 15 loop
            READ_CHECK(std_logic_vector(to_unsigned(i,N)),
                       std_logic_vector(to_unsigned(i*2,N)));
        end loop;

        report "Pruebas Completadas" severity note;
        wait;
    end process;

end TB;