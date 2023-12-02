import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'db_helper.dart';
import 'meal_plan_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calorie Calculator',
      theme: ThemeData(
        primarySwatch: Colors.green,
        textTheme: TextTheme(
          bodyText1: TextStyle(fontSize: 20.0),
          bodyText2: TextStyle(fontSize: 20.0),
          headline6: TextStyle(fontSize: 24.0),
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dbHelper = DatabaseHelper();
  int targetCalories = 0;
  DateTime selectedDate = DateTime.now();
  int totalConsumedCalories = 0;
  TextEditingController foodController = TextEditingController();
  int calories = 0;
  bool usePredefinedList = true;

  @override
  void initState() {
    super.initState();
    _loadTotalConsumedCalories();
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _loadTotalConsumedCalories();
      });
    }
  }

  void _loadTotalConsumedCalories() async {
    final consumedFoods =
        await dbHelper.getMealPlanForDate(_formatDate(selectedDate));
    int totalCalories =
        consumedFoods.fold(0, (sum, food) => sum + food.calories);
    setState(() {
      totalConsumedCalories = totalCalories;
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _showFoodSelectionDialog() async {
    List<Map<String, dynamic>> foods = await dbHelper.getFoods();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Food'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text('Use Predefined List'),
                Column(
                  children: foods.map((food) {
                    return ListTile(
                      title: Text(food['name']),
                      onTap: () {
                        if (food['name'] != null && food['name'].isNotEmpty) {
                          setState(() {
                            foodController.text = food['name'];
                            calories = food['calories'];
                          });
                        }
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addFood() async {
    if (selectedDate == null) {
      _showSnackBar('Please choose a date.');
      return;
    }

    if (targetCalories == 0) {
      _showSnackBar('Please enter target calories');
      return;
    }

    await _showFoodSelectionDialog();

    if (calories > 0) {
      if (totalConsumedCalories + calories > targetCalories) {
        _showSnackBar('Target Calories Exceeded!');
        return;
      }

      await dbHelper.insertFood(
        foodController.text,
        calories,
        _formatDate(selectedDate),
      );

      _loadTotalConsumedCalories();

      setState(() {
        foodController.text = '';
        calories = 0;
      });
    }
  }

  void _deleteFood(int calories) {
    setState(() {
      totalConsumedCalories -= calories;
    });
  }

  void _viewMealPlan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MealPlanScreen(
          selectedDate: selectedDate,
          onDeleteFood: _deleteFood,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calories Calculator'),
      ),
      body: Column(
        children: [
          _buildTargetCaloriesInput(),
          _buildSelectedDateRow(),
          _buildAddFoodButton(),
          _buildTotalConsumedCaloriesText(),
          if (totalConsumedCalories > targetCalories)
            _buildExceedingCaloriesWarning(),
          _buildViewMealPlanButton(),
        ],
      ),
    );
  }

  Widget _buildTargetCaloriesInput() {
    return Padding(
      padding: const EdgeInsets.all(19.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Target Calories:'),
            SizedBox(height: 8),
            Container(
              width: 200,
              child: TextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  setState(() {
                    targetCalories = int.parse(value);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDateRow() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Date Selected: ${_formatDate(selectedDate)}'),
              IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddFoodButton() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _addFood,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(20.0),
                ),
                child: Text(
                  'Add Food',
                  style: TextStyle(fontSize: 22.0),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalConsumedCaloriesText() {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Center(
        child: Text(
          'Total Calories Consumed = $totalConsumedCalories',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildExceedingCaloriesWarning() {
    return Text(
      'Warning: Exceeding Target Calories!',
      style: TextStyle(color: Colors.red),
    );
  }

  Widget _buildViewMealPlanButton() {
    return Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
            onPressed: _viewMealPlan,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(17.0),
            ),
            child: Text(
              'View Meal Plan',
              style: TextStyle(fontSize: 20.0),
            )));
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 5),
      ),
    );
  }
}
