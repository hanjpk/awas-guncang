import 'package:flutter/material.dart';

List<dynamic> _shelter = [
  [
    'Lapangan BMKG Pusat',
    'https://cdn.bmkg.go.id/Web/Logo-BMKG-new.png',
    'Kemayoran',
    '1 KM'
  ],
  [
    'ATM',
    'https://img.icons8.com/external-kiranshastry-lineal-color-kiranshastry/2x/external-atm-banking-and-finance-kiranshastry-lineal-color-kiranshastry.png',
    'Gunung Sahari',
    '2.5 KM'
  ],
  [
    'Bioskop',
    'https://img.icons8.com/color-glass/2x/netflix.png',
    'Sunter',
    '5 KM'
  ],
  [
    'Apple Store',
    'https://img.icons8.com/color/2x/mac-os--v2.gif',
    'Bintaro',
    '20 KM'
  ],
];

Widget makeInfo() {
  return Transform.translate(
    offset: const Offset(0, 0),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const Text(
            //   "Nearest Assembly Point and Shelter",
            //   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            // ),
            ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 20),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _shelter.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade100,
                        blurRadius: 5,
                        spreadRadius: 1,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.network(
                            _shelter[index][1],
                            width: 50,
                            height: 50,
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _shelter[index][0],
                                style: TextStyle(
                                  color: Colors.grey.shade900,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _shelter[index][2],
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        _shelter[index][3],
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}
