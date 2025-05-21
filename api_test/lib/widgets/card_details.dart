import 'package:api_test/model/imat/credit_card.dart';
import 'package:api_test/model/imat_data_handler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Simple widget to edit card information.
// It's probably better to use Form
class CardDetails extends StatefulWidget {
  const CardDetails({super.key});

  @override
  State<CardDetails> createState() => _CardDetailsState();
}

class _CardDetailsState extends State<CardDetails> {
  late final TextEditingController _typeController;
  late final TextEditingController _nameController;
  late final TextEditingController _monthController;
  late final TextEditingController _yearController;
  late final TextEditingController _numberController;
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();

    var iMat = Provider.of<ImatDataHandler>(context, listen: false);
    CreditCard card = iMat.getCreditCard();

    _typeController = TextEditingController(text: card.cardType);
    _nameController = TextEditingController(text: card.holdersName);
    _monthController = TextEditingController(text: '${card.validMonth}');
    _yearController = TextEditingController(text: '${card.validYear}');
    _numberController = TextEditingController(text: card.cardNumber);
    _codeController = TextEditingController(text: '${card.verificationCode}');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _typeController,
          decoration: InputDecoration(labelText: 'Kortnummer'),
        ),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(labelText: 'Namn'),
        ),
        TextField(
          controller: _monthController,
          decoration: InputDecoration(labelText: 'Giltigt månad (1-12)'),
        ),
        TextField(
          controller: _yearController,
          decoration: InputDecoration(labelText: 'Giltigt år'),
        ),
        TextField(
          controller: _codeController,
          decoration: InputDecoration(labelText: 'CVV-kod'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(onPressed: _saveCard, child: Text('Spara')),
          ],
        ),
      ],
    );
  }

  _saveCard() {
    var iMat = Provider.of<ImatDataHandler>(context, listen: false);
    CreditCard card = iMat.getCreditCard();

    card.cardType = _typeController.text;
    card.holdersName = _nameController.text;
    card.validMonth = int.parse(_monthController.text);
    card.validYear = int.parse(_yearController.text);
    card.cardNumber = _numberController.text;
    card.verificationCode = int.parse(_codeController.text);

    // This needed to trigger update to the server
    iMat.setCreditCard(card);
  }
}
