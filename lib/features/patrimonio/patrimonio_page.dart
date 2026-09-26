import 'package:flutter/material.dart';
import '../../repositories/fgts_repository.dart';
import '../../repositories/patrimonio_repository.dart';
import '../../shared/utils/formatters.dart';
import '../contas/pages/contas_page.dart';
import '../investimentos/investimentos_page.dart';
import '../metas/metas_page.dart';
import '../patrimonio_fisico/patrimonio_fisico_page.dart';
import 'vr_page.dart';

class PatrimonioPage extends StatefulWidget {
  const PatrimonioPage({super.key});
  @override State<PatrimonioPage> createState() => _PatrimonioPageState();
}
class _PatrimonioPageState extends State<PatrimonioPage> {
  Future<PatrimonioResumo> _carregar() => PatrimonioRepository().resumo();
  Future<void> _abrir(Widget page) async { await Navigator.push(context, MaterialPageRoute(builder: (_) => page)); if (mounted) setState(() {}); }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Patrimônio')),
    body: FutureBuilder<PatrimonioResumo>(future: _carregar(),builder:(context,snap){
      if(!snap.hasData)return const Center(child:CircularProgressIndicator()); final d=snap.data!;
      return ListView(padding:const EdgeInsets.all(16),children:[
        Card(child:Padding(padding:const EdgeInsets.all(20),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Patrimônio total'),const SizedBox(height:6),Text(Formatters.moeda(d.total),style:const TextStyle(fontSize:30,fontWeight:FontWeight.w900))]))),
        const SizedBox(height:12),
        _item('Dinheiro em contas',d.financeiro,Icons.account_balance_outlined,()=>_abrir(ContasPage())),
        _item('Investimentos',d.investimentos,Icons.show_chart_outlined,()=>_abrir(const InvestimentosPage())),
        _item('FGTS',d.fgts,Icons.savings_outlined,()=>_abrir(const FgtsPage())),
        _item('VR / benefícios',d.beneficios,Icons.card_giftcard_outlined,()=>_abrir(const VrPage())),
        _item('Metas',d.metas,Icons.flag_outlined,()=>_abrir(const MetasPage())),
        _item('Patrimônio físico',d.fisico,Icons.home_work_outlined,()=>_abrir(const PatrimonioFisicoPage())),
        const SizedBox(height:12),
      ]);
    }),
  );
  Widget _item(String title,double value,IconData icon,VoidCallback? tap)=>Card(child:ListTile(onTap:tap,leading:Icon(icon),title:Text(title),trailing:Row(mainAxisSize:MainAxisSize.min,children:[Text(Formatters.moeda(value),style:const TextStyle(fontWeight:FontWeight.w800)),if(tap!=null)const Icon(Icons.chevron_right)])));
}

class FgtsPage extends StatefulWidget {
  const FgtsPage({super.key});
  @override State<FgtsPage> createState()=>_FgtsPageState();
}
class _FgtsPageState extends State<FgtsPage>{
  final _repo=FgtsRepository();
  Future<List<FgtsMovimentacao>> _historico() => _repo.historico();

  Future<void> _registrar() async {
    final tipo=await showDialog<String>(context:context,builder:(_)=>const _FgtsTipoDialog());
    if(tipo==null||!mounted)return;
    final valor=await showDialog<double>(context:context,builder:(_)=>const _ValorFgtsDialog());
    if(valor==null||valor<=0)return;
    if(tipo=='aporte') await _repo.adicionarAporte(valor);
    if(tipo=='rendimento') await _repo.adicionarRendimento(valor);
    if(mounted)setState((){});
  }

  Future<void> _editar(FgtsMovimentacao movimento) async {
    final resultado=await showDialog<_FgtsEdicao>(context:context,builder:(_)=>_FgtsEdicaoDialog(movimento:movimento));
    if(resultado==null)return;
    await _repo.editarMovimentacao(movimento,tipo:resultado.tipo,valor:resultado.valor);
    if(mounted)setState((){});
  }

  Future<void> _excluir(FgtsMovimentacao movimento) async {
    final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(
      title:const Text('Excluir movimentação?'),
      content:Text('Excluir ${movimento.tipo == 'aporte' ? 'o aporte/depósito' : 'o rendimento'} de ${Formatters.moeda(movimento.valor)}?'),
      actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Cancelar')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Excluir'))],
    ));
    if(ok!=true)return;
    await _repo.excluirMovimentacao(movimento.id);
    if(mounted)setState((){});
  }

  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('FGTS')),
    floatingActionButton:FloatingActionButton.extended(onPressed:_registrar,icon:const Icon(Icons.add_rounded),label:const Text('Registrar movimentação')),
    body:FutureBuilder<FgtsSaldo>(future:_repo.buscar(),builder:(c,s){
      if(!s.hasData)return const Center(child:CircularProgressIndicator());
      final d=s.data!;
      return ListView(padding:const EdgeInsets.fromLTRB(16,16,16,110),children:[
        Card(child:Padding(padding:const EdgeInsets.all(20),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Saldo atual'),const SizedBox(height:6),Text(Formatters.moeda(d.total),style:const TextStyle(fontSize:30,fontWeight:FontWeight.w900))]))),
        const SizedBox(height:12),
        Card(child:Column(children:[
          ListTile(leading:const Icon(Icons.add_circle_outline),title:const Text('Aportes / depósitos'),trailing:Text(Formatters.moeda(d.aportes))),
          ListTile(leading:const Icon(Icons.trending_up),title:const Text('Rendimentos'),trailing:Text(Formatters.moeda(d.rendimentos))),
          const Divider(height:1),
          ListTile(title:const Text('Total',style:TextStyle(fontWeight:FontWeight.w800)),trailing:Text(Formatters.moeda(d.total),style:const TextStyle(fontWeight:FontWeight.w900))),
        ])),
        const SizedBox(height:16),
        const Text('Histórico de lançamentos',style:TextStyle(fontSize:18,fontWeight:FontWeight.w800)),
        const SizedBox(height:8),
        FutureBuilder<List<FgtsMovimentacao>>(future:_historico(),builder:(context,h){
          if(!h.hasData)return const Padding(padding:EdgeInsets.all(16),child:Center(child:CircularProgressIndicator()));
          final itens=h.data!;
          if(itens.isEmpty)return const Card(child:Padding(padding:EdgeInsets.all(16),child:Text('Nenhuma movimentação registrada ainda.')));
          return Card(child:Column(children:[
            for(final movimento in itens) ListTile(
              leading:CircleAvatar(child:Icon(movimento.tipo=='aporte'?Icons.add_circle_outline:Icons.trending_up)),
              title:Text(movimento.tipo=='aporte'?'Aporte / depósito':'Rendimento'),
              subtitle:Text('${movimento.data.day.toString().padLeft(2,'0')}/${movimento.data.month.toString().padLeft(2,'0')}/${movimento.data.year}'),
              trailing:Row(mainAxisSize:MainAxisSize.min,children:[
                Text(Formatters.moeda(movimento.valor),style:const TextStyle(fontWeight:FontWeight.w700)),
                PopupMenuButton<String>(onSelected:(op){if(op=='editar')_editar(movimento);if(op=='excluir')_excluir(movimento);},itemBuilder:(_)=>const [PopupMenuItem(value:'editar',child:Text('Editar')),PopupMenuItem(value:'excluir',child:Text('Excluir'))]),
              ]),
            )
          ]));
        }),
        const SizedBox(height:12),
        const Card(child:Padding(padding:EdgeInsets.all(16),child:Text('O FGTS é compartilhado e não reduz nenhuma conta bancária. Cada aporte e rendimento fica registrado no histórico e pode ser editado ou excluído.'))),
      ]);
    }),
  );
}

class _FgtsEdicao { final String tipo; final double valor; const _FgtsEdicao(this.tipo,this.valor); }
class _FgtsEdicaoDialog extends StatefulWidget {
  final FgtsMovimentacao movimento;
  const _FgtsEdicaoDialog({required this.movimento});
  @override State<_FgtsEdicaoDialog> createState()=>_FgtsEdicaoDialogState();
}
class _FgtsEdicaoDialogState extends State<_FgtsEdicaoDialog>{
  late String _tipo;
  late final TextEditingController _controller;
  @override void initState(){super.initState();_tipo=widget.movimento.tipo;_controller=TextEditingController(text:widget.movimento.valor.toStringAsFixed(2).replaceAll('.',','));}
  @override void dispose(){_controller.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>AlertDialog(title:const Text('Editar movimentação'),content:Column(mainAxisSize:MainAxisSize.min,children:[DropdownButtonFormField<String>(initialValue:_tipo,items:const [DropdownMenuItem(value:'aporte',child:Text('Aporte / depósito')),DropdownMenuItem(value:'rendimento',child:Text('Rendimento'))],onChanged:(v){if(v!=null)setState(()=>_tipo=v);},decoration:const InputDecoration(labelText:'Tipo')),TextField(controller:_controller,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Valor',prefixText:'R\$ '))]),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Cancelar')),FilledButton(onPressed:(){final v=double.tryParse(_controller.text.replaceAll('.','').replaceAll(',','.'));if(v!=null&&v>0)Navigator.pop(context,_FgtsEdicao(_tipo,v));},child:const Text('Salvar'))]);
}

class _FgtsTipoDialog extends StatelessWidget {
  const _FgtsTipoDialog();
  @override Widget build(BuildContext context)=>AlertDialog(
    title:const Text('Tipo de movimentação'),
    content:Column(mainAxisSize:MainAxisSize.min,children:[
      ListTile(leading:const Icon(Icons.add_circle_outline),title:const Text('Aporte / depósito'),onTap:()=>Navigator.of(context).pop('aporte')),
      ListTile(leading:const Icon(Icons.trending_up),title:const Text('Rendimento'),onTap:()=>Navigator.of(context).pop('rendimento')),
    ]),
  );
}

class _ValorFgtsDialog extends StatefulWidget {
  const _ValorFgtsDialog();
  @override State<_ValorFgtsDialog> createState()=>_ValorFgtsDialogState();
}
class _ValorFgtsDialogState extends State<_ValorFgtsDialog>{
  late final TextEditingController _controller;
  @override void initState(){super.initState();_controller=TextEditingController();}
  @override void dispose(){_controller.dispose();super.dispose();}
  double _parse(String s)=>double.tryParse(s.replaceAll('.','').replaceAll(',','.'))??double.nan;
  @override Widget build(BuildContext context)=>AlertDialog(
    title:const Text('Valor da movimentação'),
    content:TextField(controller:_controller,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Valor',prefixText:'R\$ ')),
    actions:[TextButton(onPressed:()=>Navigator.of(context).pop(),child:const Text('Cancelar')),FilledButton(onPressed:(){final v=_parse(_controller.text);if(v.isFinite&&v>0)Navigator.of(context).pop(v);},child:const Text('Adicionar'))],
  );
}
