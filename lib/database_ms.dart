import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  String title;
  double cost;

  Transaction(this.title, this.cost);
}

Future getUserData({String? uid}) async{
  final docUser = await FirebaseFirestore.instance.collection('users').doc(uid).get();

  return docUser.data();
}

Future<List<Transaction>> getUserIncome({ String? uid, required DateTime date }) async{
  final data = await getUserData(uid: uid);

  final income;
  final tryIncome = data['incomes']['${date.day}+${date.month}+${date.year}'];
  if(tryIncome != null)
    income = tryIncome['items'] as List;
  else
    income = [];
  List<Transaction> incomes = [];
  
  income.forEach((element) {
    incomes.add(Transaction(element['title'], double.parse(element['cost'].toString())));
  });

  return incomes;
}

Future<List<Transaction>> getUserExpenses({String? uid, required DateTime date }) async{
  final data = await getUserData(uid: uid);

  final expense;
  final tryExpense = data['expenses']['${date.day}+${date.month}+${date.year}'];
  if(tryExpense != null)
    expense = tryExpense['items'] as List;
  else
    expense = [];

  List<Transaction> expenses = [];
  
  expense.forEach((element) {
    expenses.add(Transaction(element['title'], double.parse(element['cost'].toString())));
  });

  return expenses;

}

Future<void> addTransaction({required String uid, required Transaction t, required String type, required DateTime date}) async{
  final docUser = await FirebaseFirestore.instance.collection('users').doc(uid);
  String query = type == 'Income' ? 'incomes' : 'expenses';

  final data = await getUserData(uid: uid);

  final expense;
  final tryExpense = data[query]['${date.day}+${date.month}+${date.year}'];
  if(tryExpense != null)
    expense = tryExpense['items'] as List;
  else
    expense = [];

  (expense as List).add({
    'title': t.title,
    'cost': t.cost
  });

  var fieldPath = FieldPath.fromString('${query}.${date.day}+${date.month}+${date.year}.items');

  docUser.update({
    fieldPath.components.reduce((value, element) => '$value.$element'): expense
  }
  );
}
