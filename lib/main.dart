import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

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
        visualDensity: VisualDensity.adaptivePlatformDensity,
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
  double totalBudget = 500.0;
  List<Map<String, dynamic>> expenses = [];
  DateTime? filterStartDate;
  DateTime? filterEndDate;
  String? filterCategory;

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
        backgroundColor: Colors.purpleAccent,
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
          ),
          IconButton(
            icon: const Icon(Icons.credit_card),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => EducationLoanCalculator()));
            },
          ),
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
                    style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Remaining: ₹${remainingBudget.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20, color: Colors.greenAccent, fontWeight: FontWeight.w500),
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
                    elevation: 8,
                    child: ListTile(
                      title: Text(expense['title'], style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
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
            showDialog(
              context: context,
              builder: (context) {
                final TextEditingController budgetController = TextEditingController();

                return AlertDialog(
                  title: const Text('Enter Total Budget'),
                  content: TextField(
                    controller: budgetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Budget in Rupees',
                      labelStyle: TextStyle(color: Colors.purpleAccent),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.purpleAccent),
                      ),
                    ),
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
                      child: const Text('Submit', style: TextStyle(color: Colors.purpleAccent)),
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
          child: const Text('Set Total Budget', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            primary: Colors.purpleAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 5,
          ),
        ),
      ),
    );
  }
}

class EducationLoanCalculator extends StatefulWidget {
  @override
  _EducationLoanCalculatorState createState() => _EducationLoanCalculatorState();
}

class _EducationLoanCalculatorState extends State<EducationLoanCalculator> {
  final _loanAmountController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _loanTenureController = TextEditingController();

  double _emi = 0.0;
  double _totalRepayment = 0.0;

  void calculateLoan() {
    double loanAmount = double.tryParse(_loanAmountController.text) ?? 0.0;
    double interestRate = double.tryParse(_interestRateController.text) ?? 0.0;
    int loanTenure = int.tryParse(_loanTenureController.text) ?? 0;

    if (loanAmount <= 0 || interestRate <= 0 || loanTenure <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid values.')),
      );
      return;
    }

    // Calculate EMI using the formula
    double monthlyInterestRate = (interestRate / 100) / 12;
    int totalMonths = loanTenure * 12;

    double emi = (loanAmount * monthlyInterestRate) /
        (1 - pow(1 + monthlyInterestRate, -totalMonths));

    setState(() {
      _emi = emi;
      _totalRepayment = emi * totalMonths;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Education Loan Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _loanAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Loan Amount (₹)'),
            ),
            TextField(
              controller: _interestRateController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Interest Rate (%)'),
            ),
            TextField(
              controller: _loanTenureController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Loan Tenure (Years)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateLoan,
              child: const Text('Calculate EMI'),
            ),
            const SizedBox(height: 20),
            if (_emi > 0)
              Column(
                children: [
                  Text('EMI: ₹${_emi.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20)),
                  Text('Total Repayment: ₹${_totalRepayment.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class AddExpense extends StatelessWidget {
  final Function addExpense;
  final Function updateExpense;
  final int? expenseIndex;
  final Map<String, dynamic>? expenseToEdit;

  const AddExpense({
    required this.addExpense,
    required this.updateExpense,
    this.expenseIndex,
    this.expenseToEdit,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController = TextEditingController(
      text: expenseToEdit?['title'] ?? '',
    );
    final TextEditingController amountController = TextEditingController(
      text: expenseToEdit?['amount'].toString() ?? '',
    );
    final TextEditingController categoryController = TextEditingController(
      text: expenseToEdit?['category'] ?? '',
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Amount'),
          ),
          TextField(
            controller: categoryController,
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text;
              final amount = double.tryParse(amountController.text) ?? 0.0;
              final category = categoryController.text;

              if (title.isEmpty || amount <= 0 || category.isEmpty) {
                return;
              }

              if (expenseIndex != null) {
                updateExpense(expenseIndex!, title, amount, category, DateTime.now());
              } else {
                addExpense(title, amount, category, DateTime.now());
              }
              Navigator.pop(context);
            },
            child: Text(expenseIndex == null ? 'Add Expense' : 'Update Expense'),
          ),
        ],
      ),
    );
  }
}

class FilterExpenses extends StatelessWidget {
  final Function(DateTime?, DateTime?, String?) applyFilters;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  final String? filterCategory;

  const FilterExpenses({
    required this.applyFilters,
    this.filterStartDate,
    this.filterEndDate,
    this.filterCategory,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController categoryController = TextEditingController(text: filterCategory);
    DateTime? startDate = filterStartDate;
    DateTime? endDate = filterEndDate;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: categoryController,
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          ListTile(
            title: const Text('Start Date'),
            subtitle: Text(startDate != null ? DateFormat.yMMMd().format(startDate) : 'Select Date'),
            trailing: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: startDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  startDate = pickedDate;
                }
              },
            ),
          ),
          ListTile(
            title: const Text('End Date'),
            subtitle: Text(endDate != null ? DateFormat.yMMMd().format(endDate) : 'Select Date'),
            trailing: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: endDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  endDate = pickedDate;
                }
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              applyFilters(startDate, endDate, categoryController.text);
              Navigator.pop(context);
            },
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }
}
