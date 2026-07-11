import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class MedicalReport {
  final String name;
  final String type;
  final DateTime uploadedAt;
  final File file;

  MedicalReport({
    required this.name,
    required this.type,
    required this.uploadedAt,
    required this.file,
  });
}

class MedicalReportsScreen extends StatefulWidget {
  const MedicalReportsScreen({super.key});

  @override
  State<MedicalReportsScreen> createState() => _MedicalReportsScreenState();
}

class _MedicalReportsScreenState extends State<MedicalReportsScreen> {

  final List<MedicalReport> reports = [];
  bool uploading = false;

  Future<void> pickReport() async {

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf','jpg','jpeg','png'],
    );

    if(result == null) return;

    final file = result.files.single;

    setState(() {
      reports.add(
        MedicalReport(
          name: file.name,
          type: file.extension ?? "",
          uploadedAt: DateTime.now(),
          file: File(file.path!),
        ),
      );
    });
  }

  void deleteReport(int index){

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Report"),
        content: const Text(
            "Are you sure you want to delete this report?"),
        actions: [

          TextButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),

          TextButton(
            onPressed: (){
              setState(() {
                reports.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          )
        ],
      ),
    );
  }

  Icon fileIcon(String type){

    type = type.toLowerCase();

    if(type == "pdf"){
      return const Icon(
        Icons.picture_as_pdf,
        color: Colors.red,
        size: 38,
      );
    }

    return const Icon(
      Icons.image,
      color: Colors.green,
      size: 38,
    );
  }

  String formatDate(DateTime date){
    return "${date.day}/${date.month}/${date.year}";
  }

  void previewReport(MedicalReport report){

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      builder: (_) {

        if(report.type == "jpg" ||
            report.type == "jpeg" ||
            report.type == "png"){

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Text(
                  report.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height:15),

                Image.file(
                  report.file,
                  height: 250,
                )
              ],
            ),
          );
        }

        return const Padding(
          padding: EdgeInsets.all(25),
          child: Text(
            "PDF preview will be available after Firebase integration.",
          ),
        );
      },
    );
  }

  Widget emptyState(){

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Icon(
            Icons.medical_information_outlined,
            size: 70,
            color: Colors.grey,
          ),

          SizedBox(height:16),

          Text(
            "No Medical Reports",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height:6),

          Text(
            "Upload prescriptions, scans or lab reports",
            style: TextStyle(color: Colors.grey),
          )
        ],
      ),
    );
  }

  Widget reportCard(MedicalReport report,int index){

    return Container(
      margin: const EdgeInsets.only(bottom:14),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
          )
        ],
      ),

      child: Row(
        children: [

          fileIcon(report.type),

          const SizedBox(width:14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  report.name,
                  maxLines:1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize:15,
                  ),
                ),

                const SizedBox(height:4),

                Text(
                  "${report.type.toUpperCase()} • Uploaded ${formatDate(report.uploadedAt)}",
                  style: const TextStyle(
                    fontSize:12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          TextButton(
            onPressed: (){
              previewReport(report);
            },
            child: const Text("View"),
          ),

          IconButton(
            onPressed: (){
              deleteReport(index);
            },
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.red,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Medical Reports"),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: pickReport,
        icon: const Icon(Icons.upload_file),
        label: const Text("Upload Report"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: reports.isEmpty
            ? emptyState()

            : ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context,index){
            return reportCard(reports[index],index);
          },
        ),
      ),
    );
  }
}