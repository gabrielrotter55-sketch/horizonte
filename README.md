# Horizonte — V2

Aplicativo pessoal de organização financeira com a proposta **clareza financeira sem culpa**.

## O que a V2 entrega

- Dashboard com patrimônio financeiro + investimentos + patrimônio físico líquido.
- Contas com edição do saldo inicial e ações de editar/excluir.
- Lançamentos com criação rápida de despesa, receita e transferência.
- Transferências entre contas com criação, edição e exclusão.
- Categorias com uma base inicial de receitas recorrentes.
- Metas com progresso, prazo e aportes protegidos contra valores inválidos.
- Patrimônio físico para moto, carro, imóvel e outros bens, incluindo financiamento e saldo devedor.
- Carteira de investimentos organizada por classe, instituição e moeda.
- Carteira inicial baseada nos dados informados do Investidor10.
- Instituições personalizadas para o seu uso: Nubank, Nomad, Binance e Mercado Pago.
- Cotação USD/BRL digitada manualmente e conversão automática dos ativos internacionais para reais.
- Investimentos da planilha não são duplicados na carteira: a planilha permanece como fonte de histórico, metas e reserva de emergência.
- Meta do apartamento preserva o valor acumulado de EU E MO da planilha.
- Importação Excel com prévia, deduplicação, limpeza da importação anterior e controle explícito do saldo inicial.
- Compras no cartão não reduzem diretamente o saldo da conta; o efeito ocorre no pagamento da fatura.
- Material 3 e arquitetura separada por UI, ViewModel, repositórios e serviços.

## Fonte da carteira de investimentos

O Horizonte trata o Investidor10 como a fonte de conferência da carteira. O Investidor10 permite acompanhar classes como ações, FIIs, renda fixa, ETFs, stocks e criptomoedas e registrar posições manualmente. 

No Horizonte, os dados são mantidos localmente para que você consiga atualizar o preço atual e acompanhar o patrimônio sem depender de uma conexão bancária.

## Executar

```powershell
cd C:\Projetos\horizonte
flutter pub get
dart run build_runner build
flutter analyze
flutter run
```

Depois de abrir:

1. Confira **Investimentos** e ajuste a cotação USD.
2. Confira **Metas** e o acumulado do apartamento.
3. Em **Contas**, revise o saldo inicial de cada conta.
4. Se for importar a planilha, use **Configurações → Importar planilha** e revise a prévia antes de confirmar.

> Observação: o ambiente usado para montar este pacote não possui Flutter/Dart instalado, então a validação final deve ser feita no seu computador com `flutter analyze` e `flutter run`.
