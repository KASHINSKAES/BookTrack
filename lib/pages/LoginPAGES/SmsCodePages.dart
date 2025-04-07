import 'dart:ui';

import 'package:booktrack/pages/LoginPAGES/AuthEnums.dart';
import 'package:booktrack/pages/LoginPAGES/DetailPainterBlobAuth.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class CodeVerificationScreen extends StatefulWidget {
  final String? phoneNumber;
  final String? email;
  final bool isEmail;
  final Future<VerificationStatus> Function(String) onCodeVerified;

  const CodeVerificationScreen({
    super.key,
    this.phoneNumber,
    this.email,
    required this.isEmail,
    required this.onCodeVerified,
  });

  @override
  State<CodeVerificationScreen> createState() => _CodeVerificationScreenState();
}

class _CodeVerificationScreenState extends State<CodeVerificationScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: AnimatedWaveScreenAuthWrap(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Введите 6-значный код, отправленный на ${widget.isEmail ? widget.email : widget.phoneNumber}',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Pinput(
                  length: 6,
                  controller: _codeController,
                  defaultPinTheme: PinTheme(
                    width: 56,
                    height: 56,
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(
                      Size(
                        260 * scale.clamp(0.5, 2.0),
                        35 * scale.clamp(0.5, 2.0),
                      ),
                    ),
                    side: MaterialStateProperty.all(
                      const BorderSide(
                        color: AppColors.background,
                        width: 2,
                      ),
                    ),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          final enteredCode = _codeController.text;
                          if (enteredCode.length != 6) {
                            setState(() => _errorMessage = 'Введите 6 цифр');
                            return;
                          }

                          setState(() {
                            _isLoading = true;
                            _errorMessage = null;
                          });

                          try {
                            final status = await widget.onCodeVerified(enteredCode);

                            switch (status) {
                              case VerificationStatus.existingUser:
                                Navigator.pop(context, status);
                                break;
                              case VerificationStatus.newUser:
                                Navigator.pop(context, status);
                                break;
                              case VerificationStatus.invalidCode:
                                setState(() => _errorMessage = 'Неверный код');
                                break;
                              case VerificationStatus.error:
                                setState(() => _errorMessage = 'Ошибка сервера');
                            }
                          } catch (e) {
                            setState(() => _errorMessage = 'Ошибка: ${e.toString()}');
                          } finally {
                            if (mounted) setState(() => _isLoading = false);
                          }
                        },
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Подтвердить',
                          style: TextStyle(
                              fontSize: 20, color: AppColors.textPrimary)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Назад',
                      style: TextStyle(
                          fontSize: 20, color: AppColors.textPrimary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
