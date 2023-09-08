import 'package:flutter/material.dart';
import 'package:forestapp/screens/loginScreen.dart';
import 'package:forestapp/utils/user_service.dart';
import '../common/themeHelper.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({Key? key}) : super(key: key);

  @override
  _AdminLoginState createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final Key _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _OTPController = TextEditingController();
  bool otpSent = false;

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
                                    controller: _phoneController,
                                    decoration: ThemeHelper()
                                        .textInputDecoration(
                                        'Phone Number', 'Enter Your Phone Number'),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter your phone number';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.number,
                                  ),
                                ),

                                // if( otpSent )
                                //   Container(
                                //       alignment: Alignment.topLeft,
                                //       padding: const EdgeInsets.symmetric( vertical: 6.0, horizontal: 6.0, ),
                                //       child: Text("OTP sent..!")
                                //   ),

                                // if( !otpSent )
                                  const SizedBox(height: 10.0),

                                Container(
                                  decoration:
                                  ThemeHelper().inputBoxDecorationShaddow(),
                                  child: TextFormField(
                                    enabled: otpSent,
                                    controller: _OTPController,
                                    obscureText: true,
                                    decoration: ThemeHelper()
                                        .textInputDecoration(
                                        'OTP', 'Enter OTP'),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                GestureDetector(
                                    onTap: ()  async {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) =>  Center(
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      );

                                      // sending Otp
                                      otpSent = await UserService.sendOTP( context, _phoneController.text );

                                      if( otpSent ) {
                                        // show success message
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'OTP Sent to phone number +91 ${_phoneController.text}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                            duration: const Duration(seconds: 4),
                                            backgroundColor: Colors.green,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        );
                                      }

                                      setState(() {});
                                    },
                                    child: Container(
                                      alignment: Alignment.topLeft,
                                      padding: const EdgeInsets.only( top: 16.0, ),
                                      child: Text(
                                        "Resend OTP",
                                        style: TextStyle(
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    )
                                ),
                                const SizedBox(
                                  height: 30,
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
                                    child: Text(
                                      !otpSent ? 'Get OTP' : 'Verify OTP',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    onPressed: () async {
                                      // checking if otp is sent
                                      if( otpSent ) {
                                        // verifying otp and logging in
                                        UserService.loginAsAdmin(  context, _phoneController.text.trim(), _OTPController.text.trim()  );
                                      }
                                      else {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) =>  Center(
                                            child: CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );

                                        // sending Otp
                                        otpSent = await UserService.sendOTP( context, _phoneController.text );

                                        if( otpSent ) {
                                          // show success message
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'OTP Sent to phone number +91 ${_phoneController.text}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              duration: const Duration(seconds: 4),
                                              backgroundColor: Colors.green,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          );
                                        }

                                        setState(() {});
                                      }
                                    },
                                  ),
                                ),
                                GestureDetector(
                                    onTap: () {
                                      // Navigating to Sign in as admin
                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(builder: (context) => LoginScreen() )
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only( top: 16.0, ),
                                      child: Text(
                                        "Sign in as User",
                                        style: TextStyle(
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    )
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
