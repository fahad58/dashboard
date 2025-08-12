//import 'package:flutter/foundation.dart';
import 'package:dashboard_ui/const/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart';

class PDFViewerScreen extends StatefulWidget {
  final String pdfPath;
  final String? pdfTitle;

  const PDFViewerScreen({
    super.key,
    required this.pdfPath,
    this.pdfTitle,
  });

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  int totalPages = 0;
  int currentPage = 0;
  bool pdfReady = false;
  PDFViewController? _pdfViewController;

  Future<void> shareViaEmail() async {
    final XFile file = XFile(widget.pdfPath);
    await Share.shareXFiles(
      [file],
      subject: 'PDF Document via Email',
      text: 'Please find the attached PDF document',
    );
  }

  void showEmailSharePopup() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Brief automatisch versenden',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Text(
                  "Sie können das Schreiben auch durch uns vollkommen automatisiert versenden."),
              Text(
                  "Dabei kümmern wir uns um die Verarbeitung des Briefes und der Aussendung."),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(icolor.blue)),
                    onPressed: () {
                      Navigator.pop(context); // Close the bottom sheet
                      shareViaEmail(); // Call the share function
                    },
                    icon: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Teilen',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(icolor.blue)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Abbrechen',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    height: 120,
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.pdfTitle ?? 'PDF Viewer',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: icolor.blue,
        toolbarHeight: 110,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: icolor.gray,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.email,
              color: icolor.gray,
            ),
            onPressed: showEmailSharePopup,
            tooltip: 'Share PDF via Email',
          ),
          //send the PDF to the API you want to write
          IconButton(
            icon: const Icon(
              Icons.share,
              color: icolor.gray,
            ),
            onPressed: shareViaEmail,
          ),
        ],
      ),
      body: PDFView(
        filePath: widget.pdfPath,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        pageSnap: true,
        defaultPage: currentPage,
        fitPolicy: FitPolicy.BOTH,
        preventLinkNavigation: false,
        onRender: (pages) {
          setState(() {
            totalPages = pages!;
            pdfReady = true;
          });
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading PDF: $error')),
          );
        },
        onPageError: (page, error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error on page $page: $error')),
          );
        },
        onViewCreated: (PDFViewController pdfViewController) {
          setState(() {
            _pdfViewController = pdfViewController;
          });
        },
        onPageChanged: (int? page, int? total) {
          setState(() {
            currentPage = page!;
          });
        },
      ),
    );
  }
}

class PDFLoaderScreen extends StatefulWidget {
  String pdfPath;
  PDFLoaderScreen({super.key, required this.pdfPath});

  @override
  State<PDFLoaderScreen> createState() =>
      _PDFLoaderScreenState(pdfPath: pdfPath);
}

class _PDFLoaderScreenState extends State<PDFLoaderScreen> {
  String pdfPath;
  _PDFLoaderScreenState({required this.pdfPath});
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PDFViewerScreen(
      pdfPath: pdfPath,
      pdfTitle: 'PDF',
    );
  }
}
