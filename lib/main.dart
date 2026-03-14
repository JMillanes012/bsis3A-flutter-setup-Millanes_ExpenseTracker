import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ExpensesHomePage(),
    );
  }
}

// ================= EXPENSE MODEL =================

class Expense {
  String title;
  double amount;

  Expense({required this.title, required this.amount});
}

// ================= HOME PAGE =================

class ExpensesHomePage extends StatefulWidget {
  const ExpensesHomePage({super.key});

  @override
  State<ExpensesHomePage> createState() => _ExpensesHomePageState();
}

class _ExpensesHomePageState extends State<ExpensesHomePage> {

  final List<Expense> _expenses = [
    Expense(title: "Food", amount: 150),
    Expense(title: "Transportation", amount: 60),
    Expense(title: "Snacks", amount: 45),
  ];

  // ADD EXPENSE
  void _navigateToAddExpense() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditExpensePage(),
      ),
    );

    if (result != null && result is Expense) {
      setState(() {
        _expenses.add(result);
      });
    }
  }

  // EDIT EXPENSE
  void _navigateToEditExpense(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditExpensePage(
          expense: _expenses[index],
        ),
      ),
    );

    if (result != null && result is Expense) {
      setState(() {
        _expenses[index] = result;
      });
    }
  }

  // DELETE EXPENSE
  void _deleteExpense(int index) {
    setState(() {
      _expenses.removeAt(index);
    });
  }

  // CONFIRM DELETE
  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Expense"),
        content: const Text("Are you sure you want to delete this expense?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              _deleteExpense(index);
              Navigator.pop(ctx);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  double get totalAmount {
    return _expenses.fold(0, (sum, item) => sum + item.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Tracker"),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddExpense,
        icon: const Icon(Icons.add),
        label: const Text("Add Expense"),
      ),

      body: Column(
        children: [

          // TOTAL CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  "Total Expenses",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                Text(
                  "₱${totalAmount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _expenses.length,
              itemBuilder: (context, index) {

                final expense = _expenses[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),

                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.attach_money),
                    ),

                    title: Text(
                      expense.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: Text("₱${expense.amount.toStringAsFixed(2)}"),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _navigateToEditExpense(index);
                          },
                        ),

                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _confirmDelete(index);
                          },
                        ),

                      ],
                    ),

                    onTap: () {
                      _navigateToEditExpense(index);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ================= ADD / EDIT SCREEN =================

class AddEditExpensePage extends StatefulWidget {

  final Expense? expense;

  const AddEditExpensePage({super.key, this.expense});

  @override
  State<AddEditExpensePage> createState() => _AddEditExpensePageState();
}

class _AddEditExpensePageState extends State<AddEditExpensePage> {

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  bool get isEdit => widget.expense != null;

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      _titleController.text = widget.expense!.title;
      _amountController.text = widget.expense!.amount.toString();
    }
  }

  void _saveExpense() {

    final title = _titleController.text.trim();
    final amountText = _amountController.text.trim();

    if (title.isEmpty) {
      _showError("Title cannot be empty");
      return;
    }

    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      _showError("Amount must be greater than 0");
      return;
    }

    Navigator.pop(
      context,
      Expense(title: title, amount: amount),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Expense" : "Add Expense"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Text(
                  isEdit ? "Edit Expense" : "New Expense",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Amount",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 25),

                Row(
                  children: [

                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveExpense,
                        child: const Text("Save"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}