# Flood Guard — Documento de Design

## Visão Geral

O Flood Guard é um aplicativo de monitoramento hidrológico em tempo real que utiliza inteligência orbital para prever e alertar sobre riscos de inundação. O design foca em clareza, urgência controlada e confiabilidade tecnológica.

## Paleta de Cores

- `#FF7E7B` — Coral Vibrante: ações principais e alertas críticos.
- `#FFAD59` — Laranja Suave: estados de alerta moderado.
- `#FFFFFF` — Branco: fundo principal para clareza.
- `#313A51` — Navy Profundo: texto, ícones e elementos de suporte.
- `#00C853` — Verde: indica segurança e normalidade.
- `#E0E0E0` — Cinza Claro: bordas e divisores.

## Tipografia

- Família: Plus Jakarta Sans
- Peso Bold: 700
- Peso Semibold: 600
- Peso Regular: 400

Escalas principais:
- `headline-lg`: 32px
- `headline-md`: 24px
- `body-md`: 16px
- `label-sm`: 12px

## Forma

- Roundness: `rounded-full / rounded-3xl` — bordas volumosas e amigáveis.

## Espaçamento

- Margem mobile: 24px
- Gutter: 16px

## Componentes

- Botões primários: fundo coral vibrante, texto branco, totalmente arredondado.
- Cards de status: alto contraste, sombras suaves e leitura imediata.
- Navegação inferior: fundo branco com destaque de estado ativo em containers de cor secundária.

## Telas

### 1. Login

- Logotipo "Flood Guard" centralizado.
- Título principal: "Acesse sua conta".
- Campos de email e senha com ícones.
- Botão "Entrar" em coral vibrante.
- Links de recuperação de senha e nova conta.
- Autenticação social com Google e Apple.

### 2. Cadastro

- Título "Criar Conta" com peso alto.
- Campos: Nome Completo, E-mail, Senha, Confirmação de Senha.
- Placeholders claros.
- Botão "Cadastrar" com ícone de seta.
- Rodapé gráfico em forma de onda suave.

### 3. Mapa de Risco

- Mapa digital com polígonos de calor.
- Legenda flutuante explicando cores.
- Bottom sheet persistente com status de alagamento.
- Navegação inferior com Mapa, Alertas e Perfil.

### 4. Central de Alerta

- Cards coloridos para estados de segurança.
- Botão de emergência para Defesa Civil (199).
- Feed visual que mostra chuva em tempo real.
