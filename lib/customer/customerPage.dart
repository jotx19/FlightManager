import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../customer/database.dart';
import 'customer.dart';

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
  final _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _loadLastCustomer();
  }

  Future<void> _loadCustomers() async {
    try {
      final customers = await _databaseService.getCustomers();
      setState(() {
        _customers.clear();
        _customers.addAll(customers);
      });
    } catch (e) {
      _showSnackbar('Error loading customers: $e');
    }
  }

  Future<void> _loadLastCustomer() async {
    _firstNameController.text = await _storage.read(key: 'firstName') ?? '';
    _lastNameController.text = await _storage.read(key: 'lastName') ?? '';
    _addressController.text = await _storage.read(key: 'address') ?? '';
    String? birthdayStr = await _storage.read(key: 'birthday');
    if (birthdayStr != null) {
      setState(() {
        _selectedBirthday = DateTime.parse(birthdayStr);
      });
    }
  }

  Future<void> _saveLastCustomer() async {
    await _storage.write(key: 'firstName', value: _firstNameController.text);
    await _storage.write(key: 'lastName', value: _lastNameController.text);
    await _storage.write(key: 'address', value: _addressController.text);
    if (_selectedBirthday != null) {
      await _storage.write(
          key: 'birthday', value: _selectedBirthday!.toIso8601String());
    }
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

                try {
                  if (customer == null) {
                    await _databaseService.addCustomer(Customer(
                      firstName: firstName,
                      lastName: lastName,
                      address: address,
                      birthday: birthday!,
                    ));
                    _showSnackbar('Customer added successfully.');
                  } else {
                    await _databaseService.updateCustomer(Customer(
                      id: customer.id,
                      firstName: firstName,
                      lastName: lastName,
                      address: address,
                      birthday: birthday!,
                    ));
                    _showSnackbar('Customer updated successfully.');
                  }

                  _saveLastCustomer();
                  _loadCustomers();
                  Navigator.of(context).pop();
                } catch (e) {
                  _showSnackbar('Error saving customer: $e');
                }
              }
            },
            child: Text(customer == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _deleteCustomer(int id) async {
    try {
      await _databaseService.deleteCustomer(id);
      _showSnackbar('Customer deleted successfully.');
      _loadCustomers();
    } catch (e) {
      _showSnackbar('Error deleting customer: $e');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
