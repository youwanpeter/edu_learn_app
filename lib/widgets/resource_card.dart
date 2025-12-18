import 'package:flutter/material.dart';

class ResourceCard extends StatelessWidget {
  final String title;
  final String description;
  final String type;
  final bool canEdit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDownload;

  const ResourceCard({
    super.key,
    required this.title,
    required this.description,
    required this.type,
    required this.canEdit,
    required this.onEdit,
    required this.onDelete,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.only(bottom: h * 0.015),
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(w * 0.04),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Icon(
            type == 'pdf'
                ? Icons.picture_as_pdf
                : type == 'doc'
                ? Icons.description
                : Icons.play_circle,
            size: w * 0.08,
            color: Colors.blueAccent,
          ),
          SizedBox(width: w * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: w * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: h * 0.005),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: w * 0.035,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (canEdit)
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    size: w * 0.06,
                    color: Colors.blueAccent,
                  ),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    size: w * 0.06,
                    color: Colors.blueAccent,
                  ),
                  onPressed: onDelete,
                ),
              ],
            )
          else
            IconButton(
              icon: Icon(
                Icons.download,
                size: w * 0.06,
                color: Colors.blueAccent,
              ),
              onPressed: onDownload,
            ),
        ],
      ),
    );
  }
}
