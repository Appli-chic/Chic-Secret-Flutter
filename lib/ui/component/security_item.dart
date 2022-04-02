import 'package:flutter/material.dart';

class SecurityItem extends StatelessWidget {
  final int securityIndex;
  final String title;
  final Color color;
  final IconData icon;
  final int number;
  final Function(String, int) onTap;

  const SecurityItem({
    required this.securityIndex,
    required this.title,
    required this.color,
    required this.icon,
    required this.number,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 25),
                Container(
                  margin: EdgeInsets.only(left: 8),
                  child: Text(
                    number.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 12),
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ));

    // return Card(
    //   color: themeProvider.secondBackgroundColor,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(6.0),
    //   ),
    //   child: ListTile(
    //     onTap: () {
    //       onTap(title, securityIndex);
    //     },
    //     contentPadding: EdgeInsets.only(top: 3, bottom: 3, left: 12, right: 12),
    //     leading: Container(
    //       width: 40,
    //       height: 40,
    //       padding: EdgeInsets.all(8),
    //       decoration: BoxDecoration(
    //         color: color,
    //         borderRadius: BorderRadius.all(Radius.circular(6)),
    //       ),
    //       child: Center(
    //         child: Text(
    //           number.toString(),
    //           style: TextStyle(
    //             color: themeProvider.textColor,
    //             fontSize: 20,
    //             fontWeight: FontWeight.bold,
    //           ),
    //         ),
    //       ),
    //     ),
    //     title: Container(
    //       margin: EdgeInsets.only(left: 8),
    //       child: Text(
    //         title,
    //         style: TextStyle(
    //           fontWeight: FontWeight.w600,
    //           fontSize: 18,
    //           color: themeProvider.textColor,
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
