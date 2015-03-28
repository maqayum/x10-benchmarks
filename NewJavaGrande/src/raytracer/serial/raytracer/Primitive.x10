/**************************************************************************
*                                                                         *
*             Java Grande Forum Benchmark Suite - Version 2.0             *
*                                                                         *
*                            produced by                                  *
*                                                                         *
*                  Java Grande Benchmarking Project                       *
*                                                                         *
*                                at                                       *
*                                                                         *
*                Edinburgh Parallel Computing Centre                      *
*                                                                         *
*                email: epcc-javagrande@epcc.ed.ac.uk                     *
*                                                                         *
*                 Original version of this code by                        *
*            Florian Doyon (Florian.Doyon@sophia.inria.fr)                *
*              and  Wilfried Klauser (wklauser@acm.org)                   *
*                                                                         *
*      This version copyright (c) The University of Edinburgh, 1999.      *
*                         All rights reserved.                            *
*                                                                         *
**************************************************************************/
package raytracer.serial.raytracer;

//ok
public abstract class Primitive {
	public var surf: Surface;

	public def this(): Primitive {
		surf = new Surface();
	}
	public def this(var s: Surface): Primitive {
		surf = ((s == null) ? new Surface() : s as Surface);
	}

	abstract public def normal(var pnt: Vec): Vec;
	abstract public def intersect(var ry: Ray): Isect;
	abstract public def toString(): String;
	abstract public def getCenter(): Vec;
	//public abstract void setCenter(Vec c);
}
