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

import x10.array.Array_2;
import x10.array.Array_3;
import x10.compiler.Ifdef;
public class Reg_detect {

  var _PB_NITER : Long;
  var _PB_LENGTH : Long;
  var _PB_MAXGRID : Long;  

  def setPBs(niter : Long, length : Long, maxgrid : Long) {
    _PB_NITER = niter; 
    _PB_LENGTH = length; 
    _PB_MAXGRID = maxgrid; 
  }
  def init_array(maxgrid : Long,
  		sum_tang : Array_2[Long],
  		mean : Array_2[Long],
  		path : Array_2[Long])
  {
    for (var i : Long = 0; i < maxgrid; i++)
      for (var j : Long = 0; j < maxgrid; j++) {
        sum_tang(i,j) = (((i+1) as Long) * (j+1));
        mean(i,j) = ((i as Long)-j) / maxgrid;
        path(i,j) = ((i as Long)*(j-1)) / maxgrid;
      }
  }  /* DCE code. Must scan the entire live-out data.
     Can be used also to check the correctness of the output. */
  def print_array(maxgrid : Long,
  		 path : Array_2[Long])
  {
    for (var i : Long = 0; i < maxgrid; i++)
      for (var j : Long = 0; j < maxgrid; j++) {
        Console.ERR.printf("%d ", path(i,j));
        if ((i * maxgrid + j) % 20 == 0) Console.ERR.printf("\n");
      }
    Console.ERR.printf("\n");
  }  

  /* Main computational kernel. The whole function will be timed,
     including the call and return. */
  def kernel_reg_detect(niter : Long, maxgrid : Long, length : Long,
  		       sum_tang : Array_2[Long],
  		       mean : Array_2[Long],
  		       path : Array_2[Long],
  		       diff : Array_3[Long],
  		       sum_diff : Array_3[Long])
  {
  // #pragma scop
    var t : Long;
    var j : Long;
    var i : Long;
    for (t = 0; t < niter; t++) {
        for (j = 0; j <= maxgrid - 1; j++)
            for (i = j; i <= maxgrid - 1; i++)
                for (var cnt : Long = 0; cnt <= length - 1; cnt++)
                    diff(j,i,cnt) = sum_tang(j,i);

        for (j = 0; j <= maxgrid - 1; j++) {
            for (i = j; i <= maxgrid - 1; i++) {
                sum_diff(j,i,0) = diff(j,i,0);
                for (var cnt : Long = 1; cnt <= length - 1; cnt++) {
                    sum_diff(j,i,cnt) = sum_diff(j,i,cnt - 1) + diff(j,i,cnt);
                }
                mean(j,i) = sum_diff(j,i,length - 1);
            }
        }

        for (i = 0; i <= maxgrid - 1; i++) {
            path(0,i) = mean(0,i);
        }

        for (j = 1; j <= maxgrid - 1; j++) {
            for (i = j; i <= maxgrid - 1; i++) {
                path(j,i) = path(j - 1,i - 1) + mean(j,i);
            }
        }
    }
  // #pragma endscop
  
  }  public static def main(args : Rail[String])
  {
    var NITER : Long = 0;
    var LENGTH : Long = 0;
    var MAXGRID : Long = 0;
    
    @Ifdef("EXTRALARGE_DATASET") {
        NITER = 10000;
        LENGTH = 500;
        MAXGRID = 12;
    }
    @Ifdef("STANDARD_DATASET") {
        NITER = 10000;
        LENGTH = 64;
        MAXGRID = 6;
    }
    @Ifdef("MINI_DATASET") {
        NITER = 10;
        LENGTH = 32;
        MAXGRID = 2;
    }
    @Ifdef("SMALL_DATASET") {
        NITER = 100;
        LENGTH = 50;
        MAXGRID = 6;
    }
    @Ifdef("LARGE_DATASET") {
        NITER = 10000;
        LENGTH = 100;
        MAXGRID = 1000;
    }
    
    val reg_detect = new Reg_detect();
    /* Retrieve problem size. */
    var niter  : Long= NITER;
    var maxgrid  : Long= MAXGRID;
    var length  : Long= LENGTH;
  
    reg_detect.setPBs(niter, length, maxgrid);
    /* Variable declaration/allocation. */
    val sum_tang = new Array_2[Long](maxgrid,maxgrid);

    val mean = new Array_2[Long](maxgrid,maxgrid);

    val path = new Array_2[Long](maxgrid,maxgrid);

    val diff = new Array_3[Long](maxgrid,maxgrid,length);

    val sum_diff = new Array_3[Long](maxgrid,maxgrid,length);    /* Initialize array(s). */
    reg_detect.init_array (maxgrid,
  	      sum_tang,
  	      mean,
  	      path);
  
    /* Start timer. */
    val t1 = System.currentTimeMillis();
  
    /* Run kernel. */
    reg_detect.kernel_reg_detect (niter, maxgrid, length,
  		     sum_tang,
  		     mean,
  		     path,
  		     diff,
  		     sum_diff);
  
    /* Stop and prvar timer : Long. */
    val t2 = System.currentTimeMillis();
    Console.OUT.printf("Elapsed time= " + (t2 - t1) + " (ms)");
    // reg_detect.print_array(maxgrid, path);
  
    /* Prevent dead-code elimination. All live-out data must be printed
       by the function call in argument. */
  
    /* Be clean. */
  
  }
}
