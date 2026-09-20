import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  String _expression = '';

  void _onPressed(String text) async {
    setState(() {
      if (text == 'AC') {
        _display = '0';
        _expression = '';
      } else if (text == 'DEL') {
        if (_display == 'Error') {
          _display = '0';
        } else {
          _display = _display.length > 1
              ? _display.substring(0, _display.length - 1)
              : '0';
        }
      } else if (text == '+/-') {
        if (_display != '0' && _display != 'Error') {
          _display = _display.startsWith('-')
              ? _display.substring(1)
              : '-$_display';
        }
      } else if (text == '=') {
        try {
          _expression = _display;

          // Convert visual operators to parsable math operators
          String mathExpr = _expression
              .replaceAll('×', '*')
              .replaceAll('%', '/100');

          Parser p = Parser();
          Expression exp = p.parse(mathExpr);
          ContextModel cm = ContextModel();

          double eval = exp.evaluate(EvaluationType.REAL, cm);

          // Format the result to remove trailing '.0' for whole numbers
          _display = eval.toString();
          if (_display.endsWith('.0')) {
            _display = _display.substring(0, _display.length - 2);
          }
        } catch (e) {
          _display = 'Error';
        }
      } else {
        // Prevent appending to an error state
        if (_display == 'Error') {
          _display = text;
        } else {
          _display = (_display == '0') ? text : _display + text;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Calculator'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        shape: Border(bottom: BorderSide(color: Colors.black, width: 2)),
      ),
      // SafeArea prevents the UI from hiding under the status bar or notch
      body: Column(
        children: [
          // Display Area - Flex 2 ensures it takes 40% of the screen
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _expression,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      _display,
                      style: GoogleFonts.inter(
                        fontSize: 72,
                        fontWeight: FontWeight.w300,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Buttons Grid - Flex 3 ensures it takes exactly 60% of the screen
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                border: Border(top: BorderSide(color: Colors.black, width: 2)),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: _buildRow(context, [
                      'AC',
                      '+/-',
                      '%',
                      '/',
                    ], isAction: true),
                  ),
                  Expanded(child: _buildRow(context, ['7', '8', '9', '×'])),
                  Expanded(child: _buildRow(context, ['4', '5', '6', '-'])),
                  Expanded(child: _buildRow(context, ['1', '2', '3', '+'])),
                  Expanded(
                    child: _buildRow(context, [
                      '0',
                      '.',
                      'DEL',
                      '=',
                    ], isLast: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    List<String> labels, {
    bool isAction = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: labels.map((label) {
          return _buildButton(context, label, flex: 1, isAction: isAction);
        }).toList(),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String label, {
    int flex = 1,
    bool isAction = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    bool isEqual = label == '=';
    bool isOperator = ['+', '-', '×', '/', 'DEL'].contains(label);

    // Material 3 Color Mapping
    Color bgColor;
    Color textColor;

    if (isEqual) {
      bgColor = colorScheme.primary;
      textColor = colorScheme.onPrimary;
    } else if (isAction) {
      bgColor = colorScheme.secondaryContainer;
      textColor = colorScheme.onSecondaryContainer;
    } else if (isOperator) {
      bgColor = colorScheme.tertiaryContainer;
      textColor = colorScheme.onTertiaryContainer;
    } else {
      bgColor = colorScheme.surfaceContainerHighest;
      textColor = colorScheme.onSurface;
    }

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: textColor,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          onPressed: () => _onPressed(label),
          child: Center(
            child: label == 'DEL'
                ? Icon(LucideIcons.delete, color: textColor)
                : Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: isEqual || isOperator || isAction
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
