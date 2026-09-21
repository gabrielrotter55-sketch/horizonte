
# Horizonte V2 Profissional

Horizonte — clareza financeira sem culpa.

## V2 inclui
- Dashboard com saldo atual, resultado do mês, próximo compromisso e patrimônio total compacto.
- Contas e compromissos: mensal, anual e esporádico.
- Registro de pagamento de compromisso como lançamento.
- Metas compartilhadas com depósitos individuais por pessoa.
- Investimentos com Nubank, Nomad, Binance e cotação USD manual.
- Patrimônio físico e financiamentos.
- Importação histórica da planilha sem duplicar investimentos.
- Configurações completas, perfil e modo de exibição Claro / Escuro / Automático.
- Material 3 e tema escuro persistido localmente.

## Primeira execução

```powershell
cd C:\Projetos\horizonte
flutter pub get
dart run build_runner build
flutter analyze
flutter run
```

O projeto deve ser validado localmente com `flutter analyze` e testado no aparelho/emulador.
