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
    return GestureDetector(
      onTap: () {
        if(number != 0) {
          onTap(title, securityIndex);
        }
      },
      child: Container(
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
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
