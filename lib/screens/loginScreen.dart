import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:forestapp/screens/homeScreen.dart';

import '../common/themeHelper.dart';


// import 'forgot_password_page.dart';
// import 'profile_page.dart';
// import 'registration_page.dart';
// import 'widgets/header_widget.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({Key? key}): super(key:key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>{
  final double _headerHeight = 250;
  final Key _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(

            children: [

              SafeArea(

                child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 200, 20, 10),
                    margin: EdgeInsets.fromLTRB(20, 10, 20, 10),// This will be the login form
                    child: Column(
                      children: [
                        const Text(
                          'Signin into your account',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 30.0),
                        Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Container(
                                  decoration: ThemeHelper().inputBoxDecorationShaddow(),
                                  child: TextField(
                                    decoration: ThemeHelper().textInputDecoration('User Name', 'Enter your user name'),
                                  ),
                                ),
                                const SizedBox(height: 30.0),
                                Container(
                                  decoration: ThemeHelper().inputBoxDecorationShaddow(),
                                  child: TextField(
                                    obscureText: true,
                                    decoration: ThemeHelper().textInputDecoration('Password', 'Enter your password'),
                                  ),
                                ),
                                const SizedBox(height: 15.0),
                                Container(
                                  margin: const EdgeInsets.fromLTRB(10,0,10,20),
                                  alignment: Alignment.topRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      // Navigator.push( context, MaterialPageRoute( builder: (context) => ForgotPasswordPage()), );
                                    },
                                    child: const Text( "Forgot your password?", style: TextStyle( color: Colors.grey, ),
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: ThemeHelper().buttonBoxDecoration(context),
                                  child: ElevatedButton(
                                    style: ThemeHelper().buttonStyle(),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                                      child: Text('Sign In'.toUpperCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
                                    ),
                                    onPressed: (){
                                      //After successful login we will redirect to profile page. Let's create profile page now
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                                    },
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.fromLTRB(10,20,10,20),
                                  //child: Text('Don\'t have an account? Create'),

                                ),
                              ],
                            )
                        ),
                      ],
                    )
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }
}








// import 'package:flutter/material.dart';
//
// import '../services/firebase_auth_methods.dart';
// import '../widgets/custom_textfield.dart';
// import 'package:provider/provider.dart';
//
// class LoginScreen extends StatefulWidget {
//   static String routeName = '/login-email-password';
//   const LoginScreen({Key? key}) : super(key: key);
//
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//
//   void loginUser() {
//     context.read<FirebaseAuthMethods>().loginWithEmail(
//       email: emailController.text,
//       password: passwordController.text,
//       context: context,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Text(
//             "Login",
//             style: TextStyle(fontSize: 30),
//           ),
//           SizedBox(height: MediaQuery.of(context).size.height * 0.08),
//           Container(
//             margin: const EdgeInsets.symmetric(horizontal: 20),
//             child: CustomTextField(
//               controller: emailController,
//               hintText: 'Enter your email',
//             ),
//           ),
//           const SizedBox(height: 20),
//           Container(
//             margin: const EdgeInsets.symmetric(horizontal: 20),
//             child: CustomTextField(
//               controller: passwordController,
//               hintText: 'Enter your password',
//             ),
//           ),
//           const SizedBox(height: 40),
//           ElevatedButton(
//             onPressed: loginUser,
//             style: ButtonStyle(
//               backgroundColor: MaterialStateProperty.all(Colors.blue),
//               textStyle: MaterialStateProperty.all(
//                 const TextStyle(color: Colors.white),
//               ),
//               minimumSize: MaterialStateProperty.all(
//                 Size(MediaQuery.of(context).size.width / 2.5, 50),
//               ),
//             ),
//             child: const Text(
//               "Login",
//               style: TextStyle(color: Colors.white, fontSize: 16),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }