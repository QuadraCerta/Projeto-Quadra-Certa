-- ============================================================================
-- Pedro Parte 1: Modelagem do banco de dados e carga inicial (Seed)
-- Cria o banco de dados QuadraCerta, define as tabelas principais (usuarios,
-- quadras, horarios, jogos, presencas) e insere 65 quadras reais de São Paulo
-- e região metropolitana (Grande SP e Jundiaí/arredores), além de dados base.
-- ============================================================================

CREATE DATABASE IF NOT EXISTS quadra_certa
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE quadra_certa;

-- ----------------------------------------------------------------------------
-- 1. Tabela de Usuários
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    telefone VARCHAR(20),
    bairro_preferido VARCHAR(100),
    esporte_favorito VARCHAR(50),
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 2. Tabela de Quadras
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS quadras (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    esporte VARCHAR(50) NOT NULL,
    endereco VARCHAR(255) NOT NULL,
    bairro VARCHAR(100) NOT NULL,
    cidade VARCHAR(100) NOT NULL DEFAULT 'São Paulo',
    tipo_acesso ENUM('Gratuita', 'Paga', 'Clube/Sesc') NOT NULL DEFAULT 'Gratuita',
    horario_abertura TIME NOT NULL DEFAULT '06:00:00',
    horario_fechamento TIME NOT NULL DEFAULT '22:00:00',
    descricao TEXT,
    foto_url VARCHAR(255),
    criado_por INT,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_quadras_usuario FOREIGN KEY (criado_por) REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 3. Tabela de Horários / Agenda da Quadra
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS horarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    quadra_id INT NOT NULL,
    dia_semana ENUM('Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo') NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fim TIME NOT NULL,
    status ENUM('Livre', 'Reservado', 'Manutenção') NOT NULL DEFAULT 'Livre',
    observacao VARCHAR(150),
    CONSTRAINT fk_horarios_quadra FOREIGN KEY (quadra_id) REFERENCES quadras(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 4. Tabela de Jogos Abertos
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS jogos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    quadra_id INT NOT NULL,
    criador_id INT NOT NULL,
    titulo VARCHAR(120) NOT NULL,
    esporte VARCHAR(50) NOT NULL,
    data_jogo DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fim TIME NOT NULL,
    vagas_totais INT NOT NULL,
    nivel ENUM('Iniciante', 'Intermediário', 'Avançado', 'Todos') NOT NULL DEFAULT 'Todos',
    descricao TEXT,
    status ENUM('Aberto', 'Lotado', 'Encerrado', 'Cancelado') NOT NULL DEFAULT 'Aberto',
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_jogos_quadra FOREIGN KEY (quadra_id) REFERENCES quadras(id) ON DELETE CASCADE,
    CONSTRAINT fk_jogos_criador FOREIGN KEY (criador_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 5. Tabela de Confirmação de Presença
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS presencas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    jogo_id INT NOT NULL,
    usuario_id INT NOT NULL,
    status ENUM('Confirmado', 'Lista de Espera', 'Cancelado') NOT NULL DEFAULT 'Confirmado',
    confirmado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_presencas_jogo FOREIGN KEY (jogo_id) REFERENCES jogos(id) ON DELETE CASCADE,
    CONSTRAINT fk_presencas_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    UNIQUE KEY uk_jogo_usuario (jogo_id, usuario_id)
) ENGINE=InnoDB;

-- ============================================================================
-- DADOS INICIAIS (SEED)
-- ============================================================================

-- Usuários iniciais do grupo (senhas ilustrativas em hash bcrypt)
INSERT INTO usuarios (id, nome, email, senha_hash, telefone, bairro_preferido, esporte_favorito) VALUES
(1, 'Pedro Menezes', 'pedro@quadracerta.com.br', '$2y$10$ExemploHashPedroMenezes1234567890', '(11) 99111-1111', 'Ibirapuera', 'Basquete'),
(2, 'Rian Andrade', 'rian@quadracerta.com.br', '$2y$10$ExemploHashRianAndrade12345678901', '(11) 99222-2222', 'Pinheiros', 'Futebol Society'),
(3, 'Gabriel Oliveira', 'gabriel@quadracerta.com.br', '$2y$10$ExemploHashGabrielOliveira1234567', '(11) 99333-3333', 'Tatuapé', 'Futsal'),
(4, 'Luan Padovani', 'luan@quadracerta.com.br', '$2y$10$ExemploHashLuanPadovani1234567890', '(11) 99444-4444', 'Santana', 'Vôlei');

-- 65 Quadras Famosas de São Paulo e Arredores
INSERT INTO quadras (nome, esporte, endereco, bairro, cidade, tipo_acesso, horario_abertura, horario_fechamento, descricao, criado_por) VALUES
-- ZONA SUL - SÃO PAULO
('Quadras de Basquete do Parque Ibirapuera (Portão 6)', 'Basquete', 'Av. Pedro Álvares Cabral, s/n - Portão 6', 'Vila Mariana', 'São Paulo', 'Gratuita', '05:00:00', '23:00:00', 'Um dos templos do basquete de rua de SP, com múltiplas tabelas e rachões diários.', 1),
('Quadra Poliesportiva Ibirapuera (Serraria)', 'Poliesportiva', 'Av. Pedro Álvares Cabral, s/n - Próximo à Serraria', 'Vila Mariana', 'São Paulo', 'Gratuita', '05:00:00', '23:00:00', 'Quadra muito disputada para futsal e vôlei recreativo.', 1),
('Quadras de Areia Parque Ibirapuera', 'Vôlei de Praia', 'Av. República do Líbano, 1111', 'Moema', 'São Paulo', 'Gratuita', '06:00:00', '22:00:00', 'Quadras de areia para vôlei de praia e futevôlei.', 4),
('Parque do Povo - Quadra Poliesportiva', 'Poliesportiva', 'Av. Henrique Chamma, 420', 'Itaim Bibi', 'São Paulo', 'Gratuita', '06:00:00', '22:00:00', 'Quadra bem conservada, muito movimentada nos fins de tarde.', 1),
('Parque do Povo - Basquete Street', 'Basquete', 'Av. Henrique Chamma, 420', 'Itaim Bibi', 'São Paulo', 'Gratuita', '06:00:00', '22:00:00', 'Meia quadra e quadra inteira com piso reformado.', 1),
('CDC Dorival Caymmi (Arena Brooklin)', 'Futebol Society', 'Rua Arandu, 700', 'Brooklin', 'São Paulo', 'Gratuita', '07:00:00', '22:00:00', 'Clube da Comunidade tradicional da Zona Sul com campo de grama sintética.', 2),
('Parque Severo Gomes - Quadra Poliesportiva', 'Poliesportiva', 'Rua Pires de Oliveira, 356', 'Granja Julieta', 'São Paulo', 'Gratuita', '06:00:00', '18:00:00', 'Quadra arborizada ideal para jogos diurnos em família ou amigos.', 3),
('Parque Burle Marx - Quadra de Areia', 'Beach Tennis', 'Av. Dona Helena Pereira de Moraes, 200', 'Vila Andrade', 'São Paulo', 'Gratuita', '07:00:00', '19:00:00', 'Espaço tranquilo para beach tennis e vôlei de areia.', 4),
('Sesc Santo Amaro - Ginásio Poliesportivo', 'Poliesportiva', 'Rua Amador Bueno, 505', 'Santo Amaro', 'São Paulo', 'Clube/Sesc', '09:00:00', '21:30:00', 'Ginásio coberto com excelente piso para basquete, futsal e vôlei.', 1),
('Sesc Interlagos - Quadras Externas', 'Futsal', 'Av. Manuel Alves Soares, 1100', 'Parque Colonial', 'São Paulo', 'Clube/Sesc', '09:00:00', '17:00:00', 'Complexo amplo com diversas quadras em meio à área verde.', 3),
('Parque Independência - Quadras Poliesportivas', 'Poliesportiva', 'Av. Nazaré, s/n', 'Ipiranga', 'São Paulo', 'Gratuita', '05:00:00', '20:00:00', 'Quadras ao lado do Museu do Ipiranga com alto fluxo de jogadores.', 2),
('Sesc Ipiranga - Ginásio', 'Vôlei', 'Rua Bom Pastor, 822', 'Ipiranga', 'São Paulo', 'Clube/Sesc', '09:00:00', '21:30:00', 'Ginásio coberto com horários abertos para recreação.', 4),
('Arena Congonhas Society', 'Futebol Society', 'Rua Tamoios, 380', 'Jardim Aeroporto', 'São Paulo', 'Paga', '07:00:00', '23:30:00', 'Quadras de grama sintética com iluminação LED e vestiários.', 2),
('Playball Pompéia / Vila Olímpia (Unidade Vila Olímpia)', 'Futebol Society', 'Rua Funchal, 500', 'Vila Olímpia', 'São Paulo', 'Paga', '08:00:00', '00:00:00', 'Complexo famoso de futebol society e churrasqueira pós-jogo.', 2),
('Parque Guarapiranga - Quadras', 'Futsal', 'Estrada do Guarapiranga, 575', 'Parque Alves de Lima', 'São Paulo', 'Gratuita', '06:00:00', '18:00:00', 'Quadras próximas à represa, muito usadas aos domingos.', 3),

-- ZONA OESTE - SÃO PAULO
('Parque Villa-Lobos - Quadras de Basquete Street', 'Basquete', 'Av. Prof. Fonseca Rodrigues, 2001', 'Alto de Pinheiros', 'São Paulo', 'Gratuita', '05:30:00', '19:00:00', 'Referência no streetball paulistano, com várias tabelas oficiais.', 1),
('Parque Villa-Lobos - Quadras Poliesportivas', 'Poliesportiva', 'Av. Prof. Fonseca Rodrigues, 2001', 'Alto de Pinheiros', 'São Paulo', 'Gratuita', '05:30:00', '19:00:00', 'Quadras para futsal e handebol próximas à entrada principal.', 3),
('Parque Villa-Lobos - Quadras de Tênis', 'Tênis', 'Av. Prof. Fonseca Rodrigues, 2001', 'Alto de Pinheiros', 'São Paulo', 'Gratuita', '05:30:00', '19:00:00', 'Quadras rápidas públicas muito procuradas para tênis.', 4),
('Parque da Água Branca - Quadra Poliesportiva', 'Poliesportiva', 'Av. Francisco Matarazzo, 455', 'Água Branca', 'São Paulo', 'Gratuita', '06:00:00', '20:00:00', 'Quadra tradicional na Zona Oeste para partidas amistosas.', 3),
('Sesc Pompeia - Ginásios Poliesportivos', 'Basquete', 'Rua Clélia, 93', 'Água Branca', 'São Paulo', 'Clube/Sesc', '09:00:00', '21:30:00', 'Ginásios icônicos empilhados no bloco esportivo projetado por Lina Bo Bardi.', 1),
('Playball Pompéia', 'Futebol Society', 'Av. Nicolas Boer, 66', 'Barra Funda', 'São Paulo', 'Paga', '08:00:00', '00:00:00', 'Um dos maiores complexos de futebol society da cidade.', 2),
('Praça Por do Sol - Quadra Comunitária', 'Basquete', 'Praça Cel. Custódio Fernandes Pinheiro, s/n', 'Alto de Pinheiros', 'São Paulo', 'Gratuita', '06:00:00', '22:00:00', 'Quadra revitalizada com vista privilegiada da região.', 1),
('CEPEUSP - Quadras Externas USP', 'Poliesportiva', 'Praça 2, Prof. Rubião Meira, 61', 'Butantã', 'São Paulo', 'Clube/Sesc', '07:00:00', '21:00:00', 'Centro de Práticas Esportivas da USP com estrutura olímpica.', 4),
('Parque Previdência - Quadra', 'Futsal', 'Rua Pedro Peccinini, 88', 'Jardim Previdência', 'São Paulo', 'Gratuita', '07:00:00', '18:00:00', 'Quadra cercada por mata atlântica preservada no Butantã.', 3),
('Arena Pinheiros Beach & Society', 'Futevôlei', 'Rua dos Pinheiros, 1250', 'Pinheiros', 'São Paulo', 'Paga', '07:00:00', '23:00:00', 'Quadras de areia cobertas e descobertas no coração de Pinheiros.', 4),

-- ZONA CENTRAL - SÃO PAULO
('Parque da Aclimação - Quadra Poliesportiva', 'Poliesportiva', 'Rua Muniz de Sousa, 1119', 'Aclimação', 'São Paulo', 'Gratuita', '06:00:00', '20:00:00', 'Quadra clássica do bairro com rachões de basquete e futsal.', 1),
('Parque Buenos Aires - Quadra Infantil/Juvenil', 'Poliesportiva', 'Av. Angélica, 1500', 'Higienópolis', 'São Paulo', 'Gratuita', '06:00:00', '19:00:00', 'Espaço recreativo para jogos leves em Higienópolis.', 3),
('Sesc 24 de Maio - Quadra Coberta', 'Futsal', 'Rua 24 de Maio, 109', 'República', 'São Paulo', 'Clube/Sesc', '09:00:00', '21:00:00', 'Quadra moderna no centro de São Paulo com vista panorâmica.', 3),
('Sesc Consolação - Ginásio Vermelho', 'Vôlei', 'Rua Dr. Vila Nova, 245', 'Vila Buarque', 'São Paulo', 'Clube/Sesc', '07:00:00', '21:30:00', 'Tradicional ginásio poliesportivo no centro.', 4),
('Praça Roosevelt - Espaço Esportivo', 'Basquete', 'Praça Franklin Roosevelt, s/n', 'Consolação', 'São Paulo', 'Gratuita', '00:00:00', '23:59:00', 'Ponto de encontro urbano com tabelas de streetball 3x3.', 1),
('Parque Augusta - Quadra Multiuso', 'Poliesportiva', 'Rua Augusta, 200', 'Consolação', 'São Paulo', 'Gratuita', '06:00:00', '21:00:00', 'Espaço recreativo muito frequentado por jovens no centro.', 1),
('Arena Pacaembu (Complexo Poliesportivo)', 'Tênis', 'Praça Charles Miller, s/n', 'Pacaembu', 'São Paulo', 'Paga', '06:00:00', '22:00:00', 'Complexo histórico revitalizado com quadras de tênis e poliesportiva.', 4),

-- ZONA LESTE - SÃO PAULO
('Parque Ceret (Tatuapé) - Quadras de Basquete', 'Basquete', 'Rua Canuto Abreu, s/n', 'Jardim Anália Franco', 'São Paulo', 'Gratuita', '06:00:00', '22:00:00', 'Maior polo esportivo público da Zona Leste com várias quadras.', 1),
('Parque Ceret - Campos e Quadras de Futsal', 'Futsal', 'Rua Canuto Abreu, s/n', 'Jardim Anália Franco', 'São Paulo', 'Gratuita', '06:00:00', '22:00:00', 'Amplo espaço para peladas de fim de semana no Tatuapé.', 3),
('Parque do Carmo - Quadras Poliesportivas', 'Poliesportiva', 'Av. Afonso de Sampaio e Sousa, 951', 'Itaquera', 'São Paulo', 'Gratuita', '05:30:00', '20:00:00', 'Diversas quadras espalhadas pelo maior parque da Zona Leste.', 3),
('Sesc Itaquera - Complexo Esportivo', 'Futebol Society', 'Av. Fernando do Espírito Santo Alves de Mattos, 1000', 'Itaquera', 'São Paulo', 'Clube/Sesc', '09:00:00', '17:00:00', 'Campos e quadras de altíssimo nível na Zona Leste.', 2),
('Sesc Belenzinho - Ginásios', 'Vôlei', 'Rua Padre Adelino, 1000', 'Belenzinho', 'São Paulo', 'Clube/Sesc', '09:00:00', '21:30:00', 'Ginásios cobertos muito disputados para vôlei e basquete.', 4),
('Parque Ecológico do Tietê - Quadras', 'Poliesportiva', 'Via Parque, 8055', 'Engenheiro Goulart', 'São Paulo', 'Gratuita', '06:00:00', '17:00:00', 'Quadras poliesportivas e campos de futebol em área ambiental.', 2),
('Parque Linear Tiquatira - Quadras de Basquete e Futsal', 'Basquete', 'Av. Gov. Carvalho Pinto, s/n', 'Penha', 'São Paulo', 'Gratuita', '00:00:00', '23:59:00', 'Várias quadras ao longo da avenida com iluminação noturna.', 1),
('CDC Arthur Friedenreich (Vila Alpina)', 'Futebol Society', 'Rua das Giestas, 410', 'Vila Alpina', 'São Paulo', 'Gratuita', '07:00:00', '22:00:00', 'Clube comunitário tradicional da Zona Leste.', 2),
('Playball São Caetano / Mooca (Unidade Mooca)', 'Futebol Society', 'Rua da Mooca, 1600', 'Mooca', 'São Paulo', 'Paga', '08:00:00', '00:00:00', 'Quadras society cobertas e descobertas na Mooca.', 2),

-- ZONA NORTE - SÃO PAULO
('Parque da Juventude - Quadras Poliesportivas', 'Poliesportiva', 'Av. Cruzeiro do Sul, 2630', 'Santana', 'São Paulo', 'Gratuita', '06:00:00', '22:00:00', 'Complexo famoso ao lado do metrô Carandiru com 8 quadras.', 3),
('Parque da Juventude - Quadras de Basquete', 'Basquete', 'Av. Cruzeiro do Sul, 2630', 'Santana', 'São Paulo', 'Gratuita', '06:00:00', '22:00:00', 'Ponto de encontro forte do basquete da Zona Norte.', 1),
('Sesc Santana - Ginásio Coberto', 'Basquete', 'Av. Luiz Dumont Villares, 579', 'Santana', 'São Paulo', 'Clube/Sesc', '09:00:00', '21:30:00', 'Ginásio climatizado com excelente estrutura na ZN.', 1),
('Centro Esportivo Tietê - Quadras', 'Poliesportiva', 'Av. Santos Dumont, 843', 'Luz / Ponte Pequena', 'São Paulo', 'Gratuita', '07:00:00', '21:00:00', 'Clube público histórico às margens do Rio Tietê.', 3),
('Parque Rodrigo de Gásperi - Quadra', 'Futsal', 'Av. Miguel de Castro, 321', 'Vila Zati / Pirituba', 'São Paulo', 'Gratuita', '06:00:00', '20:00:00', 'Principal parque de Pirituba com quadras bem movimentadas.', 3),
('Parque Cidade de Toronto - Quadras', 'Poliesportiva', 'Av. Cardeal Motta, 84', 'City América', 'São Paulo', 'Gratuita', '06:00:00', '18:00:00', 'Quadras poliesportivas e de tênis em Pirituba.', 4),
('Horto Florestal (Parque Alberto Löfgren) - Quadras', 'Poliesportiva', 'Rua do Horto, 931', 'Horto Florestal', 'São Paulo', 'Gratuita', '06:00:00', '18:00:00', 'Quadras cercadas pela Serra da Cantareira.', 4),
('CDC Jardim São Paulo', 'Futebol Society', 'Rua Viri, 425', 'Jardim São Paulo', 'São Paulo', 'Gratuita', '07:00:00', '22:00:00', 'Campo e quadras comunitárias muito tradicionais na ZN.', 2),

-- ARREDORES / GRANDE SÃO PAULO E REGIÃO (ABC, Guarulhos, Osasco, Barueri, Jundiaí)
('Parque Bosque Maia - Quadras Poliesportivas', 'Basquete', 'Av. Paulo Faccini, s/n', 'Centro', 'Guarulhos', 'Gratuita', '06:00:00', '22:00:00', 'Principal ponto esportivo de Guarulhos com rachões diários.', 1),
('Sesc Guarulhos - Ginásio Poliesportivo', 'Vôlei', 'Rua Guilherme Lino dos Santos, 1200', 'Jardim Flor do Campo', 'Guarulhos', 'Clube/Sesc', '09:00:00', '21:30:00', 'Ginásio moderno com estrutura completa em Guarulhos.', 4),
('Parque Chico Mendes - Quadras', 'Poliesportiva', 'Rua Lázaro Suave, 15', 'City Bussocaba', 'Osasco', 'Gratuita', '06:00:00', '20:00:00', 'Parque referência em Osasco para basquete e futsal.', 1),
('Sesc Osasco - Quadras Externas e Ginásio', 'Futsal', 'Av. Sport Club Corinthians Paulista, 1300', 'Jardim das Flores', 'Osasco', 'Clube/Sesc', '09:00:00', '21:30:00', 'Excelente espaço esportivo em Osasco.', 3),
('Parque Municipal Dom José - Quadras', 'Basquete', 'Rua Ângela Mirella, 500', 'Jardim Maria Tereza', 'Barueri', 'Gratuita', '06:00:00', '22:00:00', 'Quadras muito procuradas na região de Alphaville e Barueri.', 1),
('Parque Ecológico do Tietê - Núcleo Barueri', 'Futebol Society', 'Av. Dr. Dib Sauaia Neto, 1600', 'Alphaville', 'Barueri', 'Gratuita', '06:00:00', '19:00:00', 'Campos e quadras poliesportivas ao lado de Alphaville.', 2),
('Parque Central de Santo André - Quadras', 'Poliesportiva', 'Rua José Bonifácio, s/n', 'Vila Assunção', 'Santo André', 'Gratuita', '06:00:00', '21:00:00', 'Maior parque de Santo André com quadras para várias modalidades.', 3),
('Sesc Santo André - Ginásio', 'Basquete', 'Rua Tamarutaca, 302', 'Vila Guiomar', 'Santo André', 'Clube/Sesc', '09:00:00', '21:30:00', 'Referência esportiva no Grande ABC.', 1),
('Parque Cidade de São Bernardo (Raphael Lazzuri)', 'Basquete', 'Av. Kennedy, 1111', 'Jardim do Mar', 'São Bernardo do Campo', 'Gratuita', '06:00:00', '22:00:00', 'Complexo esportivo tradicional de São Bernardo do Campo.', 1),
('Parque Espaço Verde Chico Mendes (São Caetano)', 'Poliesportiva', 'Av. Fernando Simonsen, 566', 'Cerâmica', 'São Caetano do Sul', 'Gratuita', '06:00:00', '22:00:00', 'Quadras muito bem cuidadas em São Caetano do Sul.', 4),
('Sesc São Caetano - Quadra Poliesportiva', 'Vôlei', 'Rua Piauí, 554', 'Santa Paula', 'São Caetano do Sul', 'Clube/Sesc', '09:00:00', '21:30:00', 'Espaço coberto para atividades recreativas no ABC.', 4),
('Parque da Cidade de Jundiaí - Quadras Poliesportivas', 'Poliesportiva', 'Rodovia João Cereser, km 66', 'Pinheirinho', 'Jundiaí', 'Gratuita', '06:30:00', '19:00:00', 'Principal parque de Jundiaí com quadras de basquete, futsal e vôlei.', 1),
('Complexo Esportivo Dr. Nicolino de Lucca (Bolão)', 'Basquete', 'Rua Rodrigo Soares de Oliveira, s/n', 'Anhangabaú', 'Jundiaí', 'Gratuita', '06:00:00', '22:00:00', 'Centro esportivo histórico de Jundiaí com quadras externas e ginásio.', 1),
('Sesc Jundiaí - Ginásio Poliesportivo', 'Vôlei', 'Av. Antônio Frederico Ozanan, 6600', 'Jardim Botânico', 'Jundiaí', 'Clube/Sesc', '09:00:00', '21:30:00', 'Ginásio moderno em Jundiaí com agendamentos e recreação livre.', 4),
('Parque Engordadouro Ângelo Costa - Quadra de Areia', 'Beach Tennis', 'Av. André Costa, 1595', 'Engordadouro', 'Jundiaí', 'Gratuita', '06:00:00', '19:00:00', 'Quadras de areia muito movimentadas em Jundiaí.', 4),
('Parque das Hortênsias - Quadras', 'Futsal', 'Praça Miguel Ortega, 500', 'Parque Assunção', 'Taboão da Serra', 'Gratuita', '07:00:00', '18:00:00', 'Principal espaço público de lazer e esporte em Taboão da Serra.', 3);

-- Horários de exemplo para testar a agenda (Parte 9)
INSERT INTO horarios (quadra_id, dia_semana, hora_inicio, hora_fim, status, observacao) VALUES
(1, 'Sábado', '09:00:00', '12:00:00', 'Livre', 'Rachão aberto 5x5'),
(1, 'Domingo', '15:00:00', '18:00:00', 'Livre', 'Basquete livre'),
(14, 'Quarta', '20:00:00', '21:00:00', 'Reservado', 'Pelada semanal fixa'),
(16, 'Sábado', '10:00:00', '13:00:00', 'Livre', 'Streetball 3x3'),
(33, 'Domingo', '09:00:00', '11:00:00', 'Livre', 'Treino aberto'),
(61, 'Sábado', '14:00:00', '17:00:00', 'Livre', 'Rachão aberto no Parque da Cidade');

-- Jogos abertos de exemplo para testar criação e presença (Partes 10 e 11)
INSERT INTO jogos (quadra_id, criador_id, titulo, esporte, data_jogo, hora_inicio, hora_fim, vagas_totais, nivel, descricao) VALUES
(1, 1, 'Rachão 5x5 no Ibira', 'Basquete', '2026-11-28', '10:00:00', '12:00:00', 10, 'Intermediário', 'Bora completar dois times no Portão 6! Levar camisa clara e escura.'),
(14, 2, 'Society Quarta à Noite', 'Futebol Society', '2026-11-25', '20:00:00', '21:00:00', 14, 'Todos', 'Faltam 4 jogadores para fechar o rachão.'),
(33, 3, 'Futsal Domingo de Manhã', 'Futsal', '2026-11-29', '09:00:00', '11:00:00', 10, 'Iniciante', 'Pelada amistosa no Ceret.'),
(12, 4, 'Vôlei Misto Sesc Ipiranga', 'Vôlei', '2026-11-28', '15:00:00', '17:00:00', 12, 'Intermediário', 'Vôlei recreativo 6x6.');

-- Confirmações de presença de exemplo
INSERT INTO presencas (jogo_id, usuario_id, status) VALUES
(1, 1, 'Confirmado'),
(1, 2, 'Confirmado'),
(2, 2, 'Confirmado'),
(2, 3, 'Confirmado'),
(3, 3, 'Confirmado'),
(4, 4, 'Confirmado');
