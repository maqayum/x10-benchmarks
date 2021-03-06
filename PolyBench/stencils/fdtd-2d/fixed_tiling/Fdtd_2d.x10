/*
 *  This file is part of the X10 project (http://x10-lang.org).
 *
 *  This file is licensed to You under the Eclipse Public License (EPL);
 *  You may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *      http://www.opensource.org/licenses/eclipse-1.0.php
 *
 *  (C) Copyright IBM Corporation 2015.
 * 
 *
 *  @author HUANG RUOCHEN (hrc706@gmail.com)
 */

import x10.compiler.Ifdef;
import x10.array.Array_2;
import x10.array.Array_3;
import x10.compiler.Foreach;
public class Fdtd_2d {

    var _PB_NX : Long;
    var _PB_NY : Long;
    var _PB_TMAX : Long;    def init_array (tmax : Long, nx : Long, ny : Long,
                    ex : Array_2[Double],
                    ey : Array_2[Double],
                    hz : Array_2[Double],
                    _fict_ : Rail[Double]) {
        for (var i : Long = 0; i < tmax; i++)
            _fict_(i) = i as Double;
        for (var i : Long = 0; i < nx; i++)
            for (var j : Long = 0; j < ny; j++) {
                ex(i,j) = ((i as Double)*(j+1)) / nx;
                ey(i,j) = ((i as Double)*(j+2)) / ny;
                hz(i,j) = ((i as Double)*(j+3)) / nx;
            }
    }    /* DCE code. Must scan the entire live-out data.
      Can be used also to check the correctness of the output. */
    def print_array(nx : Long, ny : Long,
                   ex : Array_2[Double],
                   ey : Array_2[Double],
                   hz : Array_2[Double]) {
        for (var i : Long = 0; i < nx; i++)
            for (var j : Long = 0; j < ny; j++) {
                Console.ERR.printf("%0.2lf ", ex(i,j));
                Console.ERR.printf("%0.2lf ", ey(i,j));
                Console.ERR.printf("%0.2lf ", hz(i,j));
                if ((i * nx + j) % 20 == 0) Console.ERR.printf ("\n");
            }
        Console.ERR.printf ("\n");
    }

    /* Main computational kernel. The whole function will be timed,
       including the call and return. */
    def kernel_fdtd_2d(tmax : long, nx : long, ny : long, ex : Array_2[double], ey : Array_2[double], hz : Array_2[double], _fict_ : Rail[double])  {
        var c3 : long;
        var c5 : long;
        var c1 : long;
        var c0 : long;
        var c4 : long;
        var c2 : long;
        if (((ny >= 1) && (tmax >= 1))) {
            for (c0 = 0; (c0 <= (((ny + (2 * tmax)) + -3) * 256 < 0 ? (256 < 0 ?  -(( -(((ny + (2 * tmax)) + -3)) + 256 + 1) / 256) :  -(( -(((ny + (2 * tmax)) + -3)) + 256 - 1) / 256)) : ((ny + (2 * tmax)) + -3) / 256)); c0++) {
                {
                    val c0_0 = c0;
                    Foreach.block(((c0_0 * 2 < 0 ?  -( -(c0_0) / 2) : (2 < 0 ? ( -(c0_0) +  -(2) - 1) /  -(2) : (c0_0 + 2 - 1) / 2)) > ((((256 * c0_0) + (-1 * tmax)) + 1) * 256 < 0 ?  -( -((((256 * c0_0) + (-1 * tmax)) + 1)) / 256) : (256 < 0 ? ( -((((256 * c0_0) + (-1 * tmax)) + 1)) +  -(256) - 1) /  -(256) : ((((256 * c0_0) + (-1 * tmax)) + 1) + 256 - 1) / 256)) ? ((c0_0 * 2 < 0 ?  -( -(c0_0) / 2) : (2 < 0 ? ( -(c0_0) +  -(2) - 1) /  -(2) : (c0_0 + 2 - 1) / 2))) as long : (((((256 * c0_0) + (-1 * tmax)) + 1) * 256 < 0 ?  -( -((((256 * c0_0) + (-1 * tmax)) + 1)) / 256) : (256 < 0 ? ( -((((256 * c0_0) + (-1 * tmax)) + 1)) +  -(256) - 1) /  -(256) : ((((256 * c0_0) + (-1 * tmax)) + 1) + 256 - 1) / 256))) as long),(((((ny + tmax) + -2) * 256 < 0 ? (256 < 0 ?  -(( -(((ny + tmax) + -2)) + 256 + 1) / 256) :  -(( -(((ny + tmax) + -2)) + 256 - 1) / 256)) : ((ny + tmax) + -2) / 256) < ((((256 * c0_0) + ny) + 30) * 64 < 0 ? (64 < 0 ?  -(( -((((256 * c0_0) + ny) + 30)) + 64 + 1) / 64) :  -(( -((((256 * c0_0) + ny) + 30)) + 64 - 1) / 64)) : (((256 * c0_0) + ny) + 30) / 64) ? ((((ny + tmax) + -2) * 256 < 0 ? (256 < 0 ?  -(( -(((ny + tmax) + -2)) + 256 + 1) / 256) :  -(( -(((ny + tmax) + -2)) + 256 - 1) / 256)) : ((ny + tmax) + -2) / 256)) as long : (((((256 * c0_0) + ny) + 30) * 64 < 0 ? (64 < 0 ?  -(( -((((256 * c0_0) + ny) + 30)) + 64 + 1) / 64) :  -(( -((((256 * c0_0) + ny) + 30)) + 64 - 1) / 64)) : (((256 * c0_0) + ny) + 30) / 64)) as long) < c0_0 ? (((((ny + tmax) + -2) * 256 < 0 ? (256 < 0 ?  -(( -(((ny + tmax) + -2)) + 256 + 1) / 256) :  -(( -(((ny + tmax) + -2)) + 256 - 1) / 256)) : ((ny + tmax) + -2) / 256) < ((((256 * c0_0) + ny) + 30) * 64 < 0 ? (64 < 0 ?  -(( -((((256 * c0_0) + ny) + 30)) + 64 + 1) / 64) :  -(( -((((256 * c0_0) + ny) + 30)) + 64 - 1) / 64)) : (((256 * c0_0) + ny) + 30) / 64) ? ((((ny + tmax) + -2) * 256 < 0 ? (256 < 0 ?  -(( -(((ny + tmax) + -2)) + 256 + 1) / 256) :  -(( -(((ny + tmax) + -2)) + 256 - 1) / 256)) : ((ny + tmax) + -2) / 256)) as long : (((((256 * c0_0) + ny) + 30) * 64 < 0 ? (64 < 0 ?  -(( -((((256 * c0_0) + ny) + 30)) + 64 + 1) / 64) :  -(( -((((256 * c0_0) + ny) + 30)) + 64 - 1) / 64)) : (((256 * c0_0) + ny) + 30) / 64)) as long)) as long : (c0_0) as long),(var c1 : long) => {
                        var c3 : long;
                        var c5 : long;
                        var c4 : long;
                        var c2 : long;
                        for (c2 = (c0_0 + (-1 * c1)); (c2 <= ((((((256 * c0_0) + (-256 * c1)) + (255 * nx)) * 256 < 0 ? (256 < 0 ?  -(( -((((256 * c0_0) + (-256 * c1)) + (255 * nx))) + 256 + 1) / 256) :  -(( -((((256 * c0_0) + (-256 * c1)) + (255 * nx))) + 256 - 1) / 256)) : (((256 * c0_0) + (-256 * c1)) + (255 * nx)) / 256) < (((((256 * c0_0) + (-256 * c1)) + nx) + 30) * 256 < 0 ? (256 < 0 ?  -(( -(((((256 * c0_0) + (-256 * c1)) + nx) + 30)) + 256 + 1) / 256) :  -(( -(((((256 * c0_0) + (-256 * c1)) + nx) + 30)) + 256 - 1) / 256)) : ((((256 * c0_0) + (-256 * c1)) + nx) + 30) / 256) ? (((((256 * c0_0) + (-256 * c1)) + (255 * nx)) * 256 < 0 ? (256 < 0 ?  -(( -((((256 * c0_0) + (-256 * c1)) + (255 * nx))) + 256 + 1) / 256) :  -(( -((((256 * c0_0) + (-256 * c1)) + (255 * nx))) + 256 - 1) / 256)) : (((256 * c0_0) + (-256 * c1)) + (255 * nx)) / 256)) as long : ((((((256 * c0_0) + (-256 * c1)) + nx) + 30) * 256 < 0 ? (256 < 0 ?  -(( -(((((256 * c0_0) + (-256 * c1)) + nx) + 30)) + 256 + 1) / 256) :  -(( -(((((256 * c0_0) + (-256 * c1)) + nx) + 30)) + 256 - 1) / 256)) : ((((256 * c0_0) + (-256 * c1)) + nx) + 30) / 256)) as long) < ((((((256 * c0_0) + (-256 * c1)) + (30 * tmax)) + (255 * nx)) + -30) * 992 < 0 ? (992 < 0 ?  -(( -((((((256 * c0_0) + (-256 * c1)) + (30 * tmax)) + (255 * nx)) + -30)) + 992 + 1) / 992) :  -(( -((((((256 * c0_0) + (-256 * c1)) + (30 * tmax)) + (255 * nx)) + -30)) + 992 - 1) / 992)) : (((((256 * c0_0) + (-256 * c1)) + (30 * tmax)) + (255 * nx)) + -30) / 992) ? ((((((256 * c0_0) + (-256 * c1)) + (255 * nx)) * 256 < 0 ? (256 < 0 ?  -(( -((((256 * c0_0) + (-256 * c1)) + (255 * nx))) + 256 + 1) / 256) :  -(( -((((256 * c0_0) + (-256 * c1)) + (255 * nx))) + 256 - 1) / 256)) : (((256 * c0_0) + (-256 * c1)) + (255 * nx)) / 256) < (((((256 * c0_0) + (-256 * c1)) + nx) + 30) * 256 < 0 ? (256 < 0 ?  -(( -(((((256 * c0_0) + (-256 * c1)) + nx) + 30)) + 256 + 1) / 256) :  -(( -(((((256 * c0_0) + (-256 * c1)) + nx) + 30)) + 256 - 1) / 256)) : ((((256 * c0_0) + (-256 * c1)) + nx) + 30) / 256) ? (((((256 * c0_0) + (-256 * c1)) + (255 * nx)) * 256 < 0 ? (256 < 0 ?  -(( -((((256 * c0_0) + (-256 * c1)) + (255 * nx))) + 256 + 1) / 256) :  -(( -((((256 * c0_0) + (-256 * c1)) + (255 * nx))) + 256 - 1) / 256)) : (((256 * c0_0) + (-256 * c1)) + (255 * nx)) / 256)) as long : ((((((256 * c0_0) + (-256 * c1)) + nx) + 30) * 256 < 0 ? (256 < 0 ?  -(( -(((((256 * c0_0) + (-256 * c1)) + nx) + 30)) + 256 + 1) / 256) :  -(( -(((((256 * c0_0) + (-256 * c1)) + nx) + 30)) + 256 - 1) / 256)) : ((((256 * c0_0) + (-256 * c1)) + nx) + 30) / 256)) as long)) as long : (((((((256 * c0_0) + (-256 * c1)) + (30 * tmax)) + (255 * nx)) + -30) * 992 < 0 ? (992 < 0 ?  -(( -((((((256 * c0_0) + (-256 * c1)) + (30 * tmax)) + (255 * nx)) + -30)) + 992 + 1) / 992) :  -(( -((((((256 * c0_0) + (-256 * c1)) + (30 * tmax)) + (255 * nx)) + -30)) + 992 - 1) / 992)) : (((((256 * c0_0) + (-256 * c1)) + (30 * tmax)) + (255 * nx)) + -30) / 992)) as long)); c2++) {
                            if ((((c0_0 == (c1 + c2)) && (nx >= 2)) && (ny >= 2))) {
                                for (c3 = (((256 * c0_0) + (-256 * c1)) > (((256 * c1) + (-1 * ny)) + 1) ? (((256 * c0_0) + (-256 * c1))) as long : ((((256 * c1) + (-1 * ny)) + 1)) as long); (c3 <= ((tmax + -1) < (((256 * c0_0) + (-256 * c1)) + 30) ? ((tmax + -1)) as long : ((((256 * c0_0) + (-256 * c1)) + 30)) as long)); c3++) {
                                    if ((c0_0 == (2 * c1))) {
                                        if (((c0_0 % 2) == 0)) {
                                            ey(0L,0) = _fict_(c3);
                                        }
                                        for (c5 = (c3 + 1); (c5 <= (((16 * c0_0) + 255) < ((c3 + nx) + -1) ? (((16 * c0_0) + 255)) as long : (((c3 + nx) + -1)) as long)); c5++) {
                                            if (((c0_0 % 2) == 0)) {
                                                ey(((-1 * c3) + c5),0) = ey(((-1 * c3) + c5),0) - 0.5 * (hz(((-1 * c3) + c5),0) - hz(((-1 * c3) + c5) - 1L,0));
                                            }
                                        }
                                    }
                                    for (c4 = ((256 * c1) > (c3 + 1) ? ((256 * c1)) as long : ((c3 + 1)) as long); (c4 <= (((256 * c1) + 255) < ((c3 + ny) + -1) ? (((256 * c1) + 255)) as long : (((c3 + ny) + -1)) as long)); c4++) {
                                        ex(0,((-1 * c3) + c4)) = ex(0,((-1 * c3) + c4)) - 0.5 * (hz(0,((-1 * c3) + c4)) - hz(0,((-1 * c3) + c4) - 1L));
                                        ey(0L,((-1 * c3) + c4)) = _fict_(c3);
                                        for (c5 = (c3 + 1); (c5 <= ((((256 * c0_0) + (-256 * c1)) + 255) < ((c3 + nx) + -1) ? ((((256 * c0_0) + (-256 * c1)) + 255)) as long : (((c3 + nx) + -1)) as long)); c5++) {
                                            ey(((-1 * c3) + c5),((-1 * c3) + c4)) = ey(((-1 * c3) + c5),((-1 * c3) + c4)) - 0.5 * (hz(((-1 * c3) + c5),((-1 * c3) + c4)) - hz(((-1 * c3) + c5) - 1L,((-1 * c3) + c4)));
                                            ex(((-1 * c3) + c5),((-1 * c3) + c4)) = ex(((-1 * c3) + c5),((-1 * c3) + c4)) - 0.5 * (hz(((-1 * c3) + c5),((-1 * c3) + c4)) - hz(((-1 * c3) + c5),((-1 * c3) + c4) - 1L));
                                            hz((((-1 * c3) + c5) + -1),(((-1 * c3) + c4) + -1)) = hz((((-1 * c3) + c5) + -1),(((-1 * c3) + c4) + -1)) - 0.7 * (ex((((-1 * c3) + c5) + -1),(((-1 * c3) + c4) + -1) + 1L) - ex((((-1 * c3) + c5) + -1),(((-1 * c3) + c4) + -1)) + ey((((-1 * c3) + c5) + -1) + 1L,(((-1 * c3) + c4) + -1)) - ey((((-1 * c3) + c5) + -1),(((-1 * c3) + c4) + -1)));
                                        }
                                    }
                                }
                            }
                            if (((((c0_0 == (2 * c1)) && (c0_0 == (2 * c2))) && (nx >= 2)) && (ny == 1))) {
                                for (c3 = (16 * c0_0); (c3 <= (((16 * c0_0) + 30) < (tmax + -1) ? (((16 * c0_0) + 30)) as long : ((tmax + -1)) as long)); c3++) {
                                    if (((c0_0 % 2) == 0)) {
                                        ey(0L,0) = _fict_(c3);
                                    }
                                    for (c5 = (c3 + 1); (c5 <= (((16 * c0_0) + 255) < ((c3 + nx) + -1) ? (((16 * c0_0) + 255)) as long : (((c3 + nx) + -1)) as long)); c5++) {
                                        if (((c0_0 % 2) == 0)) {
                                            ey(((-1 * c3) + c5),0) = ey(((-1 * c3) + c5),0) - 0.5 * (hz(((-1 * c3) + c5),0) - hz(((-1 * c3) + c5) - 1L,0));
                                        }
                                    }
                                }
                            }
                            if ((((c0_0 == (c1 + c2)) && (c0_0 <= (((((256 * c1) + tmax) + -256) * 256 < 0 ? (256 < 0 ?  -(( -((((256 * c1) + tmax) + -256)) + 256 + 1) / 256) :  -(( -((((256 * c1) + tmax) + -256)) + 256 - 1) / 256)) : (((256 * c1) + tmax) + -256) / 256) < ((2 * c1) + -1) ? (((((256 * c1) + tmax) + -256) * 256 < 0 ? (256 < 0 ?  -(( -((((256 * c1) + tmax) + -256)) + 256 + 1) / 256) :  -(( -((((256 * c1) + tmax) + -256)) + 256 - 1) / 256)) : (((256 * c1) + tmax) + -256) / 256)) as long : (((2 * c1) + -1)) as long))) && (nx >= 2))) {
                                for (c4 = (256 * c1); (c4 <= (((256 * c1) + 255) < ((((256 * c0_0) + (-256 * c1)) + ny) + 30) ? (((256 * c1) + 255)) as long : (((((256 * c0_0) + (-256 * c1)) + ny) + 30)) as long)); c4++) {
                                    ex(0,((((-256 * c0_0) + (256 * c1)) + c4) + -255)) = ex(0,((((-256 * c0_0) + (256 * c1)) + c4) + -255)) - 0.5 * (hz(0,((((-256 * c0_0) + (256 * c1)) + c4) + -255)) - hz(0,((((-256 * c0_0) + (256 * c1)) + c4) + -255) - 1L));
                                    ey(0L,((((-256 * c0_0) + (256 * c1)) + c4) + -255)) = _fict_((((256 * c0_0) + (-256 * c1)) + 255));
                                }
                            }
                            if (((((c0_0 == (2 * c1)) && (c0_0 == (2 * c2))) && (c0_0 <= ((tmax + -256) * 16 < 0 ? (16 < 0 ?  -(( -((tmax + -256)) + 16 + 1) / 16) :  -(( -((tmax + -256)) + 16 - 1) / 16)) : (tmax + -256) / 16))) && (nx >= 2))) {
                                if (((c0_0 % 2) == 0)) {
                                    ey(0L,0) = _fict_(((16 * c0_0) + 255));
                                }
                            }
                            if ((((c0_0 == (c1 + c2)) && (nx == 1)) && (ny >= 2))) {
                                for (c3 = (((256 * c0_0) + (-256 * c1)) > (((256 * c1) + (-1 * ny)) + 1) ? (((256 * c0_0) + (-256 * c1))) as long : ((((256 * c1) + (-1 * ny)) + 1)) as long); (c3 <= ((((256 * c1) + 30) < (tmax + -1) ? (((256 * c1) + 30)) as long : ((tmax + -1)) as long) < (((256 * c0_0) + (-256 * c1)) + 255) ? ((((256 * c1) + 30) < (tmax + -1) ? (((256 * c1) + 30)) as long : ((tmax + -1)) as long)) as long : ((((256 * c0_0) + (-256 * c1)) + 255)) as long)); c3++) {
                                    if ((c0_0 == (2 * c1))) {
                                        if (((c0_0 % 2) == 0)) {
                                            ey(0L,0) = _fict_(c3);
                                        }
                                    }
                                    for (c4 = ((256 * c1) > (c3 + 1) ? ((256 * c1)) as long : ((c3 + 1)) as long); (c4 <= (((256 * c1) + 255) < ((c3 + ny) + -1) ? (((256 * c1) + 255)) as long : (((c3 + ny) + -1)) as long)); c4++) {
                                        ex(0,((-1 * c3) + c4)) = ex(0,((-1 * c3) + c4)) - 0.5 * (hz(0,((-1 * c3) + c4)) - hz(0,((-1 * c3) + c4) - 1L));
                                        ey(0L,((-1 * c3) + c4)) = _fict_(c3);
                                    }
                                }
                            }
                            if ((((((c0_0 == (2 * c1)) && (c0_0 == (2 * c2))) && (c0_0 <= ((tmax + -256) * 16 < 0 ? (16 < 0 ?  -(( -((tmax + -256)) + 16 + 1) / 16) :  -(( -((tmax + -256)) + 16 - 1) / 16)) : (tmax + -256) / 16))) && (nx == 1)) && (ny >= 2))) {
                                if (((c0_0 % 2) == 0)) {
                                    ey(0L,0) = _fict_(((16 * c0_0) + 255));
                                }
                            }
                            if ((((c0_0 == (c1 + c2)) && (nx == 0)) && (ny >= 2))) {
                                for (c3 = (((256 * c0_0) + (-256 * c1)) > (((256 * c1) + (-1 * ny)) + 1) ? (((256 * c0_0) + (-256 * c1))) as long : ((((256 * c1) + (-1 * ny)) + 1)) as long); (c3 <= ((tmax + -1) < (((256 * c0_0) + (-256 * c1)) + 255) ? ((tmax + -1)) as long : ((((256 * c0_0) + (-256 * c1)) + 255)) as long)); c3++) {
                                    for (c4 = ((256 * c1) > c3 ? ((256 * c1)) as long : (c3) as long); (c4 <= (((256 * c1) + 255) < ((c3 + ny) + -1) ? (((256 * c1) + 255)) as long : (((c3 + ny) + -1)) as long)); c4++) {
                                        ey(0L,((-1 * c3) + c4)) = _fict_(c3);
                                    }
                                }
                            }
                            if (((((c0_0 == (2 * c1)) && (c0_0 == (2 * c2))) && (nx <= 1)) && (ny == 1))) {
                                for (c3 = (16 * c0_0); (c3 <= (((16 * c0_0) + 255) < (tmax + -1) ? (((16 * c0_0) + 255)) as long : ((tmax + -1)) as long)); c3++) {
                                    if (((c0_0 % 2) == 0)) {
                                        ey(0L,0) = _fict_(c3);
                                    }
                                }
                            }
                            if (((c0_0 <= ((c1 + c2) + -1)) && (ny >= 2))) {
                                for (c3 = ((((256 * c0_0) + (-256 * c1)) > (((256 * c1) + (-1 * ny)) + 1) ? (((256 * c0_0) + (-256 * c1))) as long : ((((256 * c1) + (-1 * ny)) + 1)) as long) > (((256 * c2) + (-1 * nx)) + 1) ? ((((256 * c0_0) + (-256 * c1)) > (((256 * c1) + (-1 * ny)) + 1) ? (((256 * c0_0) + (-256 * c1))) as long : ((((256 * c1) + (-1 * ny)) + 1)) as long)) as long : ((((256 * c2) + (-1 * nx)) + 1)) as long); (c3 <= ((((256 * c1) + 30) < (tmax + -1) ? (((256 * c1) + 30)) as long : ((tmax + -1)) as long) < (((256 * c0_0) + (-256 * c1)) + 255) ? ((((256 * c1) + 30) < (tmax + -1) ? (((256 * c1) + 30)) as long : ((tmax + -1)) as long)) as long : ((((256 * c0_0) + (-256 * c1)) + 255)) as long)); c3++) {
                                    if ((c0_0 == (2 * c1))) {
                                        for (c5 = (256 * c2); (c5 <= (((256 * c2) + 255) < ((c3 + nx) + -1) ? (((256 * c2) + 255)) as long : (((c3 + nx) + -1)) as long)); c5++) {
                                            if (((c0_0 % 2) == 0)) {
                                                ey(((-1 * c3) + c5),0) = ey(((-1 * c3) + c5),0) - 0.5 * (hz(((-1 * c3) + c5),0) - hz(((-1 * c3) + c5) - 1L,0));
                                            }
                                        }
                                    }
                                    for (c4 = ((256 * c1) > (c3 + 1) ? ((256 * c1)) as long : ((c3 + 1)) as long); (c4 <= (((256 * c1) + 255) < ((c3 + ny) + -1) ? (((256 * c1) + 255)) as long : (((c3 + ny) + -1)) as long)); c4++) {
                                        for (c5 = (256 * c2); (c5 <= (((256 * c2) + 255) < ((c3 + nx) + -1) ? (((256 * c2) + 255)) as long : (((c3 + nx) + -1)) as long)); c5++) {
                                            ey(((-1 * c3) + c5),((-1 * c3) + c4)) = ey(((-1 * c3) + c5),((-1 * c3) + c4)) - 0.5 * (hz(((-1 * c3) + c5),((-1 * c3) + c4)) - hz(((-1 * c3) + c5) - 1L,((-1 * c3) + c4)));
                                            ex(((-1 * c3) + c5),((-1 * c3) + c4)) = ex(((-1 * c3) + c5),((-1 * c3) + c4)) - 0.5 * (hz(((-1 * c3) + c5),((-1 * c3) + c4)) - hz(((-1 * c3) + c5),((-1 * c3) + c4) - 1L));
                                            hz((((-1 * c3) + c5) + -1),(((-1 * c3) + c4) + -1)) = hz((((-1 * c3) + c5) + -1),(((-1 * c3) + c4) + -1)) - 0.7 * (ex((((-1 * c3) + c5) + -1),(((-1 * c3) + c4) + -1) + 1L) - ex((((-1 * c3) + c5) + -1),(((-1 * c3) + c4) + -1)) + ey((((-1 * c3) + c5) + -1) + 1L,(((-1 * c3) + c4) + -1)) - ey((((-1 * c3) + c5) + -1),(((-1 * c3) + c4) + -1)));
                                        }
                                    }
                                }
                            }
                            if ((((c0_0 == (2 * c1)) && (c0_0 <= (((tmax + -256) * 16 < 0 ? (16 < 0 ?  -(( -((tmax + -256)) + 16 + 1) / 16) :  -(( -((tmax + -256)) + 16 - 1) / 16)) : (tmax + -256) / 16) < ((2 * c2) + -2) ? (((tmax + -256) * 16 < 0 ? (16 < 0 ?  -(( -((tmax + -256)) + 16 + 1) / 16) :  -(( -((tmax + -256)) + 16 - 1) / 16)) : (tmax + -256) / 16)) as long : (((2 * c2) + -2)) as long))) && (ny >= 2))) {
                                for (c5 = (256 * c2); (c5 <= (((256 * c2) + 255) < (((16 * c0_0) + nx) + 30) ? (((256 * c2) + 255)) as long : ((((16 * c0_0) + nx) + 30)) as long)); c5++) {
                                    if (((c0_0 % 2) == 0)) {
                                        ey((((-16 * c0_0) + c5) + -255),0) = ey((((-16 * c0_0) + c5) + -255),0) - 0.5 * (hz((((-16 * c0_0) + c5) + -255),0) - hz((((-16 * c0_0) + c5) + -255) - 1L,0));
                                    }
                                }
                            }
                            if ((((c0_0 == (2 * c1)) && (c0_0 <= ((2 * c2) + -2))) && (ny == 1))) {
                                for (c3 = ((16 * c0_0) > (((256 * c2) + (-1 * nx)) + 1) ? ((16 * c0_0)) as long : ((((256 * c2) + (-1 * nx)) + 1)) as long); (c3 <= (((16 * c0_0) + 255) < (tmax + -1) ? (((16 * c0_0) + 255)) as long : ((tmax + -1)) as long)); c3++) {
                                    for (c5 = (256 * c2); (c5 <= (((256 * c2) + 255) < ((c3 + nx) + -1) ? (((256 * c2) + 255)) as long : (((c3 + nx) + -1)) as long)); c5++) {
                                        if (((c0_0 % 2) == 0)) {
                                            ey(((-1 * c3) + c5),0) = ey(((-1 * c3) + c5),0) - 0.5 * (hz(((-1 * c3) + c5),0) - hz(((-1 * c3) + c5) - 1L,0));
                                        }
                                    }
                                }
                            }
                        }
                        if ((nx <= -1)) {
                            for (c3 = (((256 * c0_0) + (-256 * c1)) > (((256 * c1) + (-1 * ny)) + 1) ? (((256 * c0_0) + (-256 * c1))) as long : ((((256 * c1) + (-1 * ny)) + 1)) as long); (c3 <= ((tmax + -1) < (((256 * c0_0) + (-256 * c1)) + 255) ? ((tmax + -1)) as long : ((((256 * c0_0) + (-256 * c1)) + 255)) as long)); c3++) {
                                for (c4 = ((256 * c1) > c3 ? ((256 * c1)) as long : (c3) as long); (c4 <= (((256 * c1) + 255) < ((c3 + ny) + -1) ? (((256 * c1) + 255)) as long : (((c3 + ny) + -1)) as long)); c4++) {
                                    ey(0L,((-1 * c3) + c4)) = _fict_(c3);
                                }
                            }
                        }
                    }
);
                }
            }
        }
    }

    def setPBs(nx : Long, ny : Long, tmax : Long) {
        _PB_NX = nx;
        _PB_NY = ny;
        _PB_TMAX = tmax;
    }    public static def main(args : Rail[String]) {
        var TMAX : Long = 0;
        var NX : Long = 0;
        var NY : Long = 0;
        val dataset = args.size == 0 ?  "STANDARD_DATASET" : args(0);

        @Ifdef("MINI_DATASET") {
            TMAX = 2;
            NX = 32;
            NY = 32;
        }
        @Ifdef("SMALL_DATASET") {
            TMAX = 10;
            NX = 500;
            NY = 500;
        }
        @Ifdef("STANDARD_DATASET") {
            TMAX = 50;
            NX = 1000;
            NY = 1000;
        }
        @Ifdef("LARGE_DATASET") {
            TMAX = 50;
            NX = 2000;
            NY = 2000;
        }
        @Ifdef("EXTRALARGE_DATASET") {
            TMAX = 100;
            NX = 4000;
            NY = 4000;
        }

        val fdtd_2d = new Fdtd_2d();

        /* Retrieve problem size. */
        var nx : Long = NX;
        var ny : Long = NY;
        var tmax : Long = TMAX;
        fdtd_2d.setPBs(nx, ny, tmax);

        /* Variable declaration/allocation. */
        val ex  = new Array_2[Double](nx,ny); 

        val ey  = new Array_2[Double](nx,ny); 

        val hz  = new Array_2[Double](nx,ny); 
        val _fict_ = new Rail[Double](tmax);        /* Initialize array(s). */
        fdtd_2d.init_array (tmax, nx, ny, ex, ey, hz, _fict_);

        /* Start timer. */
        val t1 = System.currentTimeMillis();

        /* Run kernel. */
        fdtd_2d.kernel_fdtd_2d (tmax, nx, ny, ex, ey, hz, _fict_);

        /* Stop and print timer. */
        val t2 = System.currentTimeMillis();

        Console.OUT.printf ("Elapsed time= " + (t2 - t1) + " (ms)\n");
     // fdtd_2d.print_array(nx, ny, ex, ey, hz);  
    }
}
