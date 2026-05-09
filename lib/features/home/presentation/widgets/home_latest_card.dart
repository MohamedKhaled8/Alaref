import 'package:flutter/material.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class HomeLatestCard extends StatelessWidget {
  final String category;
  final String title;
  final String lessons;
  final String imageUrl;

  const HomeLatestCard({
    super.key,
    required this.category,
    required this.title,
    required this.lessons,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(20.sw),
        child: Container(
          width: 240.sw,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.sw),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 16.sw,
                offset: Offset(0, 5.sh),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20.sw),
                    ),
                    child: Image.network(
                      imageUrl,
                      height: 170.sh,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(14.sw),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.sw,
                            vertical: 4.sh,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C853).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8.sw),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: const Color(0xFF00C853),
                              fontSize: 11.spScaled,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.sh),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14.spScaled,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1D2E),
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6.sh),
                        Text(
                          lessons,
                          style: TextStyle(
                            fontSize: 12.spScaled,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.sw,
                    vertical: 4.sh,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.sw),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8.sw,
                        offset: Offset(0, 2.sh),
                      ),
                    ],
                  ),
                  child: Text(
                    'جديد',
                    style: TextStyle(
                      color: const Color(0xFF00C853),
                      fontSize: 11.spScaled,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
