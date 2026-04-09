library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MemDatos is
    generic ( N : INTEGER := 8 );
    Port ( CLK, WE : in STD_LOGIC;
           A : in STD_LOGIC_VECTOR (N-1 downto 0);
           WD : in STD_LOGIC_VECTOR (N-1 downto 0);
           RD : out STD_LOGIC_VECTOR (N-1 downto 0));
end MemDatos;

architecture Behavioral of MemDatos is

type MATRIZ is array (0 TO 2**N - 1) OF STD_LOGIC_VECTOR(N-1 downto 0);
signal MEMORIA: MATRIZ := (others => (others => '0')); -- Inicializamos memoria en 0s

begin
    process(CLK)
    begin
        if (rising_edge(CLK)) then
            if (WE='1') then
                MEMORIA(to_integer(unsigned(A))) <= WD; -- Escritura
            else
                RD <= MEMORIA(to_integer(unsigned(A))); -- Lectura
            end if;
        end if; 
    end process;
end Behavioral;
