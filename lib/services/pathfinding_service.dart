// lib/services/pathfinding_service.dart

import 'package:projet_ratp/models/positionnement.dart';
import 'package:projet_ratp/services/data_service.dart';

class PathfindingService {
  // NOUVEAU: Singleton pour s'assurer que les données ne sont chargées qu'une fois.
  static final PathfindingService _instance = PathfindingService._internal();
  factory PathfindingService() {
    return _instance;
  }

  PathfindingService._internal() {
    _loadAndPrepareData();
  }

  List<Positionnement> _data = [];
  // NOUVEAU: Map d'adjacence pour une recherche ultra-rapide.
  Map<String, List<Positionnement>> _adjacencyMap = {};
  bool _isReady = false;

  // NOUVEAU: Méthode pour préparer les données en arrière-plan.
  Future<void> _loadAndPrepareData() async {
    if (_isReady) return;

    final dataService = DataService();
    _data = await dataService.loadData();

    for (var position in _data) {
      if (position.fromName != null) {
        if (!_adjacencyMap.containsKey(position.fromName!)) {
          _adjacencyMap[position.fromName!] = [];
        }
        _adjacencyMap[position.fromName!]!.add(position);
      }
    }
    _isReady = true;
    print("Pathfinding Service is ready.");
  }

  // NOUVEAU: Helper pour compter les correspondances.
  int _countConnections(List<Positionnement> path) {
    if (path.isEmpty) return 0;
    
    Set<String> lines = {};
    for (var segment in path) {
      // On compte chaque ligne unique utilisée dans le trajet.
      // Les segments de marche (correspondances) ont souvent un lineId null.
      if (segment.lineId != null) {
        lines.add(segment.lineId!);
      }
    }
    // Le nombre de correspondances est le nombre de lignes utilisées moins un.
    return lines.isEmpty ? 0 : lines.length - 1;
  }

  Future<List<List<Positionnement>>> findPaths(String start, String end) async {
    if (!_isReady) {
      await _loadAndPrepareData();
    }

    List<List<Positionnement>> allPaths = [];
    
    // CHANGEMENT: On utilise un Set pour les stations déjà visitées dans un chemin donné
    // pour éviter les boucles infinies (ex: A -> B -> A).
    _findAllPathsRecursive(start, end, [], {}, allPaths);

    // CHANGEMENT: Tri avancé par nombre de correspondances, puis par longueur.
    allPaths.sort((a, b) {
      final connectionsA = _countConnections(a);
      final connectionsB = _countConnections(b);
      
      int comp = connectionsA.compareTo(connectionsB);
      if (comp != 0) return comp;
      
      return a.length.compareTo(b.length);
    });

    return allPaths.take(5).toList();
  }

  void _findAllPathsRecursive(
    String current,
    String end,
    List<Positionnement> currentPath,
    Set<String> visitedNodesInPath,
    List<List<Positionnement>> allPaths,
  ) {
    // Limite pour éviter les chemins trop longs et les calculs infinis
    if (currentPath.length > 15) {
      return;
    }
    
    visitedNodesInPath.add(current);

    if (current == end) {
      allPaths.add(List.from(currentPath));
      // On retire le noeud pour permettre de le retrouver via un autre chemin
      visitedNodesInPath.remove(current);
      return;
    }

    // CHANGEMENT: Utilisation de la map d'adjacence au lieu de scanner toute la liste.
    if (_adjacencyMap.containsKey(current)) {
      for (var segment in _adjacencyMap[current]!) {
        if (segment.toName != null && !visitedNodesInPath.contains(segment.toName!)) {
          currentPath.add(segment);
          _findAllPathsRecursive(segment.toName!, end, currentPath, visitedNodesInPath, allPaths);
          currentPath.removeLast(); // Backtrack
        }
      }
    }
    
    // On retire le noeud pour permettre de le retrouver via un autre chemin
    visitedNodesInPath.remove(current);
  }

  // NOUVEAU: Fonction pour l'auto-complétion
  Future<List<String>> getStationSuggestions(String pattern) async {
     if (!_isReady) {
      await _loadAndPrepareData();
    }
    if(pattern.isEmpty) return [];

    // On utilise les clés de la map qui sont uniques et représentent toutes les stations de départ.
    return _adjacencyMap.keys
        .where((stationName) => stationName.toLowerCase().contains(pattern.toLowerCase()))
        .toSet() // Pour s'assurer de l'unicité
        .toList();
  }
}