# Horizonte — Importação de planilha corrigida

Esta versão corrige o fluxo de importação da planilha.

## Alterações

- Mercado Pago e Nubank são criados automaticamente como contas reais ao abrir a tela de importação.
- O botão `Importar dados` não fica mais bloqueado pela ausência de uma conta.
- `Pix / Dinheiro` não é criado como conta.
- `VR Flash` não é criado como conta.
- `Crédito Nubank` e `Crédito Mercado Pago` continuam sendo tratados como cartões.
- Compras históricas não recebem uma conta bancária inventada; `contaId` de lançamentos históricos pode ser nulo.
- A tela de importação mostra os saldos reais das contas bancárias.
- O banco foi atualizado para schema 8 para permitir `contaId` nulo.

## Primeiro comando após extrair

No PowerShell, dentro da pasta do projeto:

```powershell
cd C:\Projetos\horizonte
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run
```

O `build_runner` é importante porque o projeto usa Drift e precisa regenerar `lib/database/app_database.g.dart` depois da alteração de nulabilidade de `contaId`.
