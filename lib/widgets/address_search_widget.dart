import 'package:flutter/material.dart';

import '../models/address_model.dart';
import '../services/address_search_service.dart';
import '../services/favorites_service.dart';
import '../theme/vello_tokens.dart';

class AddressSearchWidget extends StatefulWidget {
  final String hint;
  final AddressModel? initialAddress;
  final Function(AddressModel) onAddressSelected;
  final bool showFavorites;
  final IconData? prefixIcon;
  
  const AddressSearchWidget({
    Key? key,
    required this.hint,
    required this.onAddressSelected,
    this.initialAddress,
    this.showFavorites = true,
    this.prefixIcon,
  }) : super(key: key);
  
  @override
  State<AddressSearchWidget> createState() => _AddressSearchWidgetState();
}

class _AddressSearchWidgetState extends State<AddressSearchWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  List<AddressModel> _searchResults = [];
  List<FavoriteAddress> _favorites = [];
  bool _isLoading = false;
  bool _showResults = false;
  
  // Cores da identidade visual Vello
  static const Color velloBlue = VelloTokens.brandBlue;
  static const Color velloOrange = VelloTokens.brandOrange;
  static const Color velloLightGray = VelloTokens.grayLight;
  
  @override
  void initState() {
    super.initState();
    
    if (widget.initialAddress != null) {
      _controller.text = widget.initialAddress!.shortAddress;
    }
    
    _loadFavorites();
    
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _showResults = true;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  void _loadFavorites() async {
    if (!widget.showFavorites) return;
    
    FavoritesService.getFavorites().listen((favorites) {
      if (mounted) {
        setState(() {
          _favorites = favorites;
        });
      }
    });
  }
  
  void _searchAddresses(String query) async {
    if (query.length < 3) {
      setState(() {
        _searchResults = [];
        _showResults = _focusNode.hasFocus;
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _showResults = true;
    });
    
    try {
      final results = await AddressSearchService.searchAddresses(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
      }
    }
  }
  
  void _selectAddress(AddressModel address) {
    setState(() {
      _controller.text = address.shortAddress;
      _showResults = false;
    });
    _focusNode.unfocus();
    widget.onAddressSelected(address);
  }
  
  void _selectFavorite(FavoriteAddress favorite) {
    _selectAddress(favorite.address);
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: VelloTokens.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: VelloTokens.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _searchAddresses,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: velloOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.prefixIcon,
                        color: velloOrange,
                        size: 20,
                      ),
                    )
                  : null,
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _controller.clear();
                          _searchResults = [];
                          _showResults = false;
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: VelloTokens.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
        
        if (_showResults) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            decoration: BoxDecoration(
              color: VelloTokens.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: VelloTokens.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildResultsList(),
          ),
        ],
      ],
    );
  }
  
  Widget _buildResultsList() {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // Favoritos
        if (widget.showFavorites && _favorites.isNotEmpty && _controller.text.length < 3) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Favoritos',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: velloBlue,
              ),
            ),
          ),
          ..._favorites.map((favorite) => _buildFavoriteItem(favorite)),
          const Divider(height: 1),
        ],
        
        // Resultados da busca
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(
                color: velloOrange,
                strokeWidth: 3,
              ),
            ),
          )
        else if (_searchResults.isNotEmpty) ...[
          if (_favorites.isNotEmpty && _controller.text.length >= 3)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Resultados',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: velloBlue,
                ),
              ),
            ),
          ..._searchResults.map((address) => _buildAddressItem(address)),
        ] else if (_controller.text.length >= 3) ...[
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Nenhum endereço encontrado',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildFavoriteItem(FavoriteAddress favorite) {
    return InkWell(
      onTap: () => _selectFavorite(favorite),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: velloBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  favorite.displayIcon,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    favorite.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: velloBlue,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    favorite.address.shortAddress,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAddressItem(AddressModel address) {
    return InkWell(
      onTap: () => _selectAddress(address),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: velloOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.location_on,
                color: velloOrange,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.street.isNotEmpty ? address.street : address.neighborhood,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: velloBlue,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    address.displayName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}