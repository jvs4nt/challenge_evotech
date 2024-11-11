//CRIACAO DAS TABELAS

drop table tb_assoc_atend_proc cascade constraints; 
drop table tb_atendimento cascade constraints; 
drop table tb_cliente cascade constraints;
drop table tb_rede_credenciada cascade constraints;
drop table tb_endereco cascade constraints;
drop table tb_plano cascade constraints;
drop table tb_procedimento cascade constraints;
drop table tb_tratamento cascade constraints;

CREATE TABLE tb_assoc_atend_proc (
    tb_atendimento_id_atendimento VARCHAR2(20) NOT NULL,
    tb_procedimento_id_proc       VARCHAR2(8) NOT NULL
);

ALTER TABLE tb_assoc_atend_proc ADD CONSTRAINT atend_proc_pk PRIMARY KEY 
( tb_atendimento_id_atendimento, tb_procedimento_id_proc );

CREATE TABLE tb_atendimento (
    id_atendimento                 VARCHAR2(20) NOT NULL,
    dt_atendimento                 DATE NOT NULL,
    diagnostico                    VARCHAR2(300) NOT NULL,
    tb_cliente_id_clie             VARCHAR2(20) NOT NULL,
    tb_rede_credenciada_id_empresa VARCHAR2(8) NOT NULL
);

ALTER TABLE tb_atendimento ADD CONSTRAINT tb_atendimento_pk 
PRIMARY KEY ( id_atendimento );

CREATE TABLE tb_cliente (
    id_clie            VARCHAR2(20) NOT NULL,
    cpf                VARCHAR2(11) NOT NULL UNIQUE,
    dt_cadastro        DATE NOT NULL,
    nm_clie            VARCHAR2(100) NOT NULL,
    dt_nasc            DATE NOT NULL,
    genero             CHAR(1) NOT NULL,
    telefone           VARCHAR2(15) NOT NULL UNIQUE,
    email              VARCHAR2(300) NOT NULL UNIQUE,
    tb_endereco_id_end VARCHAR2(10) NOT NULL,
    tb_plano_id_plano  VARCHAR2(8) NOT NULL
);

ALTER TABLE tb_cliente ADD CONSTRAINT tb_cliente_pk PRIMARY KEY ( id_clie );

CREATE TABLE tb_endereco (
    id_end     VARCHAR2(10) NOT NULL,
    cep        VARCHAR2(8) NOT NULL,
    logradouro VARCHAR2(300) NOT NULL,
    num_end    VARCHAR2(5) NOT NULL,
    compl_end  VARCHAR2(20),
    bairro     VARCHAR2(40) NOT NULL,
    cidade     VARCHAR2(40) NOT NULL,
    uf         CHAR(2) NOT NULL
);

ALTER TABLE tb_endereco ADD CONSTRAINT tb_endereco_pk PRIMARY KEY ( id_end );

CREATE TABLE tb_plano (
    id_plano    VARCHAR2(8) NOT NULL,
    nm_plano    VARCHAR2(50) NOT NULL,
    tp_plano    VARCHAR2(20) NOT NULL,
    valor_plano NUMBER NOT NULL
);

ALTER TABLE tb_plano ADD CONSTRAINT tb_plano_pk PRIMARY KEY ( id_plano );

CREATE TABLE tb_procedimento (
    id_proc      VARCHAR2(8) NOT NULL,
    nm_proc      VARCHAR2(200) NOT NULL,
    tp_proc      VARCHAR2(30) NOT NULL,
    custo_medio  NUMBER NOT NULL,
    complexidade VARCHAR2(30) NOT NULL
);

ALTER TABLE tb_procedimento ADD CONSTRAINT tb_procedimento_pk 
PRIMARY KEY ( id_proc );

CREATE TABLE tb_rede_credenciada (
    id_empresa         VARCHAR2(8) NOT NULL,
    cnpj               VARCHAR2(20) NOT NULL UNIQUE,
    dt_cadastro        DATE NOT NULL,
    nm_empresa         VARCHAR2(200) NOT NULL,
    especialidade      VARCHAR2(150) NOT NULL,
    telefone           VARCHAR2(12) NOT NULL UNIQUE,
    email              VARCHAR2(300) NOT NULL UNIQUE,
    tb_endereco_id_end VARCHAR2(10) NOT NULL
);

ALTER TABLE tb_rede_credenciada ADD CONSTRAINT rede_cred_pk 
PRIMARY KEY ( id_empresa );

CREATE TABLE tb_tratamento (
    id_tratamento                 VARCHAR2(8) NOT NULL,
    desc_tratamento               VARCHAR2(500) NOT NULL,
    nivel_urgencia                VARCHAR2(20) NOT NULL,
    tb_atendimento_id_atendimento VARCHAR2(20) NOT NULL
);

ALTER TABLE tb_tratamento ADD CONSTRAINT tb_tratamento_pk 
PRIMARY KEY ( id_tratamento );

ALTER TABLE tb_assoc_atend_proc
    ADD CONSTRAINT tb_atend_fk FOREIGN KEY ( tb_atendimento_id_atendimento )
        REFERENCES tb_atendimento ( id_atendimento );

ALTER TABLE tb_atendimento
    ADD CONSTRAINT tb_cliente_fk FOREIGN KEY ( tb_cliente_id_clie )
        REFERENCES tb_cliente ( id_clie );

ALTER TABLE tb_cliente
    ADD CONSTRAINT tb_enderec_fk FOREIGN KEY ( tb_endereco_id_end )
        REFERENCES tb_endereco ( id_end );

ALTER TABLE tb_rede_credenciada
    ADD CONSTRAINT tb_endereco_fk FOREIGN KEY ( tb_endereco_id_end )
        REFERENCES tb_endereco ( id_end );

ALTER TABLE tb_cliente
    ADD CONSTRAINT tb_plano_fk FOREIGN KEY ( tb_plano_id_plano )
        REFERENCES tb_plano ( id_plano );

ALTER TABLE tb_assoc_atend_proc
    ADD CONSTRAINT tb_proced_fk FOREIGN KEY ( tb_procedimento_id_proc )
        REFERENCES tb_procedimento ( id_proc );

ALTER TABLE tb_atendimento
    ADD CONSTRAINT tb_rede_creden_fk FOREIGN KEY ( tb_rede_credenciada_id_empresa )
        REFERENCES tb_rede_credenciada ( id_empresa );

ALTER TABLE tb_tratamento
    ADD CONSTRAINT trat_atend_fk FOREIGN KEY ( tb_atendimento_id_atendimento )
        REFERENCES tb_atendimento ( id_atendimento );


------------------------------------------------------
--PL-SQL

set serveroutput on
set verify off


--Funções de validação. Foram criadas 3: Validar CNPJ, CPF e E-MAIL.



--VALIDAR CNPJ

CREATE OR REPLACE FUNCTION validar_cnpj(
    p_cnpj VARCHAR2
) RETURN BOOLEAN AS
    v_count NUMBER;
BEGIN
    -- Verifica se o CNPJ possui 14 caracteres e é numérico
    IF LENGTH(p_cnpj) != 14 OR NOT REGEXP_LIKE(p_cnpj, '^\d+$') THEN
        RETURN FALSE;
    END IF;

    SELECT COUNT(*)
    INTO v_count
    FROM tb_rede_credenciada
    WHERE cnpj = p_cnpj;

    IF v_count > 0 THEN
        RETURN FALSE;
    END IF;

    RETURN TRUE;
END validar_cnpj;
/



-- VALIDAR CPF

CREATE OR REPLACE FUNCTION validar_cpf(p_cpf VARCHAR2) RETURN BOOLEAN IS
    v_count NUMBER;
BEGIN
    
    SELECT COUNT(*)
    INTO v_count
    FROM tb_cliente
    WHERE cpf = p_cpf;

    IF v_count > 0 THEN
        RETURN FALSE;
    END IF;

    IF LENGTH(p_cpf) != 11 OR NOT REGEXP_LIKE(p_cpf, '^\d{11}$') THEN
        RETURN FALSE;
    END IF;

    RETURN TRUE;
END validar_cpf;
/




-- VALIDAR E-MAIL

CREATE OR REPLACE FUNCTION validar_email(p_email VARCHAR2) RETURN BOOLEAN IS
BEGIN
    RETURN REGEXP_LIKE(p_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
END validar_email;





-- PROCEDURES PARA INSERT NAS TABELAS



-- INSERT TB_PLANO
CREATE OR REPLACE PROCEDURE inserir_plano(
    p_id_plano  IN  VARCHAR2,
    p_nm_plano  IN  VARCHAR2,
    p_tp_plano  IN  VARCHAR2,
    p_valor_plano IN NUMBER
)AS

BEGIN
    
    INSERT INTO tb_plano (id_plano, nm_plano, tp_plano, valor_plano)
     VALUES (p_id_plano, p_nm_plano, p_tp_plano, p_valor_plano);

COMMIT;

    DBMS_OUTPUT.PUT_LINE('Plano inserido com sucesso: ' || p_id_plano);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro desconhecido: ' || SQLERRM);
END inserir_plano;
/




--INSERT TB_ENDERECO

CREATE OR REPLACE PROCEDURE inserir_endereco (
    p_id_end IN tb_endereco.id_end%TYPE,
    p_cep IN tb_endereco.cep%TYPE,
    p_logradouro IN tb_endereco.logradouro%TYPE,
    p_num_end IN tb_endereco.num_end%TYPE,
    p_compl_end IN tb_endereco.compl_end%TYPE,
    p_bairro IN tb_endereco.bairro%TYPE,
    p_cidade IN tb_endereco.cidade%TYPE,
    p_uf IN tb_endereco.uf%TYPE
) IS
BEGIN
    
    INSERT INTO tb_endereco (id_end, cep, logradouro, num_end, compl_end, bairro,
        cidade, uf)
    VALUES (p_id_end,p_cep,p_logradouro,p_num_end,p_compl_end,p_bairro,p_cidade,
    p_uf);

COMMIT;

    DBMS_OUTPUT.PUT_LINE('Endereço inserido com sucesso: ' || p_id_end);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao inserir endereço: ' || SQLERRM);
END inserir_endereco;
/





--INSERT TB_PROCEDIMENTO

CREATE OR REPLACE PROCEDURE inserir_procedimento (
    p_id_proc IN tb_procedimento.id_proc%TYPE,
    p_nm_proc IN tb_procedimento.nm_proc%TYPE,
    p_tp_proc IN tb_procedimento.tp_proc%TYPE,
    p_custo_medio IN tb_procedimento.custo_medio%TYPE,
    p_complexidade IN tb_procedimento.complexidade%TYPE
) IS
BEGIN
    -- Inserir o registro na tabela tb_procedimento
    INSERT INTO tb_procedimento (id_proc, nm_proc, tp_proc, custo_medio, 
    complexidade) 
    VALUES (p_id_proc, p_nm_proc, p_tp_proc, p_custo_medio, p_complexidade);

COMMIT;

    DBMS_OUTPUT.PUT_LINE('Procedimento inserido com sucesso: ' || p_id_proc);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao inserir procedimento: ' || SQLERRM);
END inserir_procedimento;
/





--INSERT TB_CLIENTE

CREATE OR REPLACE PROCEDURE inserir_cliente(
    p_id_clie          IN VARCHAR2,
    p_cpf              IN VARCHAR2,
    p_dt_cadastro      IN DATE,
    p_nm_clie          IN VARCHAR2,
    p_dt_nasc          IN DATE,
    p_genero           IN CHAR,
    p_telefone         IN VARCHAR2,
    p_email            IN VARCHAR2,
    p_tb_endereco_id   IN VARCHAR2,
    p_tb_plano_id      IN VARCHAR2
) AS
BEGIN
    
    IF NOT validar_cpf(p_cpf) THEN
        RAISE_APPLICATION_ERROR(-20001, 'CPF inválido ou já existente.');
    END IF;

    IF NOT validar_email(p_email) THEN
        RAISE_APPLICATION_ERROR(-20002, 'E-mail inválido.');
    END IF;

    INSERT INTO tb_cliente (
        id_clie, cpf, dt_cadastro, nm_clie, dt_nasc, genero, telefone, email, tb_endereco_id_end, tb_plano_id_plano
    ) VALUES (
        p_id_clie, p_cpf, p_dt_cadastro, p_nm_clie, p_dt_nasc, p_genero, p_telefone, p_email, p_tb_endereco_id, p_tb_plano_id
    );

COMMIT;

    DBMS_OUTPUT.PUT_LINE('Cliente inserido com sucesso: ' || p_id_clie);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Erro: CPF, telefone ou email já cadastrados.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro desconhecido: ' || SQLERRM);
END inserir_cliente;
/




--INSERT TB_REDE_CREDENCIADA

CREATE OR REPLACE PROCEDURE inserir_rede_credenciada(
    p_id_empresa       IN VARCHAR2,
    p_cnpj             IN VARCHAR2,
    p_dt_cadastro      IN DATE,
    p_nm_empresa       IN VARCHAR2,
    p_especialidade    IN VARCHAR2,
    p_telefone         IN VARCHAR2,
    p_email            IN VARCHAR2,
    p_tb_endereco_id   IN VARCHAR2
) AS
BEGIN
    -- Valida CNPJ
    IF NOT validar_cnpj(p_cnpj) THEN
        RAISE_APPLICATION_ERROR(-20001, 'CNPJ inválido ou já existente.');
    END IF;
    
    IF NOT validar_email(p_email) THEN
        RAISE_APPLICATION_ERROR(-20002, 'E-mail inválido.');
    END IF;

    INSERT INTO tb_rede_credenciada (
        id_empresa, cnpj, dt_cadastro, nm_empresa, especialidade, telefone, email, tb_endereco_id_end
    ) VALUES (
        p_id_empresa, p_cnpj, p_dt_cadastro, p_nm_empresa, p_especialidade, p_telefone, p_email, p_tb_endereco_id
    );

COMMIT;

    DBMS_OUTPUT.PUT_LINE('Rede Credenciada inserida com sucesso: ' || p_id_empresa);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Erro: CNPJ, telefone ou email já cadastrados.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro desconhecido: ' || SQLERRM);
END inserir_rede_credenciada;
/




--INSERT TB_ATENDIMENTO

CREATE OR REPLACE PROCEDURE inserir_atendimento (
    p_id_atendimento IN tb_atendimento.id_atendimento%TYPE,
    p_dt_atendimento IN tb_atendimento.dt_atendimento%TYPE,
    p_diagnostico IN tb_atendimento.diagnostico%TYPE,
    p_tb_cliente_id_clie IN tb_atendimento.tb_cliente_id_clie%TYPE,
    p_tb_rede_credenciada_id_empresa IN tb_atendimento.tb_rede_credenciada_id_empresa%TYPE
) IS
    v_cliente_exists NUMBER;
    v_empresa_exists NUMBER;
BEGIN
    -- Verificar se o cliente existe
    SELECT COUNT(1)
    INTO v_cliente_exists
    FROM tb_cliente
    WHERE id_clie = p_tb_cliente_id_clie;

    IF v_cliente_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Cliente não encontrado: ' || p_tb_cliente_id_clie);
    END IF;

    -- Verificar se a rede credenciada existe
    SELECT COUNT(1)
    INTO v_empresa_exists
    FROM tb_rede_credenciada
    WHERE id_empresa = p_tb_rede_credenciada_id_empresa;

    IF v_empresa_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Rede credenciada não encontrada: ' || p_tb_rede_credenciada_id_empresa);
    END IF;

    INSERT INTO tb_atendimento (id_atendimento, dt_atendimento, diagnostico, 
    tb_cliente_id_clie, tb_rede_credenciada_id_empresa) 
    VALUES (p_id_atendimento, p_dt_atendimento, p_diagnostico, p_tb_cliente_id_clie,
        p_tb_rede_credenciada_id_empresa);

COMMIT;

    DBMS_OUTPUT.PUT_LINE('Atendimento inserido com sucesso: ' || p_id_atendimento);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao inserir atendimento: ' || SQLERRM);
END inserir_atendimento;
/




--TB_TRATAMENTO
CREATE OR REPLACE PROCEDURE inserir_tratamento (
    p_id_tratamento IN tb_tratamento.id_tratamento%TYPE,
    p_desc_tratamento IN tb_tratamento.desc_tratamento%TYPE,
    p_nivel_urgencia IN tb_tratamento.nivel_urgencia%TYPE,
    p_tb_atendimento_id_atendimento IN tb_tratamento.tb_atendimento_id_atendimento%TYPE
) IS
    v_atendimento_exists NUMBER;
BEGIN
    SELECT COUNT(1)
    INTO v_atendimento_exists
    FROM tb_atendimento
    WHERE id_atendimento = p_tb_atendimento_id_atendimento;

    IF v_atendimento_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Atendimento não encontrado: ' || p_tb_atendimento_id_atendimento);
    END IF;

    INSERT INTO tb_tratamento (id_tratamento,desc_tratamento, nivel_urgencia, 
    tb_atendimento_id_atendimento) 
    VALUES (p_id_tratamento, p_desc_tratamento, p_nivel_urgencia, 
    p_tb_atendimento_id_atendimento);

COMMIT;

    DBMS_OUTPUT.PUT_LINE('Tratamento inserido com sucesso: ' || p_id_tratamento);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao inserir tratamento: ' || SQLERRM);
END inserir_tratamento;
/




--INSERT TB_ASSOC_ATEND_PROC

CREATE OR REPLACE PROCEDURE inserir_assoc_atend_proc(
    p_tb_atendimento_id_atendimento IN VARCHAR2,
    p_tb_procedimento_id_proc       IN VARCHAR2
) IS
    v_atendimento_exists NUMBER;
    v_procedimento_exists NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_atendimento_exists
    FROM tb_atendimento
    WHERE id_atendimento = p_tb_atendimento_id_atendimento;

    SELECT COUNT(*)
    INTO v_procedimento_exists
    FROM tb_procedimento
    WHERE id_proc = p_tb_procedimento_id_proc;
    
    IF v_atendimento_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Erro: Atendimento não encontrado.');
    ELSIF v_procedimento_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Erro: Procedimento não encontrado.');
    END IF;

    INSERT INTO tb_assoc_atend_proc (
        tb_atendimento_id_atendimento, tb_procedimento_id_proc
    ) VALUES (
        p_tb_atendimento_id_atendimento, p_tb_procedimento_id_proc
    );

COMMIT;

    DBMS_OUTPUT.PUT_LINE('Associação inserida com sucesso.');

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Erro: Associação já existente.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao inserir associação: ' || SQLERRM);
END inserir_assoc_atend_proc;
/





-- PROCEDURES PARA UPDATE NAS TABELAS
--Apenas não inserimos update na tabela associativa por risco no negócio, devido
--ela resultar do id de outras duas tabelas. Se o usuário quiser alterar uma associação deverá deletar
--a antiga e incluir uma nova.




--UPDATE ATUALIZAR PLANO
CREATE OR REPLACE PROCEDURE atualizar_plano(
    p_id_plano  IN  VARCHAR2,
    p_nm_plano  IN  VARCHAR2,
    p_tp_plano  IN  VARCHAR2,
    p_valor_plano IN NUMBER
)AS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM tb_plano
    WHERE id_plano = p_id_plano;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Plano não encontrado.');
    END IF;
    
    UPDATE tb_plano SET
        nm_plano = p_nm_plano,
        tp_plano = p_tp_plano,
        valor_plano = p_valor_plano
    WHERE id_plano = p_id_plano;

COMMIT;

    DBMS_OUTPUT.PUT_LINE('Plano atualizado com sucesso: ' || p_id_plano);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Erro: Plano não encontrado.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro desconhecido: ' || SQLERRM);
END atualizar_plano;
/





--UPDATE TB_CLIENTE
CREATE OR REPLACE PROCEDURE atualizar_cliente(
    p_id_clie          IN VARCHAR2,
    p_cpf              IN VARCHAR2,
    p_dt_cadastro      IN DATE,
    p_nm_clie          IN VARCHAR2,
    p_dt_nasc          IN DATE,
    p_genero           IN CHAR,
    p_telefone         IN VARCHAR2,
    p_email            IN VARCHAR2,
    p_tb_endereco_id   IN VARCHAR2,
    p_tb_plano_id      IN VARCHAR2
) AS
    v_count NUMBER;
BEGIN
    
    SELECT COUNT(*)
    INTO v_count
    FROM tb_cliente
    WHERE id_clie = p_id_clie;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Cliente não encontrado.');
    END IF;

    
    IF NOT validar_cpf(p_cpf) THEN
        RAISE_APPLICATION_ERROR(-20001, 'CPF inválido ou já existente.');
    END IF;

    IF NOT validar_email(p_email) THEN
        RAISE_APPLICATION_ERROR(-20002, 'E-mail inválido.');
    END IF;
    
    UPDATE tb_cliente
    SET cpf                = p_cpf,
        dt_cadastro        = p_dt_cadastro,
        nm_clie            = p_nm_clie,
        dt_nasc            = p_dt_nasc,
        genero             = p_genero,
        telefone           = p_telefone,
        email              = p_email,
        tb_endereco_id_end = p_tb_endereco_id,
        tb_plano_id_plano  = p_tb_plano_id
    WHERE id_clie = p_id_clie;

COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Cliente atualizado com sucesso: ' || p_id_clie);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Erro: Cliente não encontrado.');
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Erro: CPF, telefone ou email já cadastrados.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro desconhecido: ' || SQLERRM);
END atualizar_cliente;





-- UPDATE TB_REDE_CREDENCIADA

CREATE OR REPLACE PROCEDURE atualizar_rede_credenciada(
    p_id_empresa       IN VARCHAR2,
    p_cnpj             IN VARCHAR2,
    p_dt_cadastro      IN DATE,
    p_nm_empresa       IN VARCHAR2,
    p_especialidade    IN VARCHAR2,
    p_telefone         IN VARCHAR2,
    p_email            IN VARCHAR2,
    p_tb_endereco_id   IN VARCHAR2
) AS
    v_count NUMBER;
BEGIN
    
    SELECT COUNT(*)
    INTO v_count
    FROM tb_rede_credenciada
    WHERE id_empresa = p_id_empresa;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Rede Credenciada não encontrada.');
    END IF;

    -- Valida CNPJ
    IF NOT validar_cnpj(p_cnpj) THEN
        RAISE_APPLICATION_ERROR(-20001, 'CNPJ inválido ou já existente.');
    END IF;
    
    IF NOT validar_email(p_email) THEN
        RAISE_APPLICATION_ERROR(-20002, 'E-mail inválido.');
    END IF;
    
    UPDATE tb_rede_credenciada
    SET cnpj               = p_cnpj,
        dt_cadastro        = p_dt_cadastro,
        nm_empresa         = p_nm_empresa,
        especialidade      = p_especialidade,
        telefone           = p_telefone,
        email              = p_email,
        tb_endereco_id_end = p_tb_endereco_id
    WHERE id_empresa = p_id_empresa;

COMMIT;

    DBMS_OUTPUT.PUT_LINE('Rede Credenciada atualizada com sucesso: ' || p_id_empresa);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Erro: Rede Credenciada não encontrada.');
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Erro: CNPJ, telefone ou email já cadastrados.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro desconhecido: ' || SQLERRM);
END atualizar_rede_credenciada;
/





--UPDATE TB_ATENDIMENTO
CREATE OR REPLACE PROCEDURE atualizar_atendimento (
    p_id_atendimento IN tb_atendimento.id_atendimento%TYPE,
    p_dt_atendimento IN tb_atendimento.dt_atendimento%TYPE,
    p_diagnostico IN tb_atendimento.diagnostico%TYPE,
    p_tb_cliente_id_clie IN tb_atendimento.tb_cliente_id_clie%TYPE,
    p_tb_rede_credenciada_id_empresa IN tb_atendimento.tb_rede_credenciada_id_empresa%TYPE
) IS
    v_cliente_exists NUMBER;
    v_empresa_exists NUMBER;
BEGIN
    
    SELECT COUNT(1)
    INTO v_cliente_exists
    FROM tb_cliente
    WHERE id_clie = p_tb_cliente_id_clie;

    IF v_cliente_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Cliente não encontrado: ' || p_tb_cliente_id_clie);
    END IF;

    SELECT COUNT(1)
    INTO v_empresa_exists
    FROM tb_rede_credenciada
    WHERE id_empresa = p_tb_rede_credenciada_id_empresa;

    IF v_empresa_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Rede credenciada não encontrada: ' || p_tb_rede_credenciada_id_empresa);
    END IF;

    UPDATE tb_atendimento
    SET dt_atendimento = p_dt_atendimento,
        diagnostico = p_diagnostico,
        tb_cliente_id_clie = p_tb_cliente_id_clie,
        tb_rede_credenciada_id_empresa = p_tb_rede_credenciada_id_empresa
    WHERE id_atendimento = p_id_atendimento;

COMMIT;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Atendimento não encontrado: ' || p_id_atendimento);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Atendimento atualizado com sucesso: ' || p_id_atendimento);
    END IF;


EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao atualizar atendimento: ' || SQLERRM);
END atualizar_atendimento;
/





--UPDATE TB_ENDERECO
CREATE OR REPLACE PROCEDURE atualizar_endereco (
    p_id_end IN tb_endereco.id_end%TYPE,
    p_cep IN tb_endereco.cep%TYPE,
    p_logradouro IN tb_endereco.logradouro%TYPE,
    p_num_end IN tb_endereco.num_end%TYPE,
    p_compl_end IN tb_endereco.compl_end%TYPE,
    p_bairro IN tb_endereco.bairro%TYPE,
    p_cidade IN tb_endereco.cidade%TYPE,
    p_uf IN tb_endereco.uf%TYPE
) IS
BEGIN
    -- Atualizar o registro na tabela tb_endereco
    UPDATE tb_endereco
    SET cep = p_cep,
        logradouro = p_logradouro,
        num_end = p_num_end,
        compl_end = p_compl_end,
        bairro = p_bairro,
        cidade = p_cidade,
        uf = p_uf
    WHERE id_end = p_id_end;

COMMIT;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Endereço não encontrado: ' || p_id_end);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Endereço atualizado com sucesso: ' || p_id_end);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao atualizar endereço: ' || SQLERRM);
END atualizar_endereco;
/




--UPDATE TB_PROCEDIMENTO

CREATE OR REPLACE PROCEDURE atualizar_procedimento (
    p_id_proc IN tb_procedimento.id_proc%TYPE,
    p_nm_proc IN tb_procedimento.nm_proc%TYPE,
    p_tp_proc IN tb_procedimento.tp_proc%TYPE,
    p_custo_medio IN tb_procedimento.custo_medio%TYPE,
    p_complexidade IN tb_procedimento.complexidade%TYPE
) IS
BEGIN
    -- Atualizar o registro na tabela tb_procedimento
    UPDATE tb_procedimento
    SET nm_proc = p_nm_proc,
        tp_proc = p_tp_proc,
        custo_medio = p_custo_medio,
        complexidade = p_complexidade
    WHERE id_proc = p_id_proc;

COMMIT;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Procedimento não encontrado: ' || p_id_proc);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Procedimento atualizado com sucesso: ' || p_id_proc);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao atualizar procedimento: ' || SQLERRM);
END atualizar_procedimento;
/




--UPDATE TB_TRATAMENTO

CREATE OR REPLACE PROCEDURE atualizar_tratamento (
    p_id_tratamento IN tb_tratamento.id_tratamento%TYPE,
    p_desc_tratamento IN tb_tratamento.desc_tratamento%TYPE,
    p_nivel_urgencia IN tb_tratamento.nivel_urgencia%TYPE,
    p_tb_atendimento_id_atendimento IN tb_tratamento.tb_atendimento_id_atendimento%TYPE
) IS
    v_atendimento_exists NUMBER;
BEGIN
    
    SELECT COUNT(1)
    INTO v_atendimento_exists
    FROM tb_atendimento
    WHERE id_atendimento = p_tb_atendimento_id_atendimento;


    IF v_atendimento_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Atendimento não encontrado: ' || p_tb_atendimento_id_atendimento);
    END IF;

    UPDATE tb_tratamento
    SET desc_tratamento = p_desc_tratamento,
        nivel_urgencia = p_nivel_urgencia,
        tb_atendimento_id_atendimento = p_tb_atendimento_id_atendimento
    WHERE id_tratamento = p_id_tratamento;

COMMIT;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Tratamento não encontrado: ' || p_id_tratamento);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Tratamento atualizado com sucesso: ' || p_id_tratamento);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao atualizar tratamento: ' || SQLERRM);
END atualizar_tratamento;
/






--PROCEDURES PARA DELETAR DADOS





-- DELETE TB_CLIENTE

CREATE OR REPLACE PROCEDURE deletar_cliente(
    p_id_clie IN VARCHAR2
) IS
BEGIN
    -- Excluir o cliente
    DELETE FROM tb_cliente WHERE id_clie = p_id_clie;
	COMMIT;


    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Cliente não encontrado.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Cliente excluído com sucesso.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao excluir cliente: ' || SQLERRM);
END deletar_cliente;
/




--DELETE TB_PLANO

CREATE OR REPLACE PROCEDURE deletar_plano(
    p_id_plano IN VARCHAR2
) IS
BEGIN
    -- Excluir o plano 
    DELETE FROM tb_plano WHERE id_plano = p_id_plano;
	COMMIT;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Plano não encontrado.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Plano excluído com sucesso.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao excluir plano : ' || SQLERRM);
END deletar_plano;
/




--DELETE TB_REDE_CRED

CREATE OR REPLACE PROCEDURE deletar_rede_credenciada(
    p_id_empresa IN VARCHAR2
) IS
BEGIN
     
    DELETE FROM tb_rede_credenciada WHERE id_empresa = p_id_empresa;
	COMMIT;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Empresa não encontrada.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('empresa excluída com sucesso.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao excluir empresa: ' || SQLERRM);
END deletar_rede_credenciada;
/




--DELETE ENDERECO
CREATE OR REPLACE PROCEDURE deletar_endereco(
    p_id_endereco IN VARCHAR2
) IS
BEGIN
     
    DELETE FROM tb_endereco WHERE id_end= p_id_endereco;
	COMMIT;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Endereço não encontrado.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Endereço excluído com sucesso.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao excluir endereço: ' || SQLERRM);
END deletar_endereco;
/




--DELETE TB_PROCEDIMENTO
CREATE OR REPLACE PROCEDURE deletar_procedimento (
    p_id_procedimento IN VARCHAR2
) IS
BEGIN
     
    DELETE FROM tb_procedimento WHERE id_proc = p_id_procedimento ;
	COMMIT;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('procedimento não encontrado.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('procedimento excluído com sucesso.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao excluir procedimento : ' || SQLERRM);
END deletar_procedimento ;
/




--DELETE TB_TRATAMENTO
CREATE OR REPLACE PROCEDURE deletar_tratamento (
    p_id_tratamento IN VARCHAR2
) IS
BEGIN
     
    DELETE FROM tb_tratamento WHERE id_tratamento = p_id_tratamento;
	COMMIT;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('tratamento não encontrado.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('tratamento excluído com sucesso.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao excluir tratamento : ' || SQLERRM);
END deletar_tratamento ;
/




--DELETE TB_ATENDIMENTO
CREATE OR REPLACE PROCEDURE deletar_atendimento (
    p_id_atendimento IN VARCHAR2
) IS
BEGIN
     
    DELETE FROM tb_atendimento WHERE id_atendimento = p_id_atendimento ;
	COMMIT;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('atendimento não encontrado.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('atendimento excluído com sucesso.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao excluir atendimento : ' || SQLERRM);
END deletar_atendimento ;
/





--DELETE TB_ASSOCIATIVA

CREATE OR REPLACE PROCEDURE deletar_assoc_atend_proc(
    p_tb_atendimento_id_atendimento IN VARCHAR2,
    p_tb_procedimento_id_proc       IN VARCHAR2
) IS
BEGIN
    DELETE FROM tb_assoc_atend_proc
    WHERE tb_atendimento_id_atendimento = p_tb_atendimento_id_atendimento
      AND tb_procedimento_id_proc = p_tb_procedimento_id_proc;
COMMIT;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Erro: Associação não encontrada.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Associação deletada com sucesso.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao deletar associação: ' || SQLERRM);
END deletar_assoc_atend_proc;
/



--FUNÇÃO COM JOINS E CURSOR




-- REGISTROS PARA RELATÓRIO FORMATADO
CREATE OR REPLACE TYPE relatorio_associacao_tipo AS OBJECT (
    atendimento_id VARCHAR2(20),
    procedimento_id VARCHAR2(8),
    diagnostico VARCHAR2(300),
    nm_procedimento VARCHAR2(200),
    complexidade VARCHAR2(30)
);


-- RELATÓRIO DO TIPO TABLE
CREATE OR REPLACE TYPE relatorio_associacao_tab AS TABLE OF relatorio_associacao_tipo;
/

--FUNÇÃO
CREATE OR REPLACE FUNCTION relatorio_atendimento_procedimentos
RETURN relatorio_associacao_tab PIPELINED IS
    CURSOR c_relatorio IS
        SELECT 
            ap.tb_atendimento_id_atendimento AS atendimento_id,
            ap.tb_procedimento_id_proc AS procedimento_id,
            a.diagnostico,
            p.nm_proc AS nm_procedimento,
            p.complexidade
        FROM tb_assoc_atend_proc ap
        JOIN tb_atendimento a ON ap.tb_atendimento_id_atendimento = a.id_atendimento
        JOIN tb_procedimento p ON ap.tb_procedimento_id_proc = p.id_proc;
BEGIN
    FOR reg IN c_relatorio LOOP
        PIPE ROW(relatorio_associacao_tipo(
            reg.atendimento_id,
            reg.procedimento_id,
            reg.diagnostico,
            reg.nm_procedimento,
            reg.complexidade
        ));
    END LOOP;
    RETURN;
END relatorio_atendimento_procedimentos;
/



-- SELECT DO RELATÓRIO GERADO
SELECT * FROM TABLE(relatorio_atendimento_procedimentos());





--Função para Relatório com Regra de Negócio
CREATE OR REPLACE TYPE atendimento_relatorio_linha AS OBJECT (
    cliente_id        VARCHAR2(20),
    cliente_nome      VARCHAR2(100),
    total_atendimentos NUMBER,
    total_diagnosticos NUMBER,
    rede_nome         VARCHAR2(200),
    data_atendimento  DATE
);

CREATE OR REPLACE TYPE atendimento_relatorio_tab AS TABLE OF atendimento_relatorio_linha;
/


CREATE OR REPLACE FUNCTION fn_relatorio_atendimentos (
    p_data_inicio IN DATE,
    p_data_fim IN DATE
) RETURN atendimento_relatorio_tab PIPELINED
IS
BEGIN
    FOR rec IN (
        SELECT 
            cl.id_clie AS cliente_id,
            cl.nm_clie AS cliente_nome,
            COUNT(a.id_atendimento) AS total_atendimentos,
            COUNT(DISTINCT a.diagnostico) AS total_diagnosticos,
            rc.nm_empresa AS rede_nome,
            a.dt_atendimento AS data_atendimento
        FROM 
            tb_atendimento a
            INNER JOIN tb_cliente cl ON a.tb_cliente_id_clie = cl.id_clie
            INNER JOIN tb_rede_credenciada rc ON a.tb_rede_credenciada_id_empresa = rc.id_empresa
        WHERE 
            a.dt_atendimento BETWEEN p_data_inicio AND p_data_fim
        GROUP BY 
            cl.id_clie, cl.nm_clie, rc.nm_empresa, a.dt_atendimento
        ORDER BY 
            a.dt_atendimento DESC, total_atendimentos DESC
    ) LOOP
        
        PIPE ROW (atendimento_relatorio_linha(
            rec.cliente_id,
            rec.cliente_nome,
            rec.total_atendimentos,
            rec.total_diagnosticos,
            rec.rede_nome,
            rec.data_atendimento
        ));
    END LOOP;

    RETURN;
END fn_relatorio_atendimentos;
/

--resultado relatório
SELECT * 
FROM TABLE(fn_relatorio_atendimentos(DATE '2023-01-01', DATE '2023-12-31'));


 