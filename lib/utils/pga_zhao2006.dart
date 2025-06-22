import 'dart:math';

double pgaZhao2006(double mW, double rRup, double h,
    {int siteClass = 0, String mechanism = "interface"}) {
  // Coefficients from Douglas (2022)
  double a = 1.101;
  double b = -0.00564;
  double c = 0.0055;
  double d = 1.080;
  double e = 0.01412;
  // double sR = 0.251;
  double sI = 0.0;
  double sS = 2.607;
  double sSL = -0.528;
  double c1 = 1.111;
  double c2 = 1.344;
  double c3 = 1.355;
  double c4 = 1.420;
  double cH = 0.293;
  // double sIgma = 0.604; // Intra-event variability
  // double tau = 0.398; // Inter-event variability

  // Define hc = 15 km for best depth correction
  double hc = 15;
  int deltaH = h >= hc ? 1 : 0; // Depth function

  // Mechanism correction factors
  double fR = 0; // Initialize fR with a default value

  if (mechanism == "crustal") {
    fR = 1;
    sI = 0;
    sS = 0;
    sSL = 0;
  } else if (mechanism == "interface") {
    fR = 0;
    sI = 1;
    sS = 0;
    sSL = 0;
  } else if (mechanism == "slab") {
    fR = 0;
    sI = 0;
    sS = 1;
    sSL = 1; // Slab events use SS + SSL
  }

  // sIte class coefficients
  List<double> siteCoeffs = [cH, c1, c2, c3, c4];
  double cK = siteCoeffs[siteClass];

  // Compute r = x + c * exp(d * mW)
  double x = rRup; // Assuming x = rRup
  double r = x + c * exp(d * mW); // Use exp from the math library

  // Compute PGA (log-space)
  double lnPga = (a * mW +
      b * rRup -
      log(r) +
      e * (h - hc) * deltaH +
      fR +
      sI +
      sS +
      sSL * log(x) +
      cK);

  // Convert to PGA (cm/s²)
  double pgaCmS2 = exp(lnPga); // Use exp from the math library

  // Convert to %g (1 g ≈ 981 cm/s²)
  double pgaPercentG = (pgaCmS2 / 981) * 100;

  return pgaPercentG;
}

// void main() {
//   // Test parameters
//   double Mw = 5.2; // Magnitude
//   double Rrup = 72; // Rupture distance (km)
//   double h = 50; // Focal depth (km)
//   String mechanism = "interface"; // Options: "crustal", "interface", "slab"
//   int siteClass = 3; // Options: "SC I", "SC II", "SC III", "SC IV"

//   // Call the computePGA function
//   double pgaResult =
//       pgaZhao2006(Mw, Rrup, h, mechanism: mechanism, siteClass: siteClass);

//   // Print the result
//   print("Predicted PGA: ${pgaResult.toStringAsFixed(2)} %g");
// }
