import 'package:flutter/material.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class HomePopularCard extends StatelessWidget {
  final String category;
  final String title;
  final String currentPrice;
  final String oldPrice;
  final String rating;
  final String students;
  final String imageUrl;

  const HomePopularCard({
    super.key,
    required this.category,
    required this.title,
    required this.currentPrice,
    required this.oldPrice,
    required this.rating,
    required this.students,
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
          padding: EdgeInsets.all(16.sw),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.sw),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 14.sw,
                offset: Offset(0, 4.sh),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 100.sw,
                height: 100.sw,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.sw),
                  image: DecorationImage(
                    image: (imageUrl.startsWith('http'))
                        ? NetworkImage(imageUrl)
                        : const AssetImage('assets/images/placeholder.png')
                              as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 16.sw),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.sw,
                        vertical: 4.sh,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF335EF7).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.sw),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: const Color(0xFF335EF7),
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
                    SizedBox(height: 8.sh),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 16.sw,
                        ),
                        SizedBox(width: 4.sw),
                        Text(
                          rating,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.spScaled,
                            color: const Color(0xFF1A1D2E),
                          ),
                        ),
                        SizedBox(width: 8.sw),
                        Text(
                          '$students طالب',
                          style: TextStyle(
                            fontSize: 12.spScaled,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.sh),
                    Row(
                      children: [
                        Text(
                          currentPrice,
                          style: TextStyle(
                            color: const Color(0xFF335EF7),
                            fontWeight: FontWeight.bold,
                            fontSize: 15.spScaled,
                          ),
                        ),
                        SizedBox(width: 8.sw),
                        Text(
                          oldPrice,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12.spScaled,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
