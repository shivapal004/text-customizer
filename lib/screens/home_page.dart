import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<EditableTextWidget> textWidgets = [];

  final List<String> fonts = [
    'Roboto',
    'Lobster',
    'DancingScript',
    'Montserrat'
  ];

  String selectedFont = 'Font';
  bool isBold = false;
  bool isItalic = false;
  bool isUnderline = false;
  List<List<EditableTextWidget>> undoStack = [];
  List<List<EditableTextWidget>> redoStack = [];

  double fontSize = 16.0;

  void _increaseFontSize() {
    setState(() {
      if (fontSize < 50) fontSize += 1;
    });
  }

  void _decreaseFontSize() {
    setState(() {
      if (fontSize > 10) fontSize -= 1;
    });
  }

  void addTextWidget() {
    setState(() {
      textWidgets.add(
        EditableTextWidget(
          id: DateTime.now().millisecondsSinceEpoch,
          fontSize: fontSize,
          isBold: isBold,
          isItalic: isItalic,
          isUnderline: isUnderline,
          position: const Offset(50.0, 50.0),
          selectedFont: selectedFont,
          onDelete: (int id) {
            setState(() {
              textWidgets.removeWhere(
                  (widget) => widget.id == id);
            });
          },
        ),
      );
      saveStateToUndo();
    });
  }

  void undo() {
    if (undoStack.isNotEmpty) {
      redoStack.add(List.from(textWidgets));
      setState(() {
        textWidgets = undoStack.removeLast();
      });
    }
  }

  void redo() {
    if (redoStack.isNotEmpty) {
      undoStack.add(List.from(textWidgets));
      setState(() {
        textWidgets = redoStack.removeLast();
      });
    }
  }

  void saveStateToUndo() {
    undoStack.add(List.from(textWidgets));
    redoStack.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Customizer'),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: undo,
                  child: const Column(
                    children: [Icon(Icons.undo), Text("undo")],
                  ),
                ),
                TextButton(
                  onPressed: redo,
                  child: const Column(
                    children: [Icon(Icons.redo), Text("redo")],
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                color: Colors.grey[200],
                child: Stack(
                  children: textWidgets,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedFont != 'Font' ? selectedFont : null,
                        hint:
                            const Text('Font', style: TextStyle(fontSize: 12)),
                        isExpanded: true,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedFont = newValue ?? 'Font';
                          });
                        },
                        items:
                            fonts.map<DropdownMenuItem<String>>((String font) {
                          return DropdownMenuItem<String>(
                            value: font,
                            child: Text(
                              font,
                              style: TextStyle(
                                fontFamily: font == 'Font' ? null : font,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.remove,
                            size: 18,
                          ),
                          onPressed: _decreaseFontSize,
                        ),
                        Text(
                          fontSize.toStringAsFixed(0),
                          style: const TextStyle(fontSize: 14),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.add,
                            size: 18,
                          ),
                          onPressed: _increaseFontSize,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_bold),
                    onPressed: () {
                      setState(() {
                        isBold = !isBold;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_italic),
                    onPressed: () {
                      setState(() {
                        isItalic = !isItalic;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_underline),
                    onPressed: () {
                      setState(() {
                        isUnderline = !isUnderline;
                      });
                    },
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: addTextWidget,
              child: const Text('Add text'),
            ),
          ],
        ),
      ),
    );
  }
}

class EditableTextWidget extends StatefulWidget {
  final int id;
  final double fontSize;
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final Offset position;
  final String selectedFont;
  final Function(int) onDelete;

  const EditableTextWidget({
    super.key,
    required this.id,
    required this.fontSize,
    required this.isBold,
    required this.isItalic,
    required this.isUnderline,
    required this.position,
    required this.selectedFont,
    required this.onDelete,
  });

  @override
  EditableTextWidgetState createState() => EditableTextWidgetState();
}

class EditableTextWidgetState extends State<EditableTextWidget> {
  late Offset position;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    position = widget.position;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            position = Offset(
              (position.dx + details.delta.dx)
                  .clamp(0.0, MediaQuery.of(context).size.width - 200),
              (position.dy + details.delta.dy)
                  .clamp(0.0, MediaQuery.of(context).size.height - 50),
            );
          });
        },
        onTap: () {
          _focusNode.requestFocus();
        },
        child: Container(
          width: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: Colors.white,
          ),
          child: Stack(
            children: [
              TextField(
                focusNode: _focusNode,
                controller: _controller,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontWeight:
                      widget.isBold ? FontWeight.bold : FontWeight.normal,
                  fontStyle:
                      widget.isItalic ? FontStyle.italic : FontStyle.normal,
                  decoration: widget.isUnderline
                      ? TextDecoration.underline
                      : TextDecoration.none,
                  fontFamily: widget.selectedFont == 'Font'
                      ? null
                      : widget.selectedFont,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(8.0),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  onPressed: () => widget.onDelete(
                      widget.id), // Trigger the delete function with id
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
