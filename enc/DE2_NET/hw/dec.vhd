library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decryptor is
    port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        address     : in  std_logic_vector(3 downto 0);  -- 4 bits: 16 registradores
        read_enable : in  std_logic;
        wr_enable   : in std_logic;
        chip_select : in std_logic;
        data_in     : in std_logic_vector(31 downto 0);
        data_out    : out std_logic_vector(31 downto 0)
    );
end entity decryptor;

architecture rtl of decryptor is

    -- Registros de entrada para o AES:
    signal text_in   : std_logic_vector(127 downto 0) := (others => '0'); -- Texto criptografado
    signal key_in    : std_logic_vector(127 downto 0) := (others => '0'); -- Chave de decriptografia
    signal start     : std_logic := '0';  -- Registrador de controle (start)
    
    -- Sinais de saída do AES:
    signal plaintext_out : std_logic_vector(127 downto 0);
    signal done          : std_logic;  -- Sinal que indica que a operação terminou

begin
    ------------------------------------------------------------------------------
    -- Instanciação do núcleo de decriptografia AES
    ------------------------------------------------------------------------------
    aes_dec_inst : entity work.aes_dec
        port map(
            clk        => clk,
            rst        => reset,
            dec_key    => key_in,
            ciphertext => text_in,
            plaintext  => plaintext_out,
            done       => done
        );
    
    ------------------------------------------------------------------------------
    -- Processo de escrita: quando chip_select e wr_enable estão ativos,
    -- o valor de data_in é escrito no registrador mapeado conforme o endereço.
    ------------------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                text_in <= (others => '0');
                key_in  <= (others => '0');
                start   <= '0';
            elsif chip_select = '1' and wr_enable = '1' then
                case to_integer(unsigned(address)) is
                    when 0 =>
                        text_in(127 downto 96) <= data_in;
                    when 1 =>
                        text_in(95 downto 64) <= data_in;
                    when 2 =>
                        text_in(63 downto 32) <= data_in;
                    when 3 =>
                        text_in(31 downto 0) <= data_in;
                    when 4 =>
                        key_in(127 downto 96) <= data_in;
                    when 5 =>
                        key_in(95 downto 64) <= data_in;
                    when 6 =>
                        key_in(63 downto 32) <= data_in;
                    when 7 =>
                        key_in(31 downto 0) <= data_in;
                    when 8 =>
                        start <= data_in(0);  -- Apenas o bit LSB é usado para start
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;
    
    ------------------------------------------------------------------------------
    -- Processo de leitura: quando chip_select e read_enable estão ativos, o valor
    -- do registrador mapeado é colocado em data_out.
    ------------------------------------------------------------------------------
    process(all)
    begin
        if chip_select = '1' and read_enable = '1' then
            case to_integer(unsigned(address)) is
                when 0 => data_out <= text_in(127 downto 96);
                when 1 => data_out <= text_in(95 downto 64);
                when 2 => data_out <= text_in(63 downto 32);
                when 3 => data_out <= text_in(31 downto 0);
                when 4 => data_out <= key_in(127 downto 96);
                when 5 => data_out <= key_in(95 downto 64);
                when 6 => data_out <= key_in(63 downto 32);
                when 7 => data_out <= key_in(31 downto 0);
                when 8 => data_out <= (others => '0') when start = '0' else (others => '1');
                when 9 => data_out <= (others => done);  -- replicando o sinal done
                when 10 => data_out <= plaintext_out(127 downto 96);
                when 11 => data_out <= plaintext_out(95 downto 64);
                when 12 => data_out <= plaintext_out(63 downto 32);
                when 13 => data_out <= plaintext_out(31 downto 0);
                when others => data_out <= (others => '0');
            end case;
        else
            data_out <= (others => '0');
        end if;
    end process;
    
    ------------------------------------------------------------------------------
    -- (Opcional) Geração de um sinal start para o núcleo AES
    -- Caso o seu AES de decriptografia inicie a operação automaticamente quando
    -- as entradas estiverem carregadas, você pode omitir essa lógica.
    -- Se necessário, aqui você poderia, por exemplo, sincronizar o sinal start com um
    -- pulso de escrita em endereço 8.
    ------------------------------------------------------------------------------
    -- Se for preciso, adicione lógica extra para gerar o pulso de start para o AES.
    
end architecture rtl;
