/**
* MINIMAL PORT OF MOTIONDRAWS LINE GENERALIZATION ALGORITHM
* http://www.motiondraw.com/blog/?p=50
*
* @originalAuthor 	Andreas Weber, webweber@motiondraw.com
* @version  1.1x   (Dec, 18, 2013) port to DART
* @version  1.1   (April 18, 2008) port to AS3
*         [ 1.0   (March 05, 2005) AS2 Version]
*
* Ported by Mario Gonzalez | mariogonzalez@gmail.com
*/
library LineGeneralization;
import 'dart:math' as Math;
import 'package:stagexl/stagexl.dart' as Geom show Matrix, Point;


List smoothMcMaster(points) {
  var len = points.length;
  var nL = new List(len);

  if (len < 5) {
    return points;
  }
  var j, avX, avY;
  var i = len;
  while (i-- > 0) {
    if (i == len - 1 || i == len - 2 || i == 1 || i == 0) {
      nL[i] = new Geom.Point(points[i].x, points[i].y);
    } else {
      j = 5;
      avX = 0;
      avY = 0;
      while (j-- > 0 ) {
        avX += points[i + 2 - j].x;
        avY += points[i + 2 - j].y;
      }
      avX = avX / 5;
      avY = avY / 5;
      nL[i] = nL[i] = new Geom.Point((points[i].x + avX) / 2, (points[i].y + avY) / 2);
    }
  }
  return nL;
}

List simplifyLang(lookAhead, tolerance, points) {

  if (lookAhead <= 1) {
    return points;
  }
  var offset, len, count;
  len = points.length;
  if (lookAhead > len - 1) {
    lookAhead = len - 1;
  }
  var nP = new List();
  nP.add( new Geom.Point(points[0].x, points[0].y) );
  for (var i = 0; i < len; i++) {
    if (i + lookAhead >= len) {
      lookAhead = len - i - 1;
    }
    offset = recursiveToleranceBar(points, i, lookAhead, tolerance);
    if (offset > 0) {
      nP.add( new Geom.Point(points[i + offset].x, points[i + offset].y) );
      i += offset - 1;// don't loop through the skipped points
    }
  }
  return nP;
}

num recursiveToleranceBar( points, i, lookAhead, tolerance){

  var n = lookAhead;
  var cP, cLP, v1, v2, angle, dx, dy;
  cP = points[i];// current point
  // the vector through the current point and the max look ahead point
  v1 = new Geom.Point(points[i + n].x - cP.x,points[i + n].y - cP.y);
  // loop through the intermediate points
  for (var j = 1; j <= n; j++) {
      // the vector	through the current point and the current intermediate point
    cLP = points[i + j]; // current look ahead point
    v2 = new Geom.Point( cLP.x - cP.x,cLP.y - cP.y);

    angle = Math.acos((v1.x * v2.x + v1.y * v2.y) / (Math.sqrt(v1.y * v1.y + v1.x * v1.x) * Math.sqrt(v2.y * v2.y + v2.x * v2.x)));
    if (angle.isNaN) {
      angle = 0;
    }
    // the hypothenuse is the line between the current point and the current intermediate point
    dx = cP.x - cLP.x;
    dy = cP.y - cLP.y;
    var lH = Math.sqrt(dx * dx + dy * dy);// lenght of hypothenuse

    // length of opposite leg / perpendicular offset
    if (Math.sin(angle) * lH >= tolerance) {
      // too long, exceeds tolerance
      n--;
      if (n > 0) {
      // back the vector up one point
      //trace('== recursion, new lookAhead '+n);
        return recursiveToleranceBar(points, i, n, tolerance);
      } else {
        //trace('== return 0, all exceed tolerance');
        return 0;
        // all intermediate points exceed tolerance
      }

    }
  }
  return n;
}
