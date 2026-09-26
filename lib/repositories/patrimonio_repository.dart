import '../database/database_service.dart';
import 'conta_repository.dart';
import 'fgts_repository.dart';
import 'investimento_repository.dart';
import 'beneficio_repository.dart';
import 'patrimonio_fisico_repository.dart';
import 'meta_repository.dart';

class PatrimonioResumo {
  final double financeiro;
  final double investimentos;
  final double fgts;
  final double fisico;
  final double beneficios;
  final double metas;

  const PatrimonioResumo({
    required this.financeiro,
    required this.investimentos,
    required this.fgts,
    required this.fisico,
    required this.beneficios,
    required this.metas,
  });

  double get total => financeiro + investimentos + fgts + fisico + beneficios + metas;
}

class PatrimonioRepository {
  final ContaRepository contaRepository;
  final InvestimentoRepository investimentoRepository;
  final PatrimonioFisicoRepository fisicoRepository;
  final FgtsRepository fgtsRepository;
  final BeneficioRepository beneficioRepository;
  final MetaRepository metaRepository;

  PatrimonioRepository()
      : contaRepository = ContaRepository(DatabaseService.instance.database),
        investimentoRepository = InvestimentoRepository(),
        fisicoRepository = PatrimonioFisicoRepository(),
        fgtsRepository = FgtsRepository(),
        beneficioRepository = BeneficioRepository(),
        metaRepository = MetaRepository();

  Future<double> financeiro() => contaRepository.patrimonioTotal();

  Future<double> investimentos() async {
    final itens = await investimentoRepository.buscarTodas();
    final usd = await investimentoRepository.cotacaoDolar();
    return itens
        .where((item) => item.tipo.toUpperCase() != 'FGTS')
        .fold<double>(
          0,
          (total, item) => total + (item.internacional ? item.valorAtual * usd : item.valorAtual),
        );
  }

  Future<FgtsSaldo> fgts() => fgtsRepository.buscar();

  Future<double> fisicoLiquido() => fisicoRepository.patrimonioLiquidoTotal();

  Future<PatrimonioResumo> resumo() async {
    final valores = await Future.wait<dynamic>([
      financeiro(),
      investimentos(),
      fgts(),
      fisicoLiquido(),
      beneficioRepository.resumoMes(),
      _totalMetas(),
    ]);
    final fgtsSaldo = valores[2] as FgtsSaldo;
    final beneficio = valores[4] as BeneficioResumo;
    final metas = valores[5] as double;
    return PatrimonioResumo(
      financeiro: valores[0] as double,
      investimentos: valores[1] as double,
      fgts: fgtsSaldo.total,
      fisico: valores[3] as double,
      beneficios: beneficio.saldoAtual,
      metas: metas,
    );
  }

  Future<double> _totalMetas() async {
    final itens = await metaRepository.buscarTodas();
    return itens.fold<double>(0, (total, meta) => total + meta.acumulado);
  }

  Future<double> total() async => (await resumo()).total;
}
