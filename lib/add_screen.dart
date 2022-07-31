import 'package:expenses/database_ms.dart';
import 'package:flutter/material.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({ Key? key, required this.uid, required this.date }) : super(key: key);

  final String uid;
  final DateTime date;
  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  var opt = 'Income';
  final TextEditingController ctrl = TextEditingController();
  final TextEditingController numctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
      children: [
      Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text('Type', style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500
            ),),
            DropdownButton(items: const[
              DropdownMenuItem<String>(value: 'Income', child: Text('Income')),
              DropdownMenuItem<String>(value: 'Expense', child: Text('Expense'))
            ],
            onChanged: (dynamic a) {
              opt = a;
              setState(() {
                
              });
            },
            value: opt,
            )
          ],
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text('Title',
              style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500
                            ),),
              SizedBox(
                width: 150,
                height: 125,
                child: TextFormField(
                  controller: ctrl,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              )
            ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text('Cost',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500
              ),),
              SizedBox(
                width: 150,
                height: 50,
                child: TextFormField(
                  controller: numctrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder()
                  ),
                ),
              )
            ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: OutlinedButton(
          onPressed: () {
            Transaction t = Transaction(ctrl.text, double.parse(numctrl.text));
            addTransaction(uid: widget.uid, t: t, type: opt, date: widget.date);
            Navigator.pop(context);
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.green)
          ),
          child: const Text(
            "Add transaction",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            backgroundColor: Colors.green,
            color: Colors.white,
            fontSize: 16
          ),
        ),

        ),
      )
      ],
    ),
        ),
    )
    );
  }
}