import 'package:flutter/material.dart';
import '../models/text_entry.dart';
import '../providers/app_state_provider.dart';

class SearchScreen extends StatefulWidget {
  final AppStateProvider appStateProvider;

  const SearchScreen({super.key, required this.appStateProvider});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchHistory = [];
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _searchController.text = widget.appStateProvider.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    try {
      final history = await widget.appStateProvider.getSearchHistory();
      setState(() {
        _searchHistory = history;
      });
    } catch (e) {
      // Error loading search history: $e
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar en el historial...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          widget.appStateProvider.setSearchQuery('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                widget.appStateProvider.setSearchQuery(value);
              },
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _addToSearchHistory(value);
                }
              },
            ),
          ),

          // Filtros
          if (_showFilters) _buildFiltersSection(),

          // Estadísticas de búsqueda
          _buildSearchStats(),

          // Resultados
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtros',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            // Filtro por categoría
            _buildCategoryFilter(),
            const SizedBox(height: 12),
            
            // Filtro por fuente
            _buildSourceFilter(),
            const SizedBox(height: 12),
            
            // Filtro por fecha
            _buildDateFilter(),
            const SizedBox(height: 16),
            
            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: widget.appStateProvider.clearFilters,
                  child: const Text('Limpiar Filtros'),
                ),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _showFilters = false;
                    });
                  },
                  child: const Text('Ocultar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Categoría:'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            FilterChip(
              label: const Text('Todas'),
              selected: widget.appStateProvider.selectedCategory.isEmpty,
              onSelected: (_) {
                widget.appStateProvider.setCategory('');
              },
            ),
            ...widget.appStateProvider.getAllCategories().map(
              (category) => FilterChip(
                label: Text(category),
                selected: widget.appStateProvider.selectedCategory == category,
                onSelected: (_) {
                  widget.appStateProvider.setCategory(
                    widget.appStateProvider.selectedCategory == category ? '' : category,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSourceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fuente:'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            FilterChip(
              label: const Text('Todas'),
              selected: widget.appStateProvider.selectedSource.isEmpty,
              onSelected: (_) {
                widget.appStateProvider.setSource('');
              },
            ),
            ...widget.appStateProvider.getAllSources().map(
              (source) => FilterChip(
                label: Text(_getSourceDisplayName(source)),
                selected: widget.appStateProvider.selectedSource == source,
                onSelected: (_) {
                  widget.appStateProvider.setSource(
                    widget.appStateProvider.selectedSource == source ? '' : source,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rango de fechas:'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  widget.appStateProvider.dateRange != null
                      ? '${_formatDate(widget.appStateProvider.dateRange!.start)} - ${_formatDate(widget.appStateProvider.dateRange!.end)}'
                      : 'Seleccionar rango',
                ),
                onPressed: _selectDateRange,
              ),
            ),
            if (widget.appStateProvider.dateRange != null)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  widget.appStateProvider.setDateRange(null);
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchStats() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Resultados: ${widget.appStateProvider.filteredCount} de ${widget.appStateProvider.totalEntries}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (_searchHistory.isNotEmpty)
            TextButton.icon(
              icon: const Icon(Icons.history, size: 16),
              label: const Text('Historial'),
              onPressed: _showSearchHistory,
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (widget.appStateProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.appStateProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              widget.appStateProvider.error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: widget.appStateProvider.clearError,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final entries = widget.appStateProvider.textEntries;

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withAlpha((0.5 * 255).toInt()),
            ),
            const SizedBox(height: 16),
            Text(
              widget.appStateProvider.searchQuery.isNotEmpty
                  ? 'No se encontraron resultados para "${widget.appStateProvider.searchQuery}"'
                  : 'No hay entradas que mostrar',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha((0.7 * 255).toInt()),
              ),
            ),
            if (widget.appStateProvider.searchQuery.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Intenta con otros términos de búsqueda o ajusta los filtros',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha((0.5 * 255).toInt()),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        return _buildEntryCard(entries[index]);
      },
    );
  }

  Widget _buildEntryCard(TextEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          entry.text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatDate(entry.timestamp)),
            Row(
              children: [
                Chip(
                  label: Text(entry.category),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
                Icon(
                  _getSourceIcon(entry.source),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(_getSourceDisplayName(entry.source)),
              ],
            ),
            if (entry.tags.isNotEmpty)
              Wrap(
                spacing: 4,
                children: entry.tags.take(3).map(
                  (tag) => Chip(
                    label: Text(tag),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ).toList(),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'view',
              child: const ListTile(
                leading: Icon(Icons.visibility),
                title: Text('Ver'),
              ),
            ),
            PopupMenuItem(
              value: 'edit',
              child: const ListTile(
                leading: Icon(Icons.edit),
                title: Text('Editar'),
              ),
            ),
            PopupMenuItem(
              value: 'share',
              child: const ListTile(
                leading: Icon(Icons.share),
                title: Text('Compartir'),
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: const ListTile(
                leading: Icon(Icons.delete),
                title: Text('Eliminar'),
              ),
            ),
          ],
          onSelected: (value) => _handleEntryAction(entry, value),
        ),
        onTap: () => _viewEntry(entry),
      ),
    );
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: widget.appStateProvider.dateRange,
    );

    if (picked != null) {
      widget.appStateProvider.setDateRange(picked);
    }
  }

  void _showSearchHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Historial de Búsqueda'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: _searchHistory.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(_searchHistory[index]),
                onTap: () {
                  _searchController.text = _searchHistory[index];
                  widget.appStateProvider.setSearchQuery(_searchHistory[index]);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _addToSearchHistory(String query) {
    if (!_searchHistory.contains(query)) {
      setState(() {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 10) {
          _searchHistory.removeLast();
        }
      });
    }
  }

  void _handleEntryAction(TextEntry entry, String action) {
    switch (action) {
      case 'view':
        _viewEntry(entry);
        break;
      case 'edit':
        _editEntry(entry);
        break;
      case 'share':
        _shareEntry(entry);
        break;
      case 'delete':
        _deleteEntry(entry);
        break;
    }
  }

  void _viewEntry(TextEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${entry.category} - ${_formatDate(entry.timestamp)}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(entry.text),
              if (entry.translatedText != null) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Traducción (${entry.targetLanguage}):',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text(entry.translatedText!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _editEntry(TextEntry entry) {
    // Aquí implementarías la lógica para editar la entrada
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de edición en desarrollo')),
    );
  }

  void _shareEntry(TextEntry entry) {
    // Aquí implementarías la lógica para compartir la entrada
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de compartir en desarrollo')),
    );
  }

  void _deleteEntry(TextEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar entrada'),
        content: const Text('¿Estás seguro de que quieres eliminar esta entrada?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              widget.appStateProvider.deleteEntry(entry.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Entrada eliminada')),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getSourceDisplayName(String source) {
    switch (source) {
      case 'camera':
        return 'Cámara';
      case 'gallery':
        return 'Galería';
      case 'microphone':
        return 'Micrófono';
      default:
        return source;
    }
  }

  IconData _getSourceIcon(String source) {
    switch (source) {
      case 'camera':
        return Icons.camera_alt;
      case 'gallery':
        return Icons.photo_library;
      case 'microphone':
        return Icons.mic;
      default:
        return Icons.text_snippet;
    }
  }
}
