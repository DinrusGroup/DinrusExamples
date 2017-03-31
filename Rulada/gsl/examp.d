 import auxc.gsl.gsl_poly, auxc.gsl.gsl_sf_bessel; 
  
  
 int main()
{
		
		double x=6.0;
		double y=gsl_sf_bessel_J0(x);
		printf("J0(%g)=%.18e\n",x,y);
		
		 int i;
  /* coefficient of P(x) =  -1 + x^5  */
  double a[6] = [ -1, 0, 0, 0, 0, 1 ];  
  double z[10];

  gsl_poly_complex_workspace * w 
      = gsl_poly_complex_workspace_alloc (6);
  
  gsl_poly_complex_solve (cast(double*) a, 6, w, cast(double*) z);

  gsl_poly_complex_workspace_free (w);

  for (i = 0; i < 5; i++)
    {
      printf ("z%d = %+.18f %+.18f\n", 
              i, z[2*i], z[2*i+1]);
    }
	
		return 0;
} 
  
