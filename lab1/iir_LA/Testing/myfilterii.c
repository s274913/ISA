#include<stdio.h>
#include<stdlib.h>

#define NB 8  /// number of bits
#define N  1 // order of the filter

const int b0 = 53; /// coefficient b0
const int b[N]={53}; /// b array
const int a[N]={-21}; /// a array
const int ab=a[0]*b[0] >>(NB-1);
const int a_sqrd=a[0]*a[0] >>(NB-1);

/// Perform fixed point filtering assuming direct form II
///\param x is the new input sample
///\return the new output sample
int myfilter(int x)
{ 
  static int cont=0;
  static int sw[2]; /// w shift register
  static int sx[1];/// shift register della x
  static int first_run = 0; /// for cleaning the shift register
  int i; /// index
  int w; /// intermediate value (w)
  int y; /// output sample
  int fb, ff; /// feed-back and feed-forward results
  FILE *fd; // this file allow to know intermedial results. 
  int m1,m2,m3,m4,m5; // temponary variable.
  
  // opening the file 
  fd=fopen("val_inter.txt","a");
  
  /// clean the buffer
  if (first_run == 0)
  {
    first_run = 1;
    for (i=0; i<N+1; i++)
      sw[i] = 0;
    for (i=0; i<N; i++)
      sx[i] = 0;
  }

  /// compute feed-back and feed-forward
  fb = 0;
  ff = 0;
  for (i=0; i<N; i++)
  {
    m2= ((sx[i]*a[i])     >> (NB-1));
    m3= ((sw[i+1]*a_sqrd) >> (NB-1));
    m4= ((sw[i+1]*ab)     >> (NB-1));
    m5= ((sx[i]*b[i])     >> (NB-1));
    fb -= -( -m2 + m3 );
    ff +=  (  m5 - m4 );
  }

  /// compute intermediate value (w) and output sample
  w = x + fb;  
  y = (w*b0) >> (NB-1);

  /* check delle op. intermedie */ 
  fprintf(fd,"For the %d samples: s1:%d s2:%d s4:%d m1:%d m2:%d m3:%d m4:%d m5:%d\n",cont,w-m3,w,ff,y,m2,m3,m4,m5);
  fclose(fd);
  cont+=1;
 
  // compute the filtered result
  y += ff;

  
  /// update the shift register
  for (i=N-1; i>0; i--)
    sx[i] = sx[i-1];
  sx[0] = x;
  for (i=N; i>0; i--)
    sw[i] = sw[i-1];
  sw[0]=w;
  
  return y;
}

int main (int argc, char **argv)
{
  FILE *fp_in;
  FILE *fp_out;

  int x;
  int y;

  /// check the command line
  if (argc != 3)
  {
    printf("Use: %s <input_file> <output_file>\n", argv[0]);
    exit(1);
  }

  /// open files
  fp_in = fopen(argv[1], "r");
  if (fp_in == NULL)
  {
    printf("Error: cannot open %s\n",argv[1]);
    exit(2);
  }
  fp_out = fopen(argv[2], "w");

  /// get samples and apply filter
  fscanf(fp_in, "%d", &x);
  do{
    y = myfilter(x);
    fprintf(fp_out,"%d\n", y);
    fscanf(fp_in, "%d", &x);
  } while (!feof(fp_in));
  fclose(fp_in);
  fclose(fp_out);

  return 0;

}
