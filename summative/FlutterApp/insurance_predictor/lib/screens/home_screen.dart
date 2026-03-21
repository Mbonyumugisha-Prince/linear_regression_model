import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../widgets/input_field.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey          = GlobalKey<FormState>();
  final _ageController    = TextEditingController();
  final _bmiController    = TextEditingController();
  final _childrenController = TextEditingController();
  final _scrollController = ScrollController();

  String? _sex;
  String? _smoker;
  String? _region;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
  }


  @override
  void dispose() {
    _ageController.dispose();
    _bmiController.dispose();
    _childrenController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Show result as popup bottom sheet ──────────────────────────────────────
  void _showResultSheet(String result) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF12121E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // drag handle
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 28),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 255, 255, 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Estimated Insurance Charge',
              style: GoogleFonts.sora(
                color: const Color.fromRGBO(255, 255, 255, 0.5),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              result,
              style: GoogleFonts.sora(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.w700,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'per year',
              style: GoogleFonts.sora(
                color: const Color.fromRGBO(255, 255, 255, 0.35),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Close',
                  style: GoogleFonts.sora(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Show error as popup bottom sheet ───────────────────────────────────────
  void _showErrorSheet(String error) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A0E0E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 28),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 80, 80, 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Prediction Failed',
              style: GoogleFonts.sora(
                color: const Color(0xFFFF6B6B),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: GoogleFonts.sora(
                color: const Color.fromRGBO(255, 255, 255, 0.7),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 80, 80, 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color.fromRGBO(255, 80, 80, 0.3),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Close',
                  style: GoogleFonts.sora(
                    color: const Color(0xFFFF6B6B),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _predict() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final data = await ApiService.predictCharge(
        age:      int.parse(_ageController.text.trim()),
        sex:      _sex!,
        bmi:      double.parse(_bmiController.text.trim()),
        children: int.parse(_childrenController.text.trim()),
        smoker:   _smoker!,
        region:   _region!,
      );
      _showResultSheet(data['predicted_charge'] as String);
    } catch (e) {
      _showErrorSheet(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _chip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(255, 255, 255, 0.07),
          border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.10)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: GoogleFonts.sora(
            color: const Color.fromRGBO(255, 255, 255, 0.8),
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          text,
          style: GoogleFonts.sora(
            color: const Color.fromRGBO(255, 255, 255, 0.45),
            fontSize: 12,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060608),


      body: Stack(
        children: [
          // Background glow
          Positioned(
            top: -80, right: -80,
            child: Container(
              width: 320, height: 320,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color.fromRGBO(80, 80, 160, 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // ── Greeting + chips (hides on scroll down) ──────────────────
              SliverAppBar(
                backgroundColor:          const Color(0xFF060608),
                surfaceTintColor:         Colors.transparent,
                shadowColor:              Colors.transparent,
                floating:                 true,
                snap:                     true,
                automaticallyImplyLeading: false,
                toolbarHeight:            0,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(280),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 36, 24, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi there',
                          style: GoogleFonts.sora(
                            color: const Color.fromRGBO(255, 255, 255, 0.45),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'What\'s your insurance cost?',
                          style: GoogleFonts.sora(
                            color: const Color.fromRGBO(255, 255, 255, 0.9),
                            fontSize: 26,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          children: [
                            _chip('Non-smoker, 25yo', () {
                              _ageController.text      = '25';
                              _bmiController.text      = '22.0';
                              _childrenController.text = '0';
                              setState(() {
                                _sex    = 'male';
                                _smoker = 'no';
                                _region = 'southwest';
                              });
                            }),
                            _chip('Smoker, 45yo', () {
                              _ageController.text      = '45';
                              _bmiController.text      = '32.5';
                              _childrenController.text = '2';
                              setState(() {
                                _sex    = 'female';
                                _smoker = 'yes';
                                _region = 'southeast';
                              });
                            }),
                            _chip('Senior, 60yo', () {
                              _ageController.text      = '60';
                              _bmiController.text      = '28.0';
                              _childrenController.text = '1';
                              setState(() {
                                _sex    = 'male';
                                _smoker = 'no';
                                _region = 'northwest';
                              });
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Form ─────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Age (18 – 64)'),
                        AppTextField(
                          hint: 'Enter age',
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final n = int.tryParse(v ?? '');
                            if (n == null) return 'Enter a valid number';
                            if (n < 18 || n > 64) return 'Age must be 18–64';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        _label('BMI (10.0 – 60.0)'),
                        AppTextField(
                          hint: 'Enter BMI e.g. 28.5',
                          controller: _bmiController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) {
                            final n = double.tryParse(v ?? '');
                            if (n == null) return 'Enter a valid number';
                            if (n < 10 || n > 60) return 'BMI must be 10–60';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        _label('Number of children (0 – 5)'),
                        AppTextField(
                          hint: 'Enter number of children',
                          controller: _childrenController,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final n = int.tryParse(v ?? '');
                            if (n == null) return 'Enter a valid number';
                            if (n < 0 || n > 5) return 'Children must be 0–5';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        _label('Sex'),
                        AppDropdown(
                          hint: 'Select sex',
                          value: _sex,
                          items: const ['male', 'female'],
                          onChanged: (v) => setState(() => _sex = v),
                          validator: (v) => v == null ? 'Please select sex' : null,
                        ),
                        const SizedBox(height: 14),

                        _label('Smoker'),
                        AppDropdown(
                          hint: 'Are you a smoker?',
                          value: _smoker,
                          items: const ['yes', 'no'],
                          onChanged: (v) => setState(() => _smoker = v),
                          validator: (v) => v == null ? 'Please select smoker status' : null,
                        ),
                        const SizedBox(height: 14),

                        _label('Region'),
                        AppDropdown(
                          hint: 'Select region',
                          value: _region,
                          items: const ['northeast', 'northwest', 'southeast', 'southwest'],
                          onChanged: (v) => setState(() => _region = v),
                          validator: (v) => v == null ? 'Please select region' : null,
                        ),
                        const SizedBox(height: 28),

                        // ── Predict button ──────────────────────────
                        GestureDetector(
                          onTap: _loading ? null : _predict,
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: _loading
                                ? const SizedBox(
                                    width: 22, height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF060608),
                                    ),
                                  )
                                : Text(
                                    'Calculate',
                                    style: GoogleFonts.sora(
                                      color: const Color(0xFF060608),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
