-- =============================================
-- BANCO DE DADOS: GO_Servicos
-- =============================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tabela de usuários (clientes e profissionais)
CREATE TABLE usuarios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    telefone VARCHAR(20),
    documento VARCHAR(18) UNIQUE NOT NULL, -- CPF/CNPJ
    cep VARCHAR(8),
    tipo VARCHAR(20) CHECK (tipo IN ('cliente', 'profissional')) NOT NULL,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'blocked', 'pending')),
    creditos INT DEFAULT 0,
    senha_hash VARCHAR(255), -- para autenticação
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Categorias de serviços
CREATE TABLE categorias (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    icone VARCHAR(10),
    contagem INT DEFAULT 0
);

-- Profissionais (dados complementares)
CREATE TABLE profissionais (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID REFERENCES usuarios(id) ON DELETE CASCADE,
    categoria_id INT REFERENCES categorias(id),
    descricao TEXT,
    avaliacao_media DECIMAL(2,1) DEFAULT 0,
    total_avaliacoes INT DEFAULT 0,
    preco_hora DECIMAL(10,2),
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    ativo BOOLEAN DEFAULT TRUE
);

-- Solicitações de serviço
CREATE TABLE solicitacoes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cliente_id UUID REFERENCES usuarios(id),
    categoria_id INT REFERENCES categorias(id),
    descricao TEXT NOT NULL,
    estado VARCHAR(2),
    cidade VARCHAR(100),
    urgencia VARCHAR(20) CHECK (urgencia IN ('urgent', 'normal', 'flexible')),
    status VARCHAR(20) DEFAULT 'aberta',
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Chat e mensagens
CREATE TABLE conversas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    participante1 UUID REFERENCES usuarios(id),
    participante2 UUID REFERENCES usuarios(id),
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE mensagens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversa_id UUID REFERENCES conversas(id) ON DELETE CASCADE,
    remetente_id UUID REFERENCES usuarios(id),
    texto TEXT NOT NULL,
    enviada_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    lida BOOLEAN DEFAULT FALSE
);

-- Anúncios (banners e sidebar)
CREATE TABLE anuncios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    titulo VARCHAR(200) NOT NULL,
    descricao TEXT,
    url_midia TEXT NOT NULL,         -- URL ou base64 da imagem/vídeo
    tipo_midia VARCHAR(10) DEFAULT 'image', -- 'image' ou 'video'
    tipo_anuncio VARCHAR(10) CHECK (tipo_anuncio IN ('banner', 'sidebar')),
    link_destino VARCHAR(500),
    ativo BOOLEAN DEFAULT TRUE,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Usuários bloqueados (por conduta desleal)
CREATE TABLE bloqueios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID REFERENCES usuarios(id),
    motivo TEXT NOT NULL,
    duracao VARCHAR(20) CHECK (duracao IN ('temporary', 'permanent')),
    data_bloqueio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_termino TIMESTAMP, -- nulo se permanente
    removido BOOLEAN DEFAULT FALSE
);

-- Configurações editáveis da página (para o admin)
CREATE TABLE configuracoes_pagina (
    id SERIAL PRIMARY KEY,
    chave VARCHAR(100) UNIQUE NOT NULL,
    valor TEXT NOT NULL
);

-- Índices para performance
CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_usuarios_tipo ON usuarios(tipo);
CREATE INDEX idx_solicitacoes_cliente ON solicitacoes(cliente_id);
CREATE INDEX idx_mensagens_conversa ON mensagens(conversa_id);