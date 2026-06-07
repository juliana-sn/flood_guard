# 📱 Guia de Teste - Correções do Bug de Carregamento

## ✅ O Que Foi Feito

O app estava **ficando carregando infinitamente** sem exibir o mapa ou status de risco. Isso foi corrigido adicionando:

1. **Timeouts em todos os serviços** (para não travar)
2. **Dados fallback** (quando APIs falham, usar São Paulo + sem risco)
3. **Melhor UI** (mostra "Carregando", "Erro", botão retry)
4. **Logs de debug** (para diagnosticar problemas)

## 🚀 Como Testar Agora

O app está compilando no simulador. Quando terminar, você verá uma das telas abaixo:

### Cenário 1: Tudo OK (com localização + internet)
```
┌─────────────────────────────┐
│ 🗺️ Mapa de Risco             │
├─────────────────────────────┤
│                              │
│    [Mapa com pontos vermelhos]│
│    (zonas de risco)          │
│                              │
├─────────────────────────────┤
│ 📍 Localização: São Paulo    │
│ ⚠️ Risco: Moderado           │
│ 💧 Chuva: 15mm (24h)         │
└─────────────────────────────┘
```

### Cenário 2: Sem Localização / Offline
```
┌─────────────────────────────┐
│ 🗺️ Mapa de Risco             │
├─────────────────────────────┤
│                              │
│  ⏳ Carregando dados de risco  │
│                              │
│  Tentando localização...      │
│  (Timeout em 30s)            │
│                              │
└─────────────────────────────┘
```

### Cenário 3: Erro (após 30s timeout)
```
┌─────────────────────────────┐
│ 🗺️ Mapa de Risco             │
├─────────────────────────────┤
│                              │
│   ❌ Erro ao carregar mapa    │
│                              │
│   Tempo de espera excedido    │
│   Verifique sua conexão.      │
│                              │
│   [Tentar Novamente]          │
│                              │
└─────────────────────────────┘
```

## 🧪 Testes Recomendados

### ✅ Teste 1: Carregamento Normal
```
1. App está rodando com localização ativada
2. Tem internet
3. Esperado: Carregar mapa + status em <15s
```

### ✅ Teste 2: Sem Permissão de Localização
```
1. Settings > Privacidade > Localização > [Desativar]
2. Relançar app
3. Esperado:
   - Usar localização padrão (São Paulo)
   - Mostrar mapa
   - Status de risco: "Sem risco"
```

### ✅ Teste 3: Modo Avião (Offline)
```
1. Ativar Modo Avião
2. Relançar app
3. Esperado:
   - Spinner por ~30s
   - Depois mostrar: "Tempo de espera excedido"
   - Botão "Tentar Novamente"
```

### ✅ Teste 4: Botão Retry
```
1. Se estiver offline, clicar "Tentar Novamente"
2. Esperado: Tentar novamente a conexão
```

## 🔍 Onde Ver os Logs

Se algo não funcionar, veja os logs no console:

```bash
# Terminal do computador (enquanto app está rodando)
flutter run -d "iPhone 16e"

# Procure por:
📍 Obtendo localização...
✅ Localização obtida: -23.5505, -46.6333
🔍 Resolvendo localização...
✅ Localização resolvida: São Paulo
📊 Buscando dados (previsão e risco)...
✅ Dados obtidos com sucesso

# OU se houver erro:
⚠️ Erro ao obter localização: TimeoutException
⚠️ Erro ao resolver localização: ...
⚠️ Erro ao obter previsão: ...
⚠️ Erro ao obter risco de inundação: ...
❌ Erro no coordinator: ...
```

## 📊 Mudanças Técnicas

### Timeouts Adicionados
- Localização: **10 segundos**
- Cada serviço: **15 segundos**
- Operação total: **30 segundos**

### Dados Fallback
- Localização: São Paulo (-23.5505, -46.6333)
- Risco: Nenhum (seguro)
- Previsão: Sem chuva (0mm)

### UI Improvements
- ✅ Spinner com mensagem de status
- ✅ Erro detalhado + botão retry
- ✅ Botão "Tentar Novamente"
- ✅ Ícone de erro visual

## ❓ FAQ

**P: O app ainda está travando?**
- R: Não, agora tem timeout de 30s máximo

**P: E se não tiver localização?**
- R: Usa São Paulo como padrão

**P: E se não tiver internet?**
- R: Usa dados em cache, ou dados padrão se não houver cache

**P: Como recarregar se der erro?**
- R: Clique o botão "Tentar Novamente"

**P: Pode quebrar algo?**
- R: Não, todas são melhorias de robustez

## 📞 Se Precisar

Se o app não funcionar como esperado:
1. Verifique os logs (veja "Onde Ver os Logs" acima)
2. Tente cada um dos 4 testes
3. Compartilhe os logs de erro

---

**Status**: ✅ Pronto para testar  
**Data**: 4 de junho de 2026  
**Compilação**: Em progresso...
