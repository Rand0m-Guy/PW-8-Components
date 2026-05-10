----------------------------------------------------------------------------------------------------
-- @module: SegmentDisplay
-- @authors: Macias Huerta Pablo Isaac, Pérez Bárcenas Juan Rubén
-- @description: Módulo que permite leer los valores de salida del procesador como display de 7 segmentos
-- @parameters:
            -- VAL1, VAL2 (in):     Valores a escribir en el display
            -- S11, S12, S13 (out): 3 displays correspondientes a VAL1
            -- S21, S22, S23 (out): 3 displays correspondientes a VAL2
            -- SIGN1, SIGN2 (out):  Valores de signo de los valores (van desde -127 a 128)
----------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity SegmentDisplay is
    Port ( VAL1, VAL2 : in STD_LOGIC_VECTOR (7 downto 0);
           S11, S12, S13, S21, S22, S23 : out STD_LOGIC_VECTOR (7 downto 0);
           SIGN1, SIGN2 : out STD_LOGIC
           );
end SegmentDisplay;

architecture Behavioral of SegmentDisplay is

begin


end Behavioral;
