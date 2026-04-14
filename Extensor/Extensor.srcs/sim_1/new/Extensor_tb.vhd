library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Extensor_tb is
end Extensor_tb;

architecture tb of Extensor_tb is

    constant N         : integer := 8;
    constant IMM_SLICE : integer := 12;

    signal imm    : std_logic_vector(IMM_SLICE-1 downto 0);
    signal immExt : std_logic_vector(N-1 downto 0);
    signal immSrc : std_logic_vector(1 downto 0);

    component Extensor
        generic(N         : integer := 8;
                imm_slice : integer := 12);
        Port ( imm    : in  STD_LOGIC_VECTOR (imm_slice-1 downto 0);
               immExt : out STD_LOGIC_VECTOR (N-1 downto 0);
               immSrc : in  STD_LOGIC_VECTOR (1 downto 0));
    end component;

begin

    UUT: Extensor
        generic map(N => N, imm_slice => IMM_SLICE)
        port map(imm => imm, immExt => immExt, immSrc => immSrc);

    process
    begin

        -- immSrc = "00" : sign_ext(imm[4:0])
        -- imm[4]=0 -> Esperado: 00001101
        imm    <= "000000001101";
        immSrc <= "00";
        wait for 20 ns;

        report "Simulacion completada." severity failure;

    end process;

end tb;