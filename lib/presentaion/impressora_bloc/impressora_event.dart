abstract class ImpressoraEvent {}

class ImpressaIniciou extends ImpressoraEvent {
  final String filePath;

  ImpressaIniciou({required this.filePath});
}

class ImpressoraFinalizou extends ImpressoraEvent {
  final String result;

  ImpressoraFinalizou({required this.result});
}
