# Horizonte V6 — Consolidação

Esta versão consolida os ajustes levantados durante os testes da V5.

## Principais mudanças
- Investimentos não são mais recriados automaticamente na inicialização do app.
- Meta pode ser individual ou conjunta.
- Criação de meta permite informar saldos históricos iniciais de Gabriel, Natália e rendimentos sem retirar dinheiro das contas atuais.
- Aportes novos em metas podem ter uma conta de origem; esse valor passa a reduzir o saldo disponível da conta sem virar uma despesa.
- Rendimentos de metas não são atribuídos a Gabriel/Natália.
- Atalho no botão `+` para guardar dinheiro em uma meta e para abrir investimentos.
- Saldo atual do Dashboard abre Contas.
- Patrimônio total abre uma tela de composição navegável.
- FGTS ganhou tela própria e separação entre aportes e rendimentos.
- VR restante aparece como saldo do benefício e pode compor o patrimônio sem entrar no saldo bancário.
- Categorias padrão de receita e despesa passam a ser distintas.
- Contraste da tela de Faturas foi ajustado para tema escuro.
- Barra inferior foi reorganizada para que o botão `+` não fique sobre o texto de Investimentos.
- Correções de ciclo de vida/navegação da versão Runtime Corrigida foram preservadas.

## Observação
O ambiente de empacotamento não possui o SDK Flutter disponível, portanto não foi possível executar `flutter analyze`/`flutter run` nesta sessão. A versão deve ser testada no mesmo ambiente Flutter usado no desenvolvimento antes de substituir a versão anterior.
