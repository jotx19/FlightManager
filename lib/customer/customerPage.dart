import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../customer/database.dart';
import 'customer.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

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
  final _storage = const FlutterSecureStorage();
  bool _copyPrevious = false;

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
    if (_copyPrevious) {
      _firstNameController.text = await _storage.read(key: 'firstName') ?? '';
      _lastNameController.text = await _storage.read(key: 'lastName') ?? '';
      _addressController.text = await _storage.read(key: 'address') ?? '';
      String? birthdayStr = await _storage.read(key: 'birthday');
      if (birthdayStr != null) {
        setState(() {
          _selectedBirthday = DateTime.parse(birthdayStr);
        });
      }
    } else {
      _clearFields();
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

  void _clearFields() {
    setState(() {
      _firstNameController.clear();
      _lastNameController.clear();
      _addressController.clear();
      _selectedBirthday = null;
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          customer == null ? 'Add Customer' : 'Edit Customer',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (customer == null)
                SwitchListTile(
                  title: const Text('Copy from previous customer'),
                  value: _copyPrevious,
                  onChanged: (bool value) {
                    setState(() {
                      _copyPrevious = value;
                      _loadLastCustomer();
                    });
                  },
                ),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a first name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a last name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
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
                  style: const TextStyle(color: Colors.blue),
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
            child: const Text('Cancel'),
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
        title: const Text(
          'Customer List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Customer Management',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Main Page'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pop(context); // Navigate to the main page
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('How to use'),
                    content: const Text(
                        'This application allows you to manage a list of customers. You can add, update, and delete customer information.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Customer Service'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Customer Service'),
                    content: Image.asset(
                      'assets/customer.jpg',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Image at the top
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/service.jpg',
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: _customers.length,
                itemBuilder: (context, index) {
                  final customer = _customers[index];
                  return Dismissible(
                    key: Key(customer.id.toString()),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      _deleteCustomer(customer.id!);
                    },
                    background: Container(
                      color: Colors.redAccent,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      elevation: 5,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          child: Text(
                            customer.firstName[0],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24),
                          ),
                        ),
                        title: Text(
                          '${customer.firstName} ${customer.lastName}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(customer.address),
                        onTap: () => _showCustomerDialog(customer: customer),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () =>
                              _showCustomerDialog(customer: customer),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCustomerDialog(),
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }
}
