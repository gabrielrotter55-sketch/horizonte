import '../database/database_service.dart';
import 'conta_repository.dart';
import 'investimento_repository.dart';
import 'patrimonio_fisico_repository.dart';

class PatrimonioRepository {
  final ContaRepository contaRepository;
  final InvestimentoRepository investimentoRepository;
  final PatrimonioFisicoRepository fisicoRepository;

  PatrimonioRepository()
      : contaRepository = ContaRepository(
          DatabaseService.instance.database,
        ),
        investimentoRepository = InvestimentoRepository(),
        fisicoRepository = PatrimonioFisicoRepository();

  Future<double> financeiro() => contaRepository.patrimonioTotal();

  Future<double> investimentos() async {
    final itens = await investimentoRepository.buscarTodas();
    final usd = await investimentoRepository.cotacaoDolar();
    return itens.fold<double>(
      0,
      (total, item) => total + (item.internacional ? item.valorAtual * usd : item.valorAtual),
    );
  }

  Future<double> fisicoLiquido() => fisicoRepository.patrimonioLiquidoTotal();

  Future<double> total() async {
    final patrimonioFinanceiro = await financeiro();
final totalInvestimentos = await investimentos();
final fisico = await fisicoLiquido();

return patrimonioFinanceiro + totalInvestimentos + fisico;
  }
}
