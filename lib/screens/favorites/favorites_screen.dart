import 'package:flutter/material.dart';
import '../../services/favorites_service.dart';
import '../../models/address_model.dart';
import '../../widgets/address_search_widget.dart';
import '../../theme/vello_tokens.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);
  
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // Cores da identidade visual Vello
  static const Color velloBlue = VelloTokens.brandBlue;
  static const Color velloOrange = VelloTokens.brandOrange;
  static const Color velloLightGray = VelloTokens.grayLight;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: velloLightGray,
      appBar: AppBar(
        title: const Text(
          'Endereços Favoritos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: VelloTokens.white,
        elevation: 0,
        foregroundColor: velloBlue,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: velloOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: velloOrange,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: velloBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add,
                color: velloBlue,
                size: 20,
              ),
            ),
            onPressed: _showAddFavoriteDialog,
            tooltip: 'Adicionar',
          ),
        ],
      ),
      body: StreamBuilder<List<FavoriteAddress>>(
        stream: FavoritesService.getFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: velloOrange),
            );
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar favoritos',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }
          
          final favorites = snapshot.data ?? [];
          
          if (favorites.isEmpty) {
            return _buildEmptyState();
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final favorite = favorites[index];
              return _buildFavoriteCard(favorite);
            },
          );
        },
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: velloOrange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border,
                size: 64,
                color: velloOrange,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nenhum favorito ainda',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: velloBlue,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Adicione seus endereços favoritos para acessá-los rapidamente na hora de solicitar uma corrida.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showAddFavoriteDialog,
              icon: const Icon(Icons.add, color: VelloTokens.white),
              label: const Text(
                'Adicionar Favorito',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: VelloTokens.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: velloOrange,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFavoriteCard(FavoriteAddress favorite) {
    return Container(
      key: ValueKey(favorite.id ?? 'favorite_${favorite.hashCode}'),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: VelloTokens.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: VelloTokens.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getTypeColor(favorite.type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              favorite.displayIcon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          favorite.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: velloBlue,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              favorite.address.shortAddress,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getTypeColor(favorite.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getTypeLabel(favorite.type),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _getTypeColor(favorite.type),
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditFavoriteDialog(favorite);
                break;
              case 'delete':
                _showDeleteConfirmation(favorite);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Excluir', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getTypeColor(FavoriteType type) {
    switch (type) {
      case FavoriteType.home:
        return Colors.green;
      case FavoriteType.work:
        return Colors.blue;
      case FavoriteType.other:
        return velloOrange;
    }
  }
  
  String _getTypeLabel(FavoriteType type) {
    switch (type) {
      case FavoriteType.home:
        return 'Casa';
      case FavoriteType.work:
        return 'Trabalho';
      case FavoriteType.other:
        return 'Outro';
    }
  }
  
  void _showAddFavoriteDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddFavoriteDialog(),
    );
  }
  
  void _showEditFavoriteDialog(FavoriteAddress favorite) {
    showDialog(
      context: context,
      builder: (context) => _EditFavoriteDialog(favorite: favorite),
    );
  }
  
  void _showDeleteConfirmation(FavoriteAddress favorite) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Favorito'),
        content: Text('Tem certeza que deseja excluir "${favorite.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await FavoritesService.removeFavorite(favorite.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Favorito excluído com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir', style: TextStyle(color: VelloTokens.white)),
          ),
        ],
      ),
    );
  }
}

// Dialog para adicionar favorito
class _AddFavoriteDialog extends StatefulWidget {
  @override
  State<_AddFavoriteDialog> createState() => _AddFavoriteDialogState();
}

class _AddFavoriteDialogState extends State<_AddFavoriteDialog> {
  final TextEditingController _nameController = TextEditingController();
  AddressModel? _selectedAddress;
  FavoriteType _selectedType = FavoriteType.other;
  bool _isLoading = false;
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
  
  Future<void> _saveFavorite() async {
    if (_nameController.text.trim().isEmpty || _selectedAddress == null) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final success = await FavoritesService.addFavorite(
        name: _nameController.text.trim(),
        type: _selectedType,
        address: _selectedAddress!,
      );
      
      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Favorito adicionado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar favorito: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Favorito'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do favorito',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            DropdownButtonFormField<FavoriteType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                border: OutlineInputBorder(),
              ),
              items: FavoriteType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Text(_getTypeIcon(type), style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(_getTypeLabel(type)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
            
            const SizedBox(height: 16),
            
            AddressSearchWidget(
              hint: 'Buscar endereço',
              onAddressSelected: (address) {
                setState(() {
                  _selectedAddress = address;
                });
              },
              showFavorites: false,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveFavorite,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Adicionar'),
        ),
      ],
    );
  }
  
  String _getTypeIcon(FavoriteType type) {
    switch (type) {
      case FavoriteType.home:
        return '🏠';
      case FavoriteType.work:
        return '🏢';
      case FavoriteType.other:
        return '📍';
    }
  }
  
  String _getTypeLabel(FavoriteType type) {
    switch (type) {
      case FavoriteType.home:
        return 'Casa';
      case FavoriteType.work:
        return 'Trabalho';
      case FavoriteType.other:
        return 'Outro';
    }
  }
}

// Dialog para editar favorito
class _EditFavoriteDialog extends StatefulWidget {
  final FavoriteAddress favorite;
  
  const _EditFavoriteDialog({required this.favorite});
  
  @override
  State<_EditFavoriteDialog> createState() => _EditFavoriteDialogState();
}

class _EditFavoriteDialogState extends State<_EditFavoriteDialog> {
  late final TextEditingController _nameController;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.favorite.name);
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
  
  Future<void> _updateFavorite() async {
    if (_nameController.text.trim().isEmpty) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final success = await FavoritesService.updateFavorite(
        favoriteId: widget.favorite.id,
        name: _nameController.text.trim(),
      );
      
      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Favorito atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar favorito: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Favorito'),
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: 'Nome do favorito',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateFavorite,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }
}