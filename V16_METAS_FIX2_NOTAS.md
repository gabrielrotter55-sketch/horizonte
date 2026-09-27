# V16 Metas Fix 2

Corrige a atualização da aba Metas sem depender de `_MetasPageState` privado.
A NavigationPage usa um ValueNotifier compartilhado com MetasPage para solicitar recarga quando a aba é selecionada.
