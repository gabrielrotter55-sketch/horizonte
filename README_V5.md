# Horizonte — V5

V5 consolidada do projeto Horizonte, mantendo as correções da V4 e incorporando o backlog funcional já definido.

## Incluído nesta V5

- Dashboard com patrimônio total em destaque.
- Resultado, receitas e despesas do mês em resumo compacto.
- Acessos rápidos para Contas, Lançamentos, Cartões, Faturas, Categorias, Investimentos e Metas.
- Lançamentos agrupados por mês, com edição, exclusão e criação preservadas.
- Compras no cartão não exigem conta bancária e não reduzem o saldo da conta.
- Ao registrar uma compra no cartão, a fatura correspondente ao ciclo de fechamento é criada automaticamente.
- Faturas com atual, próxima fatura e histórico.
- Pagamento de fatura reduz o saldo da conta utilizada e reduz a utilização do cartão.
- Transferências entre contas com origem, destino, valor, data e descrição.
- Saldo calculado como saldo inicial + receitas − despesas − pagamentos de fatura − transferências enviadas + transferências recebidas.
- Contas, Cartões, Categorias, Investimentos, Metas, Compromissos e Patrimônio físico mantidos.
- Importação de planilha e correções do fluxo de importação mantidas.
- Depósitos de metas manual/importado com `tipo: aporte`.
- Tema Claro / Escuro / Automático carregado antes do `runApp`, evitando a reconstrução precoce que causava a tela vermelha do Flutter.

## Validação

```powershell
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run
```

A V5 é uma cópia independente. Não sobrescreva sua V3/V4.
