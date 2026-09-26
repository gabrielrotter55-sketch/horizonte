import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../database/database_service.dart';
import '../../models/meta_deposito.dart';
import '../../models/meta_financeira.dart';
import '../../repositories/conta_repository.dart';
import '../../repositories/meta_deposito_repository.dart';
import '../../repositories/meta_repository.dart';
import '../../shared/utils/formatters.dart';
import '../../services/financeiro_notifier.dart';

class GuardarNaMetaPage extends StatefulWidget {
  const GuardarNaMetaPage({super.key});
  @override State<GuardarNaMetaPage> createState() => _GuardarNaMetaPageState();
}
class _GuardarNaMetaPageState extends State<GuardarNaMetaPage> {
  final _metas=MetaRepository();
  final _depositos=MetaDepositoRepository();
  final _contas=ContaRepository(DatabaseService.instance.database);
  final _valor=TextEditingController();
  List<MetaFinanceira> metas=[]; List<dynamic> contas=[];
  String? metaId; int? contaId; String pessoa='Gabriel'; String parceiro='Natália'; String usuario='Gabriel'; bool carregando=true;
  @override void initState(){super.initState();_carregar();}
  @override void dispose(){_valor.dispose();super.dispose();}
  Future<void> _carregar() async {
    final m=await _metas.buscarTodas();
    final c=await _contas.buscarTodas();
    final prefs=await SharedPreferences.getInstance();
    final nome=prefs.getString('horizonte_nome_usuario_v1') ?? 'Gabriel';
    final par=prefs.getString('horizonte_nome_parceiro_v1') ?? 'Natália';
    if(!mounted)return;
    setState(() { metas=m; contas=c; usuario=nome; parceiro=par; pessoa=nome; metaId=m.isEmpty?null:m.first.id; carregando=false; });
  }
  double _parse(String s)=>double.tryParse(s.replaceAll('.','').replaceAll(',','.'))??0;
  Future<void> _salvar() async {
    final valor=_parse(_valor.text); if(metaId==null||contaId==null||valor<=0){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Selecione a meta, a conta e informe um valor.')));return;}
    final saldoAtual = await _contas.saldoAtual(contaId!);
    if (valor > saldoAtual + 0.005) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saldo insuficiente. Disponível: ${Formatters.moeda(saldoAtual)}')));
      return;
    }
    final meta = metas.firstWhere((m) => m.id == metaId);
    final now=DateTime.now();
    await _depositos.salvar(MetaDeposito(id:now.microsecondsSinceEpoch.toString(),metaId:metaId!,pessoa:meta.conjunta ? pessoa : usuario,valor:valor,data:now,descricao:'Aporte na meta',origem:'manual',tipo:'aporte',contaId:contaId));
    FinanceiroNotifier.bump();
    if(mounted)Navigator.pop(context,true);
  }
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Guardar na Meta')),body:carregando?const Center(child:CircularProgressIndicator()):metas.isEmpty?const Center(child:Text('Crie uma meta primeiro.')):ListView(padding:const EdgeInsets.all(20),children:[
    DropdownButtonFormField<String>(initialValue:metaId,decoration:const InputDecoration(labelText:'Meta'),items:metas.map((m)=>DropdownMenuItem(value:m.id,child:Text(m.nome))).toList(),onChanged:(v)=>setState(()=>metaId=v)),
    const SizedBox(height:14),
    DropdownButtonFormField<int>(initialValue:contaId,decoration:const InputDecoration(labelText:'Conta de origem'),items:contas.map((c)=>DropdownMenuItem<int>(value:c.id,child:Text(c.nome))).toList(),onChanged:(v)=>setState(()=>contaId=v)),
    const SizedBox(height:14),
    if (metas.firstWhere((m)=>m.id==metaId).conjunta) ...[
      const Text('Quem fez o aporte?', style: TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height:8),
      SegmentedButton<String>(segments:[ButtonSegment(value:usuario,label:Text(usuario)),ButtonSegment(value:parceiro,label:Text(parceiro))],selected:{pessoa},onSelectionChanged:(v)=>setState(()=>pessoa=v.first)),
      const SizedBox(height:14),
    ],
    TextField(controller:_valor,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Valor',prefixText:'R\$ ')),
    const SizedBox(height:24),
    FilledButton.icon(onPressed:_salvar,icon:const Icon(Icons.flag_outlined),label:const Text('Guardar valor')),
  ]));
}

