import 'package:flutter/material.dart';
import 'customer.dart';
import 'database.dart';

class CustomerPage extends StatefulWidget {
  @override
  _CustomerPageState createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final DatabaseService _databaseService = DatabaseService();
  final List<Customer> _customers = [];
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  DateTime? _selectedBirthday;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final customers = await _databaseService.getCustomers();
    setState(() {
      _customers.clear();
      _customers.addAll(customers);
    });
  }

  void _showCustomerDialog({Customer? customer}) {
    if (customer != null) {
      _firstNameController.text = customer.firstName;
      _lastNameController.text = customer.lastName;
      _addressController.text = customer.address;
      _selectedBirthday = customer.birthday;
    } else {
      _firstNameController.clear();
      _lastNameController.clear();
      _addressController.clear();
      _selectedBirthday = null;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(customer == null ? 'Add Customer' : 'Edit Customer'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a first name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a last name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),
              TextButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedBirthday = date;
                    });
                  }
                },
                child: Text(
                  _selectedBirthday == null
                      ? 'Select Birthday'
                      : 'Birthday: ${_selectedBirthday!.toLocal()}'.split(' ')[0],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final firstName = _firstNameController.text;
                final lastName = _lastNameController.text;
                final address = _addressController.text;
                final birthday = _selectedBirthday;

                if (customer == null) {
                  await _databaseService.addCustomer(Customer(
                    firstName: firstName,
                    lastName: lastName,
                    address: address,
                    birthday: birthday!,
                  ));
                } else {
                  await _databaseService.updateCustomer(Customer(
                    id: customer.id,
                    firstName: firstName,
                    lastName: lastName,
                    address: address,
                    birthday: birthday!,
                  ));
                }

                _loadCustomers();
                Navigator.of(context).pop();
              }
            },
            child: Text(customer == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _deleteCustomer(int id) async {
    await _databaseService.deleteCustomer(id);
    _loadCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer List'),
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('How to use'),
                  content: Text(
                      'This application allows you to manage a list of customers. You can add, update, and delete customer information.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _customers.length,
        itemBuilder: (context, index) {
          final customer = _customers[index];
          return ListTile(
            title: Text('${customer.firstName} ${customer.lastName}'),
            subtitle: Text(customer.address),
            onTap: () => _showCustomerDialog(customer: customer),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteCustomer(customer.id!),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCustomerDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}
