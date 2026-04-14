library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Extensor is
    generic(N         : integer := 8;
            imm_slice : integer := 12);
    Port ( imm    : in  STD_LOGIC_VECTOR (imm_slice-1 downto 0);
           immExt : out STD_LOGIC_VECTOR (N-1 downto 0);
           immSrc : in  STD_LOGIC_VECTOR (1 downto 0));
end Extensor;

architecture Extender of Extensor is
    signal vec_imm : std_logic_vector(N-1 downto 0);
begin

    process(imm, immSrc)
    begin
        case immSrc is
            when "00" =>
                vec_imm <= (N-1 downto 5 => imm(4)) & imm(4 downto 0);
            when "01" =>
                vec_imm <= (N-1 downto 5 => imm(imm_slice-1)) & imm(imm_slice-1 downto 10) & imm(2 downto 0);
            when "10" =>
                vec_imm <= imm(imm_slice-1 downto 7) & imm(2 downto 0);
            when "11" =>
                vec_imm <= imm(imm_slice-1 downto 4);
            when others =>
                vec_imm <= (others => '0');
        end case;
    end process;

    immExt <= vec_imm;

end Extender;