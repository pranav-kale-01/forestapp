// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:forestapp/utils/user_service.dart';
import '../common/themeHelper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Key _formKey = GlobalKey<FormState>();
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SafeArea(
                child: Container(
                    padding: const EdgeInsets.fromLTRB( 20, 100, 20, 10),
                    margin: const EdgeInsets.fromLTRB( 10, 10, 10, 10),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 130,
                          child: Image.asset('assets/splash_screen.jpg'),
                        ),

                        const SizedBox(
                          height: 90,
                        ),

                        Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Container(
                                  decoration:
                                      ThemeHelper().inputBoxDecorationShaddow(),
                                  child: TextFormField(
                                    controller: _emailController,
                                    decoration: ThemeHelper()
                                        .textInputDecoration(
                                        'Email', 'Email'),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter your email address';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(height: 20.0),
                                Container(
                                  decoration:
                                      ThemeHelper().inputBoxDecorationShaddow(),
                                  child: TextFormField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    decoration: ThemeHelper()
                                        .textInputDecoration(
                                            'Password', 'Password'),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(height: 40.0),
                                
                                Container(
                                  padding: const EdgeInsets.fromLTRB(
                                      0, 5, 0, 5
                                  ),
                                  width: mediaQuery.size.width,
                                  constraints: BoxConstraints(
                                    maxWidth: 350,
                                  ),
                                  decoration: ThemeHelper().buttonBoxDecoration(context),
                                  child: ElevatedButton(
                                    style: ThemeHelper().buttonStyle(),
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    onPressed: () async {
                                      UserService.loginAsUser( context, _emailController.text.trim(), _passwordController.text.trim() );
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(
                                    0, 5, 0, 5
                                  ),
                                  decoration: ThemeHelper().buttonBoxDecoration(context),
                                  width: mediaQuery.size.width,
                                  constraints: BoxConstraints(
                                    maxWidth: 350,
                                  ),
                                  child: ElevatedButton(
                                    style: ThemeHelper().buttonStyle(),
                                    child: const Text(
                                      'Login as admin',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    onPressed: () async {
                                      UserService.loginAsAdmin(  context, _emailController.text.trim(), _passwordController.text.trim()  );
                                    },
                                  ),
                                ),
                                Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(10, 20, 10, 20),
                                  //child: Text('Don\'t have an account? Create'),
                                ),
                              ],
                            )),
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
