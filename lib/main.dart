import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const StudentBudgetApp());
}

class StudentBudgetApp extends StatelessWidget {
  const StudentBudgetApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Budget App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double totalBudget = 500.0;  // Initial default budget in rupees
  List<Map<String, dynamic>> expenses = [];
  DateTime? filterStartDate;
  DateTime? filterEndDate;
  String? filterCategory;

  // Method to update the total budget
  void setTotalBudget(double newBudget) {
    setState(() {
      totalBudget = newBudget;
    });
  }

  void addExpense(String title, double amount, String category, DateTime dateTime) {
    setState(() {
      expenses.add({'title': title, 'amount': amount, 'category': category, 'dateTime': dateTime});
    });
  }

  void updateExpense(int index, String title, double amount, String category, DateTime dateTime) {
    setState(() {
      expenses[index] = {'title': title, 'amount': amount, 'category': category, 'dateTime': dateTime};
    });
  }

  void deleteExpense(int index) {
    setState(() {
      expenses.removeAt(index);
    });
  }

  void applyFilters(DateTime? startDate, DateTime? endDate, String? category) {
    setState(() {
      filterStartDate = startDate;
      filterEndDate = endDate;
      filterCategory = category;
    });
  }

  List<Map<String, dynamic>> get filteredExpenses {
    return expenses.where((expense) {
      final matchesDate = (filterStartDate == null || expense['dateTime'].isAfter(filterStartDate!)) &&
          (filterEndDate == null || expense['dateTime'].isBefore(filterEndDate!.add(const Duration(days: 1))));
      final matchesCategory = filterCategory == null || expense['category'] == filterCategory;
      return matchesDate && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    double totalSpent = filteredExpenses.fold(0.0, (sum, item) => sum + item['amount']);
    double remainingBudget = totalBudget - totalSpent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Budget App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => FilterExpenses(
                  applyFilters: applyFilters,
                  filterStartDate: filterStartDate,
                  filterEndDate: filterEndDate,
                  filterCategory: filterCategory,
                ),
              );
            },
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade200, Colors.blue.shade300],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Budget: ₹${totalBudget.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  Text(
                    'Remaining: ₹${remainingBudget.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, color: Colors.greenAccent),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredExpenses.length,
                itemBuilder: (ctx, index) {
                  final expense = filteredExpenses[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    shadowColor: Colors.black45,
                    elevation: 5,
                    child: ListTile(
                      title: Text(expense['title'], style: const TextStyle(color: Colors.black87)),
                      subtitle: Text(
                        'Category: ${expense['category']}\n'
                        'Date: ${DateFormat.yMMMd().format(expense['dateTime'])}, '
                        'Time: ${DateFormat.jm().format(expense['dateTime'])}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (_) => AddExpense(
                                  addExpense: addExpense,
                                  updateExpense: updateExpense,
                                  expenseIndex: index,
                                  expenseToEdit: expense,
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteExpense(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => AddExpense(
              addExpense: addExpense,
              updateExpense: updateExpense,
            ),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.purpleAccent,
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // Show a dialog to enter the total budget
            showDialog(
              context: context,
              builder: (context) {
                final TextEditingController budgetController = TextEditingController();

                return AlertDialog(
                  title: const Text('Enter Total Budget'),
                  content: TextField(
                    controller: budgetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Budget in Rupees'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        double newBudget = double.tryParse(budgetController.text) ?? 0.0;
                        if (newBudget > 0) {
                          setTotalBudget(newBudget);
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a valid budget.')),
                          );
                        }
                      },
                      child: const Text('Submit'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                );
              },
            );
          },
          child: const Text('Set Total Budget'),
          style: ElevatedButton.styleFrom(primary: Colors.purpleAccent),
        ),
      ),
    );
  }
}

class AddExpense extends StatefulWidget {
  final Function(String, double, String, DateTime) addExpense;
  final Function(int, String, double, String, DateTime)? updateExpense;
  final int? expenseIndex;
  final Map<String, dynamic>? expenseToEdit;

  const AddExpense({
    Key? key,
    required this.addExpense,
    this.updateExpense,
    this.expenseIndex,
    this.expenseToEdit,
  }) : super(key: key);

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Food';
  DateTime _selectedDateTime = DateTime.now();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.expenseToEdit != null) {
      _titleController.text = widget.expenseToEdit!['title'];
      _amountController.text = widget.expenseToEdit!['amount'].toString();
      _selectedCategory = widget.expenseToEdit!['category'];
      _selectedDateTime = widget.expenseToEdit!['dateTime'];
    }
  }

  void _submitData() {
    if (!_formKey.currentState!.validate()) return;

    final enteredTitle = _titleController.text.trim();
    final enteredAmount = double.parse(_amountController.text);

    if (widget.expenseIndex == null) {
      widget.addExpense(enteredTitle, enteredAmount, _selectedCategory, _selectedDateTime);
    } else {
      widget.updateExpense!(
        widget.expenseIndex!,
        enteredTitle,
        enteredAmount,
        _selectedCategory,
        _selectedDateTime,
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty || double.tryParse(value) == null) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: ['Food', 'Transport', 'Entertainment', 'Others']
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            ElevatedButton.icon(
              onPressed: _submitData,
              icon: const Icon(Icons.add),
              label: Text(widget.expenseToEdit == null ? 'Add Expense' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterExpenses extends StatefulWidget {
  final Function(DateTime?, DateTime?, String?) applyFilters;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  final String? filterCategory;

  const FilterExpenses({
    Key? key,
    required this.applyFilters,
    this.filterStartDate,
    this.filterEndDate,
    this.filterCategory,
  }) : super(key: key);

  @override
  State<FilterExpenses> createState() => _FilterExpensesState();
}

class _FilterExpensesState extends State<FilterExpenses> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _startDate = widget.filterStartDate;
    _endDate = widget.filterEndDate;
    _selectedCategory = widget.filterCategory;
  }

  void _pickStartDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _pickEndDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _applyFilters() {
    widget.applyFilters(_startDate, _endDate, _selectedCategory);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Filter Expenses',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _pickStartDate,
                  child: Text(
                    _startDate == null
                        ? 'Pick Start Date'
                        : 'Start: ${DateFormat.yMMMd().format(_startDate!)}',
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: _pickEndDate,
                  child: Text(
                    _endDate == null
                        ? 'Pick End Date'
                        : 'End: ${DateFormat.yMMMd().format(_endDate!)}',
                  ),
                ),
              ),
            ],
          ),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(labelText: 'Category'),
            items: [null, 'Food', 'Transport', 'Entertainment', 'Others']
                .map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category ?? 'All Categories'),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _applyFilters,
            icon: const Icon(Icons.filter_list),
            label: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }
}
