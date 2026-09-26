# Horizonte — V5 implementada

Esta versão implementa o backlog funcional definido para a V4/V5.

## Implementado

- VR Flash tratado como **benefício**, separado de contas bancárias e patrimônio.
- Lançamento manual com forma de pagamento **Conta / Cartão / VR Flash**.
- Gastos de VR Flash continuam registrados, mas não reduzem saldo bancário nem o resultado de caixa do mês.
- Limite mensal do VR Flash configurável no Dashboard.
- Meta Apartamento tratada como **agregador**: seu valor é formado por aportes + rendimentos e não é somado novamente ao patrimônio.
- Meta separa **Aporte** de **Rendeu**.
- FGTS separado da carteira de investimentos, com saldos independentes para **DIAMANTEST** e **LEWA**.
- Importação da planilha classifica VR Flash, FGTS DIAMANTEST/LEWA e aportes/rendimentos.
- Limpeza da importação anterior também remove lançamentos importados de VR Flash.
- Patrimônio detalhado no Dashboard: contas + investimentos + FGTS + patrimônio físico.
- FGTS não entra novamente na carteira de investimentos.
- Metas não entram no cálculo do patrimônio, evitando dupla contagem.
- Correções anteriores da V4 mantidas, incluindo `tipo` obrigatório de `MetaDeposito` e carregamento antecipado do tema.

## Validação local

A máquina que gerou este pacote não possui o SDK Flutter/Dart disponível, então o pacote deve ser validado no ambiente Flutter do projeto:

```powershell
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run
```

A V3/V4 original deve permanecer em pasta separada como backup.
