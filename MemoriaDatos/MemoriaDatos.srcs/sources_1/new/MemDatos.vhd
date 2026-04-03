library IEEE;
library WORK;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.RV8Integer.ALL;

entity MemDatos is
    Port ( CLK, WE : in STD_LOGIC;
           A : in STD_LOGIC_VECTOR (7 downto 0);
           WD : in STD_LOGIC_VECTOR (7 downto 0);
           RD : out STD_LOGIC_VECTOR (7 downto 0));
end MemDatos;

architecture Behavioral of MemDatos is

type MATRIZ is array (0 TO urv8int'HIGH) OF STD_LOGIC_VECTOR(7 downto 0);
signal MEMORIA: MATRIZ := (others => (others => '0')); -- Inicializamos memoria en 0s

begin
    process(CLK)
    begin
        if (CLK'event and CLK='1') then
            if (WE='1') then -- Escritura, ignorando registro 0
                MEMORIA(to_urv8int(A)) <= WD;
            else
                RD <= MEMORIA(to_urv8int(A));
            end if;
        end if; 
    end process;
end Behavioral;
