# Horizonte V16 — Segurança e Alocação

Base: Horizonte V15 source.

## Implementado nesta entrega
- Backup/restauração em arquivo `.hzbackup` via seletor de arquivos do Android.
- Backup inclui tabelas Drift e todas as preferências do SharedPreferences.
- Validação de formato/versão antes da restauração.
- Tela Configurações > Backup e restauração.
- Assistente de Alocação com percentuais configuráveis e validação de 100%.
- Campo para informar o valor do próximo aporte e cálculo proporcional do rebalanceamento.
- Sinalização de classes abaixo do alvo e possíveis ativos cadastrados.
- Agrupamento de FGTS com Metas.
- Inclusão do FGTS no total do agrupamento sem alterar o objetivo da meta.
- Versão atualizada para 2.2.0+5.

## Validação local obrigatória
No Windows com Flutter instalado:

```powershell
flutter clean
flutter pub get
flutter analyze
flutter build apk --release
```

A entrega não deve ser instalada no telefone antes de `flutter analyze` terminar sem issues e o APK ser testado com dados fictícios + backup/restauração.
