import 'package:flutter/material.dart';
import '../data/models/meat_item.dart';
import '../data/repositories/meat_item_repository.dart';
import '../widgets/meat_item_card.dart';
import 'capture_screen.dart';
import 'item_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final repository = MeatItemRepository();
  List<MeatItem> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => loading = true);
    items = await repository.getAllOrderedByExpiry();
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Validade do Açougue')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? const Center(child: Text('Nenhum produto cadastrado ainda.'))
          : RefreshIndicator(
              onRefresh: _loadItems,
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return MeatItemCard(
                    item: item,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ItemDetailScreen(itemId: item.id!),
                        ),
                      );
                      _loadItems();
                    },
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CaptureScreen()),
          );
          _loadItems();
        },
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
