import 'package:expenses/add_screen.dart';
import 'package:expenses/database_ms.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Expense Tracker', date: DateTime.now(),),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, required this.date}) : super(key: key);
  final DateTime date;

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime? _selectedDay;
  DateTime? _focusedDay;
  String? uid;

  void refresh(DateTime day)
  {
    setState(() {
      _selectedDay = day;
      _focusedDay = day;
    });
  }

  @override 
  void initState() {
    _selectedDay = widget.date;
    _focusedDay = widget.date;
    getUid();
  }

  int? income = 1000;
  Future<List<Transaction>>? incomes;
  Future<List<Transaction>>? expenses;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Container(
        child: Column(
          children: [
            Flexible(
              flex: 4,
              child: TableCalendar(
                firstDay: DateTime.utc(2000),
                lastDay: DateTime.utc(3000),
                focusedDay: _focusedDay!,
                calendarFormat: CalendarFormat.month,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if(!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    setIncome();
                    setExpenses();
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                  print(_focusedDay);
                },
                onFormatChanged: (_) {

                },
              ),
            ),
            Container(
                    decoration: BoxDecoration(
                      border: Border.all(),
                      color: Colors.greenAccent
                    ),
                    height: 50,
                    width: double.maxFinite,
                    child: Center(
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              '${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}'
                            ),
                          ),
                          Spacer(),
                          const Text(
                            'Add new item'
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () async{
                              await Navigator.push(context, 
                              MaterialPageRoute(
                                builder: (BuildContext context) => AddScreen(
                                  uid: uid!,
                                  date: _selectedDay!,
                                )
                              ));
                              await Future.delayed(Duration(seconds: 1));
                              refresh(_selectedDay!);
                            },
                          )
                        ],
                      ),
                    ),
                  ),
            Flexible(
              flex: 3,
              child: FutureBuilder(
                future: Future.wait([setIncome(), setExpenses()]),
                builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                  if(snapshot.hasData) {
                    if(snapshot.data?[0] != null && snapshot.data?[1] != null) {
                      return Inventory(
                        uid: uid!,
                        selectedDay: _selectedDay!,
                        incomes: snapshot.data![0] as List<Transaction>,
                        expenses: snapshot.data![1] as List<Transaction>,);
                    }
                  }
                  return const Center(child: CircularProgressIndicator(),);
                },
              )
            )
          ],
        ),
      )
    );
  }

  Future<void> getUid() async{
    uid = '4O9bKAvnKAV7YaQRwu9H';
  }

  Future<List<Transaction>> setIncome() async {
    
    incomes = getUserIncome(uid: uid, date: _selectedDay!);
    return incomes!;
  }
  Future<List<Transaction>> setExpenses() async {    
    expenses = getUserExpenses(uid: uid, date: _selectedDay!);
    return expenses!;
  }

}

class Inventory extends StatefulWidget {
  const Inventory({ Key? key , required this.uid, required this.selectedDay, required this.incomes, required this.expenses}) : super(key: key);

  final DateTime selectedDay;
  final List<Transaction> incomes;
  final List<Transaction> expenses;
  final String uid;

  @override
  _InventoryState createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  dynamic opt = 'Income';
  TextEditingController ctrl = TextEditingController();
  TextEditingController numctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(),
                        color: Colors.yellow,
                      ),
                      height: 50,
                      width: double.maxFinite,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Gross Savings',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '₹${totalCount(widget.incomes) - totalCount(widget.expenses)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: totalCount(widget.incomes) - totalCount(widget.expenses) > 0
                                  ? Colors.green
                                  : Colors.red
                                ),
                              ),
                            )
                          ],
                        )
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(),
                        color: Colors.yellow,
                      ),
                      height: 50,
                      width: double.maxFinite,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Total Income',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '₹${totalCount(widget.incomes)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green
                                ),
                              ),
                            )
                          ],
                        )
                      ),
                    ),
                  ),
                  ...incomeWidgets(widget.incomes),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(),
                        color: Colors.yellow,
                      ),
                      height: 50,
                      width: double.maxFinite,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Total Expenditure',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '₹${totalCount(widget.expenses)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red
                                ),
                              ),
                            )
                          ],
                        )
                      ),
                    ),
                  ),
                  ...incomeWidgets(widget.expenses)
                ],
              ),
    );
  }

  double totalCount(List<Transaction> e) {
    double t = 0;
    e.forEach((element) {t += element.cost;});
    return t;
  }

  List<Widget> incomeWidgets(List<Transaction>? incomes) {
    if(incomes == null) return [];
    
    return List<Widget>.generate(
      incomes.length,
      (index) { 
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 36.0),
          child: Container(
            width: double.maxFinite,
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${index+1}) ${incomes[index].title}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800
                  ),
                ),
                Text(
                  '₹${incomes[index].cost.toString()}'
                )
              ],
            ),
          ),
        );
      }
      );
  }
}
